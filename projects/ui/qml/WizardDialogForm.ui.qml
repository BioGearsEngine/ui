import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12

Item {
  id : dialogContainer
  property alias mainDialog : mainDialog
  property alias helpDialog : helpDialog
  property alias nameWarningDialog : nameWarningDialog
  property alias invalidConfigDialog : invalidConfigDialog
  Dialog {
    id: mainDialog
    width : dialogContainer.width
    height : dialogContainer.height
    //Base properties
    property alias saveButton : saveButton
    modal : true
    title : "Wizard"
    closePolicy : Popup.NoAutoClose
    //Header
    header : Rectangle {
      id : headerBackground
      width : parent.width
      height : parent.height * 0.075
      color: "#1A5276"
      border.color: "white"
      border.width : 5
      Text {
        id: headerContent
        anchors.fill : parent
        text: mainDialog.title
		    font.pointSize : 12
        leftPadding : 10
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
    //Add standard buttons to footer
    footer : DialogButtonBox {
      id : dialogButtons
      Button {
        id: saveButton
        text : "Save"
        hoverEnabled : true
        background : Rectangle {
          radius : 0
          anchors.fill : parent
          color : saveButton.hovered ? "whitesmoke" : "white"
        }
      }
      standardButtons : DialogButtonBox.Help | DialogButtonBox.Reset | DialogButtonBox.Cancel
    }
      //Main content
    contentItem : Rectangle {
      id : mainContent
      color : "transparent"
		  anchors.left : mainDialog.left;
		  anchors.right : mainDialog.right;
      anchors.top : mainDialog.header.bottom
      anchors.bottom : mainDialog.footer.top
    }
  }
  Dialog {
    id : helpDialog
    modal : true
    closePolicy : Popup.NoAutoClose
    width : parent.width / 2
    height : parent.height / 3
    anchors.centerIn : parent
    property string helpText : ""
    header : Rectangle {
      id : helpHeader
      width : parent.width
      height : parent.height * 0.1
      color: "#1A5276"
      Text {
        id: helpHeaderText
        anchors.fill : parent
        text: "Help"
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
        id : helpMainText
        anchors.fill : parent
        wrapMode : Text.WordWrap
        text : helpDialog.helpText
      }
    }
  }

  Dialog {
    id : nameWarningDialog
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
        text : "Changing the Name will change the file name under which data will be saved." 
      }
    }
    onAccepted : {
      close();
    }
  }

  Dialog {
    id : invalidConfigDialog
    modal : true
    closePolicy : Popup.NoAutoClose
    width : parent.width / 2
    height : parent.height / 5
    anchors.centerIn : parent
    property string warningText : ""
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
        text : invalidConfigDialog.warningText
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
 