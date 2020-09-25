import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3
import com.biogearsengine.ui.scenario 1.0

Column {
	id : root
  spacing : 5
  anchors.left : parent ? parent.left : undefined
  anchors.right : parent ? parent.right : undefined
  anchors.rightMargin : scrollWidth
  property double scrollWidth : 0   //Override if data request is inside a view with a scroll bar so that request is not drawn over scroll area
  property string pathId : ""   //unique to each request, used to search for requests to remove when unchecked in menu
  property string requestRoot : ""    //Top level request catergory, e.g. compartment, physiology, substance, etc.
  property var requestBranches : []    //Intermediate tiers of data (e.g. compartment type, compartment name, substance name, physiology subsection
  property string requestLeaf : ""  //Request name
  property string unitClass : ""
  property string precisionValue : ""
  property string unitValue : ""
  property string substanceValue: ""      //only required for substance quantities
  property string quantityValue : ""      //only required for substance quantities
  property string header : {
    if (requestRoot == "Compartment"){
      if (requestLeaf.includes("SubstanceQuantity")){
        return requestBranches[0] + " Compartment Data Request: " + requestBranches[1] + " (Substance Quantity)"
      } else {
        return requestBranches[0] + " Compartment Data Request: " + requestBranches[1]
      }
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
    anchors.left : parent ? parent.left : undefined
    anchors.right : parent ? parent.right : undefined
    height : 20
    color : "transparent"
    Text {
      anchors.left : parent ? parent.left : undefined
      height : parent.height
      text : header
      font.pointSize : 12
      font.bold : true
      verticalAlignment : Text.AlignVCenter
    }
  }
  Loader {
    id : requestLoader
    anchors.left : parent ? parent.left : undefined
    anchors.right : parent ? parent.right : undefined
    height : 30
    sourceComponent : requestLeaf.includes('SubstanceQuantity') ? subQuantityRequest : scalarQuantityRequest
  }
  Rectangle {
    color : "black"
    anchors.left : parent ? parent.left : undefined
    anchors.right : parent ? parent.right : undefined
    height: 2
  }
  //Component used by requestLoader when a simple scalar reqeust is being made
  Component {
    id : scalarQuantityRequest
    RowLayout {
      id : scalarLayout
      spacing : 40
      Rectangle {
        Layout.preferredHeight : parent.height
        Layout.preferredWidth : 0.4 * scalarLayout.width - spacing * 2
        color : "transparent"
        Text {
          height : parent.height
          width : parent.width
          anchors.left : parent.left
          font.pointSize : 12
          text : root.displayFormat(requestLeaf)
          leftPadding : 20
          verticalAlignment : Text.AlignVCenter
          horizontalAlignment : Text.AlignLeft
        }
      }
      Loader {
        id : unitCombo
        sourceComponent : unitClass == "" ? null : comboInput
        property var _label_text : "Unit"
        property var _combo_model : units[unitClass]
        property string _initial_text : root.unitValue
        Layout.preferredHeight : scalarLayout.height
        Layout.preferredWidth  : 0.3 * scalarLayout.width - spacing * 2
        Layout.alignment : Qt.AlignHCenter
        Connections {
          target : unitCombo.item
          onActivated : {root.unitValue = target.currentText }
        }
      }
      Loader {
        id : precisionCombo
        sourceComponent : comboInput
        property var _label_text : "Precision"
        property var _combo_model : ["0", "1", "2", "3", "4", "5", "6"]
        property string _initial_text : root.precisionValue
        Layout.preferredHeight : scalarLayout.height
        Layout.preferredWidth  :  0.3 * scalarLayout.width - spacing * 2
        Layout.alignment : Qt.AlignHCenter
        Connections {
          target : precisionCombo.item
          onActivated : {root.precisionValue = target.currentText }
        }
      }
    }
  }
  //Component used by requestLoader for Compartment substance quantity requests (more data--need to choose substance and request type)
  Component {
    id : subQuantityRequest
    RowLayout {
      id : subLayout
      spacing : 5
      Loader {
        id : subCombo
        sourceComponent : comboInput
        property var _label_text : "Substance"
        property var _combo_model : scenario.get_components()
        property string _initial_text : root.substanceValue
        Layout.preferredHeight : subLayout.height
        Layout.preferredWidth  : 200 //subLayout.width / 4 - spacing * 3
        Layout.alignment : Qt.AlignHCenter
        Connections {
          target : subCombo.item
          onActivated : { root.substanceValue = target.currentText; 
                          root.substanceQuantityChanged(root.substanceValue, root.quantityValue) }
        }
      }
      Loader {
        id : quantityCombo
        sourceComponent : comboInput
        property var _sub_quantity_model : requestBranches[0] === 'Gas' ? gasSubQuantities : requestBranches[0] === 'Liquid' ? liquidSubQuantities : tissueSubQuantities
        property var _label_text : "Quantity"
        property var _combo_model : Object.keys(_sub_quantity_model)
        property string _initial_text : root.quantityValue
        Layout.preferredHeight : subLayout.height
        Layout.preferredWidth  : 200 //subLayout.width / 4 - spacing * 3
        Layout.alignment : Qt.AlignHCenter
        Connections {
          target: quantityCombo.item
          onActivated : { root.quantityValue = target.currentText; 
                          root.substanceQuantityChanged(root.substanceValue, root.quantityValue);
                          if (quantityCombo._sub_quantity_model[quantityValue]==""){
                            unitCombo._has_unit = false;
                            unitValue = "unitless"
                          } else {
                            unitCombo._has_unit = true;
                            unitValue = ""
                          }
          }
        }
      }
      Loader {
        id : unitCombo
        sourceComponent : _has_unit ? comboInput : undefined
        property bool _has_unit : true    //false for quantities like Volume Fraction or Saturation 
        property var _label_text : "Unit"
        property var _combo_model : quantityValue === "" ? null : units[quantityCombo._sub_quantity_model[quantityValue]]   //Quantity value will be empty when creating new scenario but defined when loading existing
        property string _initial_text : root.unitValue
        Layout.preferredWidth : subLayout.width / 4 - spacing * 3
        Layout.preferredHeight : subLayout.height
        Layout.alignment : Qt.AlignHCenter
        Connections {
          target : unitCombo.item
          onActivated : {root.unitValue = target.currentText}
        }
      }
      Loader {
        id : precisionCombo
        sourceComponent : comboInput
        property var _label_text : "Precision"
        property var _combo_model : ["0", "1", "2", "3", "4", "5", "6"]
        property string _initial_text : root.precisionValue
        Layout.preferredWidth : subLayout.width / 4 - spacing * 3
        Layout.preferredHeight : subLayout.height
        Layout.alignment : Qt.AlignHCenter
        Connections {
          target : precisionCombo.item
          onActivated : {root.precisionValue = target.currentText }
        }
      }
    }
  }
  //Component used to stand up all unit/precision/substance/substance parameter combo selection widgets
  Component {
    id : comboInput
    ComboBox {
      id : comboBox
      currentIndex : setCurrentIndex()
      property string initialText : _initial_text
      bottomInset : 0
      topInset : 0
      model : _combo_model
      flat : false
      contentItem : Text {
        width : comboBox.width
        height : comboBox.height
        text : currentIndex == -1 ? _label_text : displayText
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
        //Height and width of this rectangle established by Layout preferred dimensions assigned in Loader
        border.color : "black"
        border.width : 1
      }
      function setCurrentIndex(){
        if (model){
          for (let i = 0; i < model.length; ++i){
            if (model[i]===initialText){
              return i;
            }
          }
        }
        return -1;
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
  property var gasSubQuantities : ({'Partial Pressure' : 'Pressure','Volume' : 'Volume','Volume Fraction':''})
  property var liquidSubQuantities : ({'Concentration' : 'MassPerVolume', 'Mass' : 'Mass','Mass Cleared' : 'Mass', 'Mass Deposited' : 'Mass', 'Mass Excreted' : 'Mass',
                                        'Molarity' : 'AmountPerVolume', 'Partial Pressure' : 'Pressure', 'Saturation' : ''})
  property var tissueSubQuantities : ({'Mass' : 'Mass', 'TissueConcentration' : 'MassPerVolume', 'Tissue Molarity' : 'AmountPerVolume', 'Extravascular Concentration' : 'MassPerVolume',
                                        'Extravascular Molarity' : 'AmountPerVolume', 'Extravascular Partial Pressure' : 'Pressure', 'Extravascular Saturation' : ''})
}

/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/