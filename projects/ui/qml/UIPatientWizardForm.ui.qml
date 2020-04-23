import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12

Page {
  id : patientWizard
  anchors.fill : parent
  property alias doubleValidator : doubleValidator
  property alias fractionValidator : fractionValidator
  property alias neg1To1Validator : neg1To1Validator
  property alias patientDataModel : patientDataModel 
  property alias helpDialog : helpDialog
  property alias patientChangeWarning : patientChangeWarning
  property alias invalidPatientWarning : invalidPatientWarning
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
      hintText : model.hint
      entryValidator : root.assignValidator(model.type)
      onEntryUpdated : {
        root.patientData[model.name] = [value, unit]
        if (entry === "Name"){
          root.patientChanged(entryField.text)
        }
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
  }
  DoubleValidator {
    id : fractionValidator
    bottom : 0
    top : 1.0
    decimals : 3
  }
  DoubleValidator {
    id : neg1To1Validator
    bottom : -1.0
    top : 1.0
    decimals : 3
  }

  ListModel {
    id : patientDataModel
    ListElement {name : "Name"; type : "string"; hint : "*Required"}
    ListElement {name : "Gender"; unit : "gender"; type : "enum"; hint : "Select option (*Required)"}
    ListElement {name : "Age";  unit : "time"; type : "double"; hint : "Enter value & select unit" }
    ListElement {name : "Weight";  unit : "mass"; type : "double"; hint : "Enter value & select unit"}
    ListElement {name : "Height";  unit : "length"; type : "double"; hint : "Enter value & select unit"}
    ListElement {name : "BodyFatFraction";  unit : ""; type : "0To1"; hint : "Enter value in range [0,1]"}
    ListElement {name : "BloodVolumeBaseline";  unit : "volume"; type : "double"; hint : "Enter value & select unit"}
    ListElement {name : "BloodType";  unit : "bloodType"; type : "enum"; hint : "Select option"}
    ListElement {name : "DiastolicArterialPressureBaseline";  unit : "pressure"; type : "double"; hint : "Enter value & select unit"}
    ListElement {name : "SystolicArterialPressureBaseline";  unit : "pressure"; type : "double"; hint : "Enter value & select unit"}
    ListElement {name : "HeartRateMinimum";  unit : "frequency"; type : "double"; hint : "Enter value & select unit"}
    ListElement {name : "HeartRateMaximum";  unit : "frequency"; type : "double"; hint : "Enter value & select unit"}
    ListElement {name : "RespirationRateBaseline";  unit : "frequency"; type : "double"; hint : "Enter value & select unit"}
    ListElement {name : "AlveoliSurfaceArea"; unit : "area"; type : "double"; hint : "Enter value & select unit"}
    ListElement {name : "RightLungRatio"; unit : ""; type : "0To1"; hint : "Enter value in range [0,1]"}
    ListElement {name : "FunctionalResidualCapacity"; unit : "volume"; type : "double"; hint : "Enter value & select unit"}
    ListElement {name : "ResidualVolume"; unit : "volume"; type : "double"; hint : "Enter value & select unit"}
    ListElement {name : "TotalLungCapacity"; unit : "volume"; type : "double"; hint : "Enter value & select unit"}
    ListElement {name : "SkinSurfaceArea"; unit : "area"; type : "double"; hint : "Enter value & select unit"}
    ListElement {name : "MaxWorkRate"; unit : "power"; type : "double"; hint : "Enter value & select unit" }
    ListElement {name : "PainSusceptibility"; unit : ""; type : "-1To1"; hint : "Enter value in range [-1,1]"}
    ListElement {name : "Hyperhidrosis"; unit : ""; type : "-1To1"; hint : "Enter value in range [-1,1]"}
  }

  Dialog {
    id : helpDialog
    modal : true
    closePolicy : Popup.NoAutoClose
    width : parent.width / 2
    height : parent.height / 3
    anchors.centerIn : parent
    header : Rectangle {
      id : helpHeader
      width : parent.width
      height : parent.height * 0.1
      color: "#1A5276"
      Text {
        id: helpHeaderText
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
      id : helpFooter
      Button {
        text : "Ok"
        DialogButtonBox.buttonRole : DialogButtonBox.AcceptRole
      }
    }
    contentItem : Rectangle {
      id : helpMainContent
      color : "transparent"
		  anchors.left : parent.left;
		  anchors.right : parent.right;
      anchors.top : helpHeader.bottom
      anchors.bottom : helpFooter.top
      Text {
        id : helpText
        anchors.fill : parent
        wrapMode : Text.WordWrap
        text : "--Patient name and gender are required fields.  All other fields are optional and will be set to defaults in BioGears if not assigned. 
                \n\n --Baseline inputs will be used as targets for the engine but final values may change during the stabilization process."
      }
    }
  }

  Dialog {
    id : patientChangeWarning
    modal : true
    closePolicy : Popup.NoAutoClose
    width : parent.width / 2
    height : parent.height / 4
    anchors.centerIn : parent
    header : Rectangle {
      id : patientChangeHeader
      width : parent.width
      height : parent.height * 0.15
      color: "#1A5276"
      Text {
        id: patientChangeHeaderText
        anchors.fill : parent
        text: "Warning"
		    font.pointSize : 10
        leftPadding : 10
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
    footer : DialogButtonBox {
      id : patientChangeFooter
      Button {
        text : "Ok"
        DialogButtonBox.buttonRole : DialogButtonBox.AcceptRole
      }
    }
    contentItem : Rectangle {
      id : patientChangeMainContent
      color : "transparent"
		  anchors.left : parent.left;
		  anchors.right : parent.right;
      anchors.top : patientChangeHeader.bottom
      anchors.bottom : patientChangeFooter.top
      Text {
        id : patientChangeText
        anchors.fill : parent
        wrapMode : Text.WordWrap
        text : "Changing the patient name will change the file name under which data will be saved." 
      }
    }
    onAccepted : {
      close();
    }
  }

  Dialog {
    id : invalidPatientWarning
    modal : true
    closePolicy : Popup.NoAutoClose
    width : parent.width / 2
    height : parent.height / 6
    anchors.centerIn : parent
    header : Rectangle {
      id : invalidPatientHeader
      width : parent.width
      height : parent.height * 0.2
      color: "#1A5276"
      Text {
        id: invalidPatientHeaderText
        anchors.fill : parent
        text: "Warning: Invalid configuration"
		    font.pointSize : 10
        leftPadding : 10
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
    footer : DialogButtonBox {
      id : invalidPatientFooter
      Button {
        text : "Ok"
        DialogButtonBox.buttonRole : DialogButtonBox.AcceptRole
      }
    }
    contentItem : Rectangle {
      id : invalidPatientMainContent
      color : "transparent"
		  anchors.left : parent.left;
		  anchors.right : parent.right;
      anchors.top : invalidPatientHeader.bottom
      anchors.bottom : invalidPatientFooter.top
      Text {
        id : invalidPatientText
        anchors.fill : parent
        wrapMode : Text.WordWrap
        text : "Name and Gender must be defined to save patient file." 
      }
    }
    onAccepted : {
      close();
    }
  }
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 