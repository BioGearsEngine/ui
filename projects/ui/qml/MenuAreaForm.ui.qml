import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3
import com.biogearsengine.ui.scenario 1.0

Item {
  id : menuArea
  property alias wizardDialog : wizardDialog
  property alias scenarioBuilder : scenarioBuilder
  width : menuBar.width       //Visible area should be the size of the menu bar.  Item wrapper is to hold non-visible
  height : menuBar.height         //components like ListModel and popups like FileDialog and ObjectBuilder

  MenuBar {
    id: menuBar
   //----------------File Menu-------------------
    Menu {
      id : fileMenu
      title : "File"
      Action {
        text : "Load State"
        onTriggered : {
          scenario.load_state();
        }
      }
      Action {
        text : "Save State"
        onTriggered : {
          let saveAs = false
          scenario.export_state(saveAs)
        }
      }
      Action {
        text : "Save State As"
        onTriggered : {
          let saveAs = true
          scenario.export_state(saveAs);
        }
      }
      Action {
        text : "Launch Scenario Editor"
        onTriggered : {
          scenarioBuilder.showNormal()
        }
      }

      delegate : MenuItem {
        id : fileMenuItem
        contentItem : Text {
          text : fileMenuItem.text
          font.pointSize : 8
        }
        background : Rectangle {
          color : "transparent"
          border.color : "#1A5276"
          border.width : fileMenuItem.highlighted ? 2 : 0
        }
      }
    }
    //----------------Tools Menu-------------------
    Menu {
      id : toolsMenu
      title : "Tools"
      delegate : MenuItem {
        //Controls the appearance of items in tools menu --> actual definition of submenus occurs in instantiator
        id : toolsMenuItem
        contentItem : Text {
          text : toolsMenuItem.text
          font.pointSize : 8
        }
        background : Rectangle {
          color : "transparent"
          border.color : "#1A5276"
          border.width : toolsMenuItem.highlighted ? 2 : 0
        }
      }
      Instantiator {
        //Create a menu within tools for object building (patient, substance, etc)
        id : toolMenuInstantiator
        model : toolsListModel
        delegate : Menu {
          id : toolsDelegate
          title : name  //role from toolsListModel
          Repeater {
            //Create options "Edit", "New", and "Export" for submenu
            id : toolOptionMenu
            model : toolsOptionsListModel
            delegate : MenuItem {
              id : toolsOptionsDelegate
              text : option  //role from toolsOptionListModel
              contentItem : Text {
                text : toolsOptionsDelegate.text
                font.pointSize : 8
              }
              background : Rectangle {
                color : "transparent"
                border.color : "#1A5276"
                border.width : toolsOptionsDelegate.highlighted ? 2 : 0
              }
              onTriggered : {
                root.parseToolsSelection(toolsDelegate.title, option)
              }
            }
          }    
        }
        onObjectAdded : {
          toolsMenu.addMenu(object)
        }
        onObjectRemoved : {
          toolsMenu.removeMenu(object)
        }
      }
     }
    //----------------About Menu-------------------
    Menu {
      id : helpMenu
      title : "About"
      Action {
        text : "Help"
      }
      Action {
        text : "Info"
      }
      delegate : MenuItem {
        //Controls the appearance of items in tools menu --> actual definition of submenus occurs in instantiator
        id : aboutMenuItem
        contentItem : Text {
          text : aboutMenuItem.text
          font.pointSize : 8
        }
        background : Rectangle {
          color : "transparent"
          border.color : "#1A5276"
          border.width : aboutMenuItem.highlighted ? 2 : 0
        }
      }
    }
    //Controls the appearance of the top level options (File, Tools, About)
    delegate : MenuBarItem {
      id : menuBarItem
      contentItem : Text {
        text : menuBarItem.text
        font.pointSize : 8
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
  //--------Helper components-------------------
  ListModel {
    //Elements for all options within tools
    id: toolsListModel
    ListElement { name : "Patient"}
    ListElement { name : "Environment"}
    ListElement { name : "Substance"}
    ListElement { name : "Compound"}
    ListElement { name : "Nutrition"}
    ListElement { name : "ECG"}
  }

  ListModel {
    //Elements for all options within each tools submenu
    id: toolsOptionsListModel
    ListElement { option : "New"}
    ListElement { option : "Export"}
    ListElement { option : "Edit"}
  }

  //Dialog that handles creation/editing of subtances/nutrition/compounds/environment/patient data types
  WizardDialog {
    id : wizardDialog
    visible : false
    height : menuArea.parent.height
    width : menuArea.parent.width / 2
    x : menuArea.parent.width / 4
  }
  //Dialog that handles creation/editing of scenario
  UIScenarioBuilder {
    id : scenarioBuilder
    visible : false
    height : menuArea.parent.height
    width : menuArea.parent.width
    bg_scenario : root.parent.scenario    //grab the scenario definition from main_form (parent of menuArea)
  }
}