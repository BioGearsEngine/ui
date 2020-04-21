import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick 2.12
import QtQuick.Dialogs 1.3


MenuBar {
  id: menuBar
  property alias saveAsDialog : saveAsDialog
  property alias openDialog : openDialog
  
 Menu {
    id : fileMenu
    title : "File"
    Menu {
      id : newMenu
      title: "New"
      Action {
        text : "Patient"
      }
      Action {
        text : "Environment"
      }
      delegate : MenuItem {
      id : newMenuItem
      contentItem : Text {
        text : newMenuItem.text
        font.pointSize : 10
      }
      background : Rectangle {
        color : "transparent"
        border.color : "#1A5276"
        border.width : newMenuItem.highlighted ? 2 : 0
      }
    }
    }
    Action {
      text : "Save State"
      onTriggered : {
        root.exportData(0)
      }
    }
    Action {
      text : "Save State As"
      onTriggered : {
        saveAsDialog.open();
      }
    }
    Action {
      text : "Open State"
      onTriggered : {
        openDialog.open();
      }
    }
    delegate : MenuItem {
      id : fileMenuItem
      contentItem : Text {
        text : fileMenuItem.text
        font.pointSize : 10
      }
      background : Rectangle {
        color : "transparent"
        border.color : "#1A5276"
        border.width : fileMenuItem.highlighted ? 2 : 0
      }
    }
  }
  Menu {
    id : exportMenu
    title : "Export"
    Action {
      text : "Patient"
      onTriggered : {
        root.exportData(1)
      }
    }
    Action {
      text : "State"
      onTriggered : {
        root.exportData(0)
      }
    }
    Action {
      text : "Environment"
      onTriggered : {
        root.exportData(2)
      }
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
}