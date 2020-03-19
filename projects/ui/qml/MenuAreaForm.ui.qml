import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick 2.12

import com.biogearsengine.ui.scenario 1.0

MenuBar {
  id: menuBar
 Menu {
    id : fileMenu
    title : "File"
    Action {
      text : "Save"
      onTriggered : {
        let simTime = Math.ceil(scenario.get_simulation_time())
        let patient = scenario.patient_name()
        let fileName =  patient + "@" + simTime + "s.xml"
        scenario.save_state(fileName)
      }
    }
    Action {
      text : "Save As"
    }
    Action {
      text : "Open"
    }
    delegate : MenuItem {
      id : menuItem
      contentItem : Text {
        text : menuItem.text
        font.pointSize : 10
      }
      background : Rectangle {
        color : "transparent"
        border.color : "#1A5276"
        border.width : menuItem.highlighted ? 2 : 0
      }
    }
  }
  Menu {
    id : exportMenu
    title : "Export"
    Action {
      text : "Patient"
    }
    Action {
      text : "State"
      onTriggered : {
        let simTime = scenario.get_simulation_time()
        let patient = scenario.patient_name()
        let fileName =  patient + "@" + simTime + "s.xml"
        scenario.save_state(fileName)
      }
    }
    Action {
      text : "Environment"
    }
    Action {
      text : "Scenario"
    }
    delegate : MenuItem {
      id : menuItem
      contentItem : Text {
        text : menuItem.text
        font.pointSize : 10
      }
      background : Rectangle {
        color : "transparent"
        border.color : "#1A5276"
        border.width : menuItem.highlighted ? 2 : 0
      }
    }
  }
  Menu {
    id : helpMenu
    title : "Help"
  }
  delegate : MenuBarItem {
    id : menuBarItem
    contentItem : Text {
      text : menuBarItem.text
      font.pointSize : 12
      horizontalAlignment : Text.AlignLeft
      verticalAlignment : Text.AlignVCenter
      color : menuBarItem.highlighted ? "white" : "black"
    }
    background : Rectangle {
      anchors.fill : parent 
      color : menuBarItem.highlighted ? "#1A5276" : "transparent"
    }
  }
  background : Rectangle {
    color : "transparent"
    anchors.fill : parent
    Rectangle {
      color : "#1A5276"
      width : parent.width
      height : 1
      anchors.bottom : parent.bottom
    }
  }
}