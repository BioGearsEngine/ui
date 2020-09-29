import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick 2.12
import QtQuick.Controls.Material 2.12
import QtQml.Models 2.2

import com.biogearsengine.ui.scenario 1.0

ColumnLayout {
  id: root
  spacing: 5
  Layout.preferredHeight: implicitHeight
  Layout.preferredWidth: implicitWidth
  z : 1  //Setting to higher than graph area so that action messages will not be hidden behind plots

  //property alias patientBox: patientBox
  property alias patientMenu: patientMenu
  property alias age_yr: age
  property alias gender: gender
  property alias fat_pct: fat_pct
  property alias core_temp_c: core_temp
  property alias height_cm: height_cm
  property alias weight_kg: weight
  property alias bodySufaceArea: bodySurfaceArea
  property alias bodyMassIndex: bodyMassIndex

  property alias heartRate : physiology.heartRate
  property alias systolicBloodPressure : physiology.systolicBloodPressure
  property alias dystolicBloodPressure : physiology.dystolicBloodPressure
  property alias respiratoryRate : physiology.respiratoryRate
  property alias oxygenSaturation : physiology.oxygenSaturation
  property alias condition : physiology.condition

  property alias playback : playback_controls
  property alias openDrawerButton : openDrawerButton
  property alias actionSwitchView : actionSwitchView


  PatientMenu {
    id : patientMenu
    Layout.preferredWidth : root.width
  }
  RowLayout {
    id: configuration_row1
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter
    UITextInputForm {
      id: age
      name.text: "Age:"
      value.text: "21"
      Layout.alignment: Qt.AlignHCenter
    }
    UITextInputForm {
      id: gender
      name.text: "Gender:"
      value.text: "Female"
      Layout.alignment: Qt.AlignHCenter
    }
    UITextInputForm {
      id: fat_pct
      name.text: "Fat%:"
      value.text: "0.0%"
      Layout.alignment: Qt.AlignHCenter
    }
    UITextInputForm {
      id: core_temp
      name.text: "Temp:"
      value.text: "100.0"
      Layout.alignment: Qt.AlignHCenter
    }
  }
  RowLayout {
    id:configuration_row2
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter
    UITextInputForm {
      id: height_cm
      name.text: "Height:"
      value.text: "160"
      Layout.alignment: Qt.AlignHCenter
    }
    UITextInputForm {
      id: weight
      name.text: "Weight:"
      value.text: "Male"
      Layout.alignment: Qt.AlignHCenter
    }
    UITextInputForm {
      id: bodySurfaceArea
      name.text: "BSA:"
      value.text: "1.55"
      Layout.alignment: Qt.AlignHCenter
    }
    UITextInputForm {
      id: bodyMassIndex
      name.text: "BMI:"
      value.text: "36.2"
      Layout.alignment: Qt.AlignHCenter
    }
  }
  UIControlPhysiology {
    id: physiology
    Layout.topMargin : 10
    Layout.fillWidth: true
    Layout.alignment : Qt.AlignHCenter
  }
  UIPlaybackForm {
    id: playback_controls
    Layout.topMargin : 10
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    Layout.fillWidth: true
  }
  UIBioGearsButtonForm {
    id : openDrawerButton
    contentItem : Text {
      id : drawerText
      text : 'Add Action'
      font.pointSize : 12
      color : 'white'
      horizontalAlignment : Text.AlignHCenter
      verticalAlignment : Text.AlignVCenter
    }
    Layout.preferredWidth: root.width
    Layout.alignment: Qt.AlignHCenter
    implicitHeight : drawerText.implicitHeight * 1.5
  }

  Rectangle {
    id : actionButtonWrapper
    Layout.preferredWidth : root.width
    color : "transparent"
    border.width : 0
    //This item needs to exactly fill remaining space, or else scroll feature of ListView will not have correct scoll boundaries
    //Controls item height is implicit (depends entirely on objects that fill it), so we cannot bind to it without creating a loop.
    //Since parent of Controls is main window, root.parent.height gets us an absolute height from which we can subtract other item
    //heights to get remaining space for action list view.  Note that we need to subtract the height of the file menu bar, which sits
    //atop the controls area in the main window.
    implicitHeight : root.parent.height - (patientMenu.height + configuration_row1.height + configuration_row2.height + physiology.height + playback_controls.height + openDrawerButton.height + 6 * root.spacing + root.parent.menuArea.height)
    z : 2
    ListView {
      id : actionSwitchView
      clip: true
      anchors.fill : parent
      focus : true
      spacing : 2
      model : actionSwitchModel  //Defined in Controls.qml
    }
  }
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/