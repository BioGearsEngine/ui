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

  property alias patientBox: patientBox
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
  property alias respritoryRate : physiology.respritoryRate
  property alias oxygenSaturation : physiology.oxygenSaturation
  property alias condition : physiology.condition

  property alias playback : playback_controls
  property alias drawerToggle : drawerToggle
  property alias actionSwitchView : actionSwitchView
  property alias actionMessage : actionMessage

  Row {
    height: 10
    Layout.fillWidth: true
  }

  PatientBox {
    id: patientBox
    Layout.preferredWidth : root.width
    elementRatio : 0.4
    label.text: "Patient"
    label.font.pointSize : 12
    label.verticalAlignment : Text.AlignVCenter
    label.horizontalAlignment : Text.AlignHCenter
    Layout.alignment: Qt.AlignHCenter
  }

  RowLayout {
    id: configuration_row1
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter
      UITextInputForm {
        id: age
        name: "Age:"
        value: "21"
        Layout.alignment: Qt.AlignHCenter
      }
      UITextInputForm {
        id: gender
        name: "Gender:"
        value: "Female"
        Layout.alignment: Qt.AlignHCenter
      }
      UITextInputForm {
        id: fat_pct
        name: "Fat%:"
        value: "0.0%"
        Layout.alignment: Qt.AlignHCenter
      }
      UITextInputForm {
        id: core_temp
        name: "Temp:"
        value: "100.0"
        Layout.alignment: Qt.AlignHCenter
      }
  }
  RowLayout {
    id:configuration_row2
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter
    UITextInputForm {
      id: height_cm
      name: "Height:"
      value: "160"
      Layout.alignment: Qt.AlignHCenter
    }
    UITextInputForm {
      id: weight
      name: "Weight:"
      value: "Male"
      Layout.alignment: Qt.AlignHCenter
    }
    UITextInputForm {
      id: bodySurfaceArea
      name: "BSA:"
      value: "1.55"
      Layout.alignment: Qt.AlignHCenter
    }
    UITextInputForm {
      id: bodyMassIndex
      name: "BMI:"
      value: "36.2"
      Layout.alignment: Qt.AlignHCenter
    }
  }

  UIControlPhysiology {
    id: physiology
    Layout.fillWidth: true
    Layout.preferredWidth: parent.width
  }

  UIPlaybackForm {
    id: playback_controls
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    Layout.fillWidth: true
  }

  Button {
    id : drawerToggle
    contentItem : Text {
      id : drawerText
      text : 'Add Action'
      font.pointSize : 12
      color : 'white'
      horizontalAlignment : Text.AlignHCenter
      verticalAlignment : Text.AlignVCenter
    }
    background : Rectangle {
      anchors.fill : parent
      color : '#1A5276'
      border.color : '#1A5276'
      border.width : 2
    }
    Layout.preferredWidth: root.width
    Layout.alignment: Qt.AlignHCenter
  }

  Item {
    id : actionButtonWrapper
    Layout.preferredWidth : root.width
    Layout.preferredHeight : 400
    z : 2

    ListView {
      id : actionSwitchView
      clip: true
      anchors.fill : parent
      focus : true
      model : actionSwitchModel  //Defined in Controls.qml
    }

    Rectangle {
      id : actionMessage
      color : "#1A5276"
      height : actionButtonWrapper.width / 5
      width : actionButtonWrapper.height / 2
      radius : 10
      visible : false
      property string actionText : ""
      Text {
        width : parent.width
        height : parent.height
        text: parent.actionText
        color : "white"
        anchors.fill: parent
        horizontalAlignment : Text.AlignLeft
        verticalAlignment : Text.AlignVCenter
        elide: Text.ElideRight
        font.pointSize : 8
        wrapMode : Text.Wrap
      }
    }
  }
  }

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/