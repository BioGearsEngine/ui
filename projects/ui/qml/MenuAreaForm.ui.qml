import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3
import com.biogearsengine.ui.scenario 1.0

import Qt.labs.platform 1.1 as Labs
Rectangle {
  id : menuArea
  property alias wizardDialog : wizardDialog
  property alias scenarioBuilder : scenarioBuilder
  implicitHeight : 40     //Aligns with graph area tab button
  color : "#2980b9"
  border.width : 0
  border.color : "yellow"
  MenuBar {
    id: menuBar
    anchors.left : parent.left
    //Controls the appearance of the top level options (File, Tools, About)
    delegate : MenuBarItem {
      id : menuBarItem
      height : menuArea.height
      contentItem : Text {
        text : menuBarItem.text
        font.pointSize : 14
        horizontalAlignment : Text.AlignLeft
        verticalAlignment : Text.AlignVCenter
        color : "white"
      }
      background : Rectangle {
        height : menuArea.height
        color : menuBarItem.highlighted ? "#1A5276" : "#2980b9"
      }
    }
    //Menu bar background
    background : Rectangle {
      height : menuArea.height
      color : "transparent"
      anchors.fill : parent
    }
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
        text : "Save Plots"
        onTriggered : {
          let location = Labs.StandardPaths.writableLocation(Labs.StandardPaths.DocumentsLocation)
          let runName  = Qt.formatDateTime(new Date(), "yyyy-MM-dd")
          scenario.save_plots(location, runName);
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
          color : fileMenuItem.highlighted ? "white" : "black"
          font.pointSize : 12
        }
        background : Rectangle {
          color : fileMenuItem.highlighted ? "#2980b9" : "transparent"
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
          color : toolsMenuItem.highlighted ? "white" : "black"
          font.pointSize : 8
        }
        background : Rectangle {
          color : toolsMenuItem.highlighted ? "#2980b9" : "transparent"
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
                color : toolsOptionsDelegate.highlighted ? "white" : "black"
                font.pointSize : 8
              }
              background : Rectangle {
                color : toolsOptionsDelegate.highlighted ? "#2980b9" : "transparent"
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
      id : aboutMenu
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
          color : aboutMenuItem.highlighted ? "white" : "black"
          font.pointSize : 8
        }
        background : Rectangle {
          color : aboutMenuItem.highlighted ? "#2980b9" : "transparent"
        }
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