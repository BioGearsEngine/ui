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
  property alias patientMenuButtonText: patientText.text
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

  Row {
    height: 10
    Layout.fillWidth: true
  }

  ListModel {
    id : patientMenuListModel
  }
  Button {
    id: patientMenuButton
    Layout.preferredWidth : root.width
    flat: true
    highlighted: false
    Text {
      id : patientText
      anchors.fill : parent
      text : "Select Patient" // If you actually see this then something is very wrong
      font.capitalization : Font.MixedCase
      fontSizeMode : Text.Fit
      horizontalAlignment : Text.AlignHCenter
      verticalAlignment : Text.AlignVCenter
    }
    //display : AbstractButton.TextBesideIcon
    //icon.source: "qrc:/icons/menu.png"
    //icon.color: "transparent"
    Menu {
      id : patientMenu
      x : -200
      y : 50
      function loadState(fileName){
        biogears_scenario.restart(fileName)
      }
      function updateText(fileName){
        var split_prop = fileName.split("@")
        patientText.text = "Patient: " + split_prop[0] + "@" + split_prop[1].split(".")[0]   
      }
      closePolicy : Popup.CloseOnEscape | Popup.CloseOnReleaseOutside
      Instantiator {
        id : menuItemInstance
        model : patientMenuListModel
        delegate : Menu {
          id : patientSubMenu
          title : patientName
          property int delegateIndex : index
          property string patient : patientName
          Repeater {
            id : subMenuInstance
            model : patientMenuListModel.get(patientSubMenu.delegateIndex).props
            delegate : MenuItem {
              Button { 
                anchors.fill : parent
                flat : true
                highlighted : false
                text : propName
                onClicked : {
                  patientMenu.close()
                  if (!biogears_scenario.isRunning || biogears_scenario.isPaused){ // This should be redundant with the check to open the Menu, but I'm including it to be safe
                    console.log(patient + " : " + text)
                    patientMenu.loadState(propName)
                    patientMenu.updateText(propName)
                  }          
                }
              }
            }
          }
        }
        onObjectAdded : {
          patientMenu.addMenu(object)  
        }
        onObjectRemoved : {
          patientMenu.removeMenu(object)
        }
      }    
    }
    onClicked: {
      if (!biogears_scenario.isRunning || biogears_scenario.isPaused) {
        if (patientMenu.visible) {
          patientMenu.close()
        } else {
          patientMenu.open()
        }
      } 
    }
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
    id : openDrawerButton
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
  }
  Component.onCompleted: {
    patientMenu.loadState("DefaultMale@0s.xml")
    patientText.text = "Patient: DefaultMale@0s"
    var list = biogears_scenario.get_nested_patient_state_list();
    var nlist = []
    for (var i = 0;i < list.length;++i) {
      var split_files = list[i].split(",")
      var patient_name = split_files.shift()
      var split_objects = []
      for (var k = 0;k < split_files.length;++k) {
        split_objects.push({"propName" : split_files[k]})
      }
      var menu_entry = {"patientName" : patient_name, "props" : split_objects}
      patientMenuListModel.append(menu_entry)
    }
  }
  }
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/