import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12

Page {
  id : patientWizard
  anchors.fill : parent
  property bool editMode : false
  property alias doubleValidator : doubleValidator
  property alias fractionValidator : fractionValidator
  property alias neg1To1Validator : neg1To1Validator
  property alias patientDataModel : patientDataModel 
  property alias helpDialog : helpDialog
  property alias patientGridView : patientGridView

  GridView {
    id: patientGridView
    clip : true
    model : patientDataModel
    anchors.fill : parent
    cellHeight : parent.height / 10
    cellWidth : parent.width / 2
  
    delegate : UIUnitScalarEntry {
      prefWidth : patientGridView.cellWidth * 0.9
      prefHeight : patientGridView.cellHeight * 0.95
      entry : root.displayFormat(model.name)
      unit : model.unit
      type : model.type
      entryValidator : root.assignValidator(model.type)
      onEntryUpdated : {
        root.patientData[model.name] = [value, unit]
      }
      Component.onCompleted : {
        root.onLoadConfiguration.connect(function (patient) {let valueUnitPair = root.setPatientEntry(patient[model.name]); setEntry(valueUnitPair[0], valueUnitPair[1])})
        root.onResetConfiguration.connect(resetEntry)
      }
    }
  }

  DoubleValidator {
    id : doubleValidator
    bottom : 0
    decimals : 2
  }
  DoubleValidator {
    id : fractionValidator
    bottom : 0
    top : 1.0
    decimals : 2
  }
  DoubleValidator {
    id : neg1To1Validator
    bottom : -1.0
    top : 1.0
    decimals : 2
  }

  ListModel {
    id : patientDataModel
    ListElement {name : "Name"; type : "string"}
    ListElement {name : "Gender"; unit : "gender"; type : "enum"}
    ListElement {name : "Age";  unit : "time"; type : "double" }
    ListElement {name : "Weight";  unit : "mass"; type : "double"}
    ListElement {name : "Height";  unit : "length"; type : "double"}
    ListElement {name : "BodyFatFraction";  unit : ""; type : "0To1"}
    ListElement {name : "BloodVolumeBaseline";  unit : "volume"; type : "double"}
    ListElement {name : "BloodType";  unit : "bloodType"; type : "enum"}
    ListElement {name : "DiastolicArterialPressureBaseline";  unit : "pressure"; type : "double"}
    ListElement {name : "SystolicArterialPressureBaseline";  unit : "pressure"; type : "double"}
    ListElement {name : "HeartRateMinimum";  unit : "frequency"; type : "double"}
    ListElement {name : "HeartRateMaximum";  unit : "frequency"; type : "double"}
    ListElement {name : "RespirationRateBaseline";  unit : "frequency"; type : "double"}
    ListElement {name : "AlveoliSurfaceArea"; unit : "area"; type : "double"}
    ListElement {name : "RightLungRatio"; unit : ""; type : "0To1"}
    ListElement {name : "FunctionalResidualCapacity"; unit : "volume"; type : "double"}
    ListElement {name : "ResidualVolume"; unit : "volume"; type : "double"}
    ListElement {name : "TotalLungCapacity"; unit : "volume"; type : "double"}
    ListElement {name : "SkinSurfaceArea"; unit : "area"; type : "double"}
    ListElement {name : "MaxWorkRate"; unit : "power"; type : "double"}
    ListElement {name : "PainSusceptibility"; unit : ""; type : "-1To1"}
    ListElement {name : "Hyperhidrosis"; unit : ""; type : "-1To1"}
  }

  Dialog {
    id : helpDialog
    modal : true
    closePolicy : Popup.NoAutoClose
    width : parent.width / 2
    height : parent.height / 3
    anchors.centerIn : parent
    header : Rectangle {
      id : headerBackground
      width : parent.width
      height : parent.height * 0.1
      color: "#1A5276"
      Text {
        id: headerContent
        anchors.fill : parent
        text: "Patient Setup Help"
		    font.pointSize : 10
        leftPadding : 10
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
    footer : DialogButtonBox {
      id : dialogFooter
      Button {
        text : "Close"
        DialogButtonBox.buttonRole : DialogButtonBox.RejectRole
      }
    }
    contentItem : Rectangle {
      id : mainContent
      color : "transparent"
		  anchors.left : parent.left;
		  anchors.right : parent.right;
      anchors.top : headerBackground.bottom
      anchors.bottom : dialogFooter.top
      Text {
        id : helpText
        anchors.fill : parent
        wrapMode : Text.WordWrap
        text : "--Patient name and gender are required fields.  All other fields are optional and will be set to defaults in BioGears if not assigned. 
                \n\n --Baseline inputs will be used as targets for the engine but final values may change during the stabilization process."
      }
    }
  }
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 