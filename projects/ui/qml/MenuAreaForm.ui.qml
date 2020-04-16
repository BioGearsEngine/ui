import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick 2.12
import QtQuick.Dialogs 1.3

Item {
  property alias saveAsDialog : saveAsDialog
  property alias openDialog : openDialog
  property alias wizardDialog : wizardDialog
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
          openDialog.open();
        }
      }
      Action {
        text : "Save State"
        onTriggered : {
          root.exportData(6)
        }
      }
      Action {
        text : "Save State As"
        onTriggered : {
          saveAsDialog.open();
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
          property int toolIndex : index
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
                //toolIndex = Patient/Environment/..., currentIndex = New/Export/Edit, 
                root.parseToolsSelection(toolsDelegate.toolIndex, currentIndex)
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
    ListElement { name : "Nutrient"}
    ListElement { name : "ECG"}
  }

  ListModel {
    //Elements for all options within each tools submenu
    id: toolsOptionsListModel
    ListElement { option : "New"}
    ListElement { option : "Export"}
    ListElement { option : "Edit"}
  }

  FileDialog {
    id : saveAsDialog
    title : "Save state as..."
    visible : false
    folder : "file://states"
    nameFilters : ["(*.xml)", "All files (*)"]
    selectMultiple : false
    selectExisting: false
  }
  FileDialog {
    id : openDialog
    title : "Open state file"
    visible : false
    folder : "file://states" //This url identifies the correct folder but logs warnings to the debug console from QWindowsNativeFileDialogBase.  This seems to be a Qml bug
    nameFilters : ["states (*.xml)", "All files (*)"]
    selectMultiple : false
    selectExisting : true
  }

  WizardDialog {
    id : wizardDialog
    visible : false
  }
}