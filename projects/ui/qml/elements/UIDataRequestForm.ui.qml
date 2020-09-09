import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3
import com.biogearsengine.ui.scenario 1.0

Column {
	id : root
  spacing : 2
  property string pathId : ""   //unique to each request, used to search for requests to remove when unchecked in menu
  property string requestRoot : ""    //Top level request catergory, e.g. compartment, physiology, substance, etc.
  property var requestBranches : []    //Intermediate tiers of data (e.g. compartment type, compartment name, substance name, physiology subsection
  property string requestLeaf : ""  //Request name
  property string unitClass : ""
  property string header : {
    if (requestRoot == "Compartment"){
      return requestBranches[0] + " Compartment Data Request: " + requestBranches[1]
    } else if (requestRoot == "Physiology"){
      return "Physiology Data Request: " + requestBranches[0]
    } else if (requestRoot == "Substance"){
      return "Substance Data Request: " + requestBranches[0]
    } else if (requestRoot == "Patient"){
      return "Patient Data Request"
    } else if (requestRoot == "Environment"){
      return "Environment Data Request"
    } else {
      return ""
    }
  }
  Rectangle {
    width : parent.width
    height : 20
    color : "transparent"
    Text {
      anchors.left : parent.left
      height : parent.height
      text : header
      font.pointSize : 12
      font.bold : true
      verticalAlignment : Text.AlignVCenter
    }
  }
  Loader {
    id : requestLoader
    height : 30
    width : parent.width
    sourceComponent : requestLeaf ==='SubstanceQuantity' ? subQuantityRequest : scalarQuantityRequest
  }
  Rectangle {
    color : "black"
    width : parent.width
    height : 2
  }
  //Component used by requestLoader when a simple scalar reqeust is being made
  Component {
    id : scalarQuantityRequest
    RowLayout {
      id : scalarLayout
      spacing : 0
      Rectangle {
        Layout.preferredHeight : parent.height - parent.spacing * 3
        Layout.preferredWidth : 2 * parent.width / 5
        color : "transparent"
        Text {
          height : parent.height
          anchors.left : parent.left
          font.pointSize : 12
          text : requestLeaf
          verticalAlignment : Text.AlignVCenter
        }
      }
      Loader {
        id : unitCombo
        sourceComponent : comboInput
        property var _label_text : "Unit"
        property var _combo_model : units[unitClass]
        onLoaded : {
          Layout.preferredHeight = scalarLayout.height
          Layout.preferredWidth  = 2 * scalarLayout.width / 5
        }
      }
      Loader {
        id : precisionCombo
        sourceComponent : comboInput
        property var _label_text : "Precision"
        property var _combo_model : 6
        onLoaded : {
          Layout.preferredHeight = scalarLayout.height
          Layout.preferredWidth  = scalarLayout.width / 5
        }
      }
    } 
  }
  //Component used by requestLoader for Compartment substance quantity requests (more data--need to choose substance and request type)
  Component {
    id : subQuantityRequest
    RowLayout {
      id : subLayout
      spacing : 0
      Loader {
        id : quantityCombo
        sourceComponent : comboInput
        property var _sub_quantity_model : requestBranches[0] === 'Gas' ? gasSubQuantities : requestBranches[0] === 'Liquid' ? liquidSubQuantities : tissueSubQuantities
        property var _label_text : "Quantity"
        property var _combo_model : Object.keys(_sub_quantity_model)
        Connections {
          target: quantityCombo.item
          onOptionSelected : { unitCombo._combo_model = quantityCombo._sub_quantity_model[text] }
        }
        onLoaded : {
          Layout.preferredHeight = subLayout.height
          Layout.preferredWidth  = 2 * subLayout.width / 5
        }
      }
      Loader {
        id : unitCombo
        sourceComponent : comboInput
        property var _label_text : "Unit"
        property var _combo_model : null
        onLoaded : {
          Layout.preferredHeight = subLayout.height
          Layout.preferredWidth  = 2 * subLayout.width / 5
        }
      }
      Loader {
        id : precisionCombo
        sourceComponent : comboInput
        property var _label_text : "Precision"
        property var _combo_model : 6
        onLoaded : {
          Layout.preferredHeight = subLayout.height
          Layout.preferredWidth  = subLayout.width / 5
        }
      }
    } 
  }
  //Component used to stand up all unit/precision/substance/substance parameter combo selection widgets
  Component {
    id : comboInput
    Rectangle {
      id : inputWrapper
      color : "transparent"
      signal optionSelected(int index, string text)
      property var labelText : _label_text
      property var comboModel : _combo_model
      onComboModelChanged : {
        comboBox.currentIndex = -1
      }
      Label {
        id : label
        text : labelText
        width : parent.width / 2
        height : parent.height 
        font.pointSize : 12
        verticalAlignment : Text.AlignVCenter
        horizontalAlignment : Text.AlignHCenter
      }
      ComboBox {
        id : comboBox
        currentIndex : -1
        anchors.left : label.right
        bottomInset : 0
        topInset : 0
        model : comboModel
        flat : false
        contentItem : Text {
          width : comboBox.width
          height : comboBox.height
          text : comboBox.displayText
          font.pointSize : 12
          verticalAlignment : Text.AlignVCenter
          horizontalAlignment : Text.AlignHCenter
        }
        delegate : ItemDelegate {
          width : comboBox.popup.width
          contentItem : Text {
            width : parent.width
            text : modelData
            font.pointSize : 12
            verticalAlignment : Text.AlignVCenter
            horizontalAlignment : Text.AlignHCenter
            }
          background : Rectangle {
            anchors.fill : parent
            color : "transparent"
            border.color : "green"
            border.width : comboBox.highlightedIndex === index ? 2 : 0
          }
        }
        popup : Popup {
          y : comboBox.height
          x : 0
          padding : 0
          width : comboBox.width - comboBox.indicator.width
          implicitHeight : contentItem.implicitHeight
          contentItem : ListView {
            clip : true
            implicitHeight : contentHeight
            model : comboBox.popup.visible ? comboBox.delegateModel : null
            currentIndex : comboBox.highlightedIndex
          }
        }
        background : Rectangle {
          id : comboBackground
          implicitWidth : inputWrapper.width / 2
          implicitHeight : inputWrapper.height
          border.color : "black"
          border.width : 1
        }
        onActivated : {
          inputWrapper.optionSelected(currentIndex, currentText)
        }
      }
    }
  }

	property var units : ({ 'AmountPerTime' : ['umol/s','mol/s','pmol/min','umol/min','mmol/min', 'mol/day'],
                          'AmountPerVolume' : ['mmol/mL','mmol/L','mol/mL','mol/L','ct/uL','ct/L'],
                          'Area' : ['cm^2','m^2'],
                          'ElectricPotential' : ['mV','V'],
                          'Energy': ['mJ','J','kJ','kcal'],
                          'FlowResistance' : ['mmHg s/mL','mmHg min/mL','mmHg min/L','cmH2O s/L','Pa s/m^3'],
                          'Frequency' : ['1/s', '1/min', 'Hz', '1/hr'],
                          'HeatCapacitancePerMass' : ['J/K kg','kJ/K kg','kcal/degC kg','kcal/K kg'],
                          'Mass' : ['ug','mg','g','kg','lb'],
                          'MassPerTime' : ['ug/s','mg/s','g/s','kg/s','ug/min','mg/min','g/min','g/day'],
                          'MassPerVolume' : ['ug/mL','ug/L','mg/mL','mg/dL','mg/L','mg/m^3','g/mL','g/cm^3','g/dL','g/L','g/m^3','kg/mL','kg/L','kg/m^3'],
                          'Osmolality' : ['mOsm/kg','Osm/kg'],
                          'Osmolarity' : ['mOsm/L','Osm/L'],
                          'Power': ['W','kcal/s','kcal/min','kcal/hr','BTU/hr'],
                          'Pressure' : ['Pa','cmH2O','mmHg','atm','psi'],
                          'PressureTimePerVolumeArea' : ['mmHg s/mL m^2','mmHg min/mL m^2','dyn s/cm^5 m^2'],
                          'Temperature': ['degC','K','degF','degR'],
                          'Time' : ['s', 'min','hr','day','yr'],
                          'TimeMassPerVolume' : ['s ug/mL','s g/L','min ug/mL','min g/L','hr ug/mL','hr g/L'],
                          'Volume' : ['uL','mL','dL','L','m^3'],
                          'VolumePerTime' : ['mL/s','mL/min','mL/hr','mL/day','L/s','L/min','L/day','m^3/s'],
                          'VolumePerTimePressure' : ['mL/s mmHg','mL/min mmHg','L/s mmHg','L/min mmHg']
                         })
  property var gasSubQuantities : ({'Partial Pressure' : '','Volume' : 'Volume','Volume Fraction':''})
  property var liquidSubQuantities : ({'Concentration' : 'MassPerVolume', 'Mass' : 'Mass','Mass Cleared' : 'Mass', 'Mass Deposited' : 'Mass', 'Mass Excreted' : 'Mass',
                                        'Molarity' : 'AmountPerVolume', 'Partial Pressure' : 'Pressure', 'Saturation' : ''})
  property var tissueSubQuantities : ({'Mass' : 'Mass', 'TissueConcentration' : 'MassPerVolume', 'Tissue Molarity' : 'AmountPerVolume', 'Extravascular Concentration' : 'MassPerVolume',
                                        'Extravascular Molarity' : 'AmountPerVolume', 'Extravascular Partial Pressure' : 'Pressure', 'Extravascular Saturation' : ''})
}

/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/