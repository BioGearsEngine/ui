import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import QtQml.Models 2.12
import Qt.labs.folderlistmodel 2.12
import QtQuick.Dialogs 1.3
import com.biogearsengine.ui.scenario 1.0

Window {
  id : scenarioBuilder
  title : "Scenario Builder"
  property alias actionDelegate : actionListDelegate
  property alias actionView : actionListView
  property alias scenarioView : scenarioListView
  property alias warningMessage : warningMessage
  property string scenarioInput : "DefaultTemplateMale"
  property string scenarioName : "TestScenario"
  property bool isPatientFile : true     //false ---> input = engine state file
  property Scenario bg_scenario
  //Non-visual elements defined in UIScenarioBuilder.qml
  property ListModel actionModel
  property ActionModel builderModel
  property EventModel eventModel
  property FolderListModel patientModel
  property FolderListModel stateModel
  //Components used to create time-based object in builder model
  property Component timeGapComponent : timeGapComponent
  property Component timeStartComponent : timeStartComponent
  property Component timeEndComponent : timeEndComponent

  TabBar {
    id : tabBar
    width : parent.width
    TabButton {
      text : "Set Actions"
      font.pointSize : 16
    }
    TabButton {
      text : "Set Data Requests"
      font.pointSize : 16
    }
  }

  StackLayout {
    id: builderStack
    width : parent.width
    height : parent.height - tabBar.height - optionArea.height
    anchors.top : tabBar.bottom
    anchors.bottom : optionArea.top
    currentIndex : tabBar.currentIndex
    //-----First Tab--------------------
    GridLayout {
      id : actionLayout
      Layout.preferredWidth : parent.width
      Layout.preferredHeight : parent.height
      rows : 3
      columns : 2
      rowSpacing : 0
      Rectangle {
        id : actionLabel
        color : "transparent"
        Layout.row : 0
        Layout.column : 0
        Layout.preferredHeight : parent.height * 0.05
        Layout.preferredWidth : parent.width * 0.2
        Layout.alignment : Qt.AlignBottom
        Label {
          id : actionLabelText
          anchors.bottom : parent.bottom
          anchors.horizontalCenter : parent.horizontalCenter
          text : "Actions"
          verticalAlignment : Text.AlignBottom
          horizontalAlignment : Text.AlignHCenter
          font.pointSize : 14
        }  
      }
      Rectangle {
        id : scenarioLabel
        color : "transparent"
        Layout.row : 0
        Layout.column : 1
        Layout.preferredHeight : parent.height * 0.05
        Layout.preferredWidth : parent.width * 0.8
        Layout.alignment : Qt.AlignBottom
        Label {
          id : scenarioLabelText
          anchors.bottom : parent.bottom
          anchors.horizontalCenter : parent.horizontalCenter
          text : "Timeline"
          verticalAlignment : Text.AlignBottom
          horizontalAlignment : Text.AlignHCenter
          font.pointSize : 14
        }  
      }
      Rectangle {
        Layout.row : 1
        Layout.column : 0
        Layout.preferredHeight : parent.height * 0.875
        Layout.preferredWidth : parent.width * 0.2
        color : "transparent"
        border.color : "grey"
        border.width : 2
        ListView {
          id : actionListView
          property double scrollWidth : actionScroll.width
          anchors.fill : parent
          model : actionModel
          delegate : actionDelegate
          currentIndex : -1
          clip : true
          ScrollBar.vertical : ScrollBar {
            id : actionScroll
            policy : ScrollBar.AlwaysOn
          }
          section {
            property : "section"
            delegate : Rectangle {
              color : "navy"
              width : parent.width - actionListView.scrollWidth
              height : childrenRect.height
              Text {
                anchors.horizontalCenter : parent.horizontalCenter
                text : section
                font.pixelSize : 20
                color : "white"
              }
            }
          }
        }
      }
      Rectangle {
        id : scenario
        color : 'transparent'
        Layout.preferredHeight : parent.height * 0.875
        Layout.preferredWidth : parent.width * 0.8
        border.width : 1
        Layout.row : 1
        Layout.column : 1
        ListView {
          id : scenarioListView
          property double scrollWidth : scenarioScroll.width
          anchors.top : parent.top
          anchors.topMargin : 15
          anchors.bottom : parent.bottom
          width : parent.width
          clip : true
          currentIndex : -1
          spacing : 5
          model : builderModel
          ScrollBar.vertical : ScrollBar {
            id : scenarioScroll
            policy : ScrollBar.AlwaysOn
          }
        }
      }
      Item {
        id : addButtonArea
        Layout.preferredWidth : parent.width * 0.2
        Layout.preferredHeight : parent.height * 0.075
        Layout.row : 2
        Layout.column : 0
        Button {
          id : addButton
          width : parent.width / 2
          height : parent.height
          anchors.centerIn : parent
          text : "Add"
          onClicked : {
            if (actionView.currentIndex!==-1){
              builderModel.createAction(actionModel.get(actionView.currentIndex))
            }
            actionView.currentIndex = -1
          }
        }
      }

      RowLayout {
        id : scenarioButtonArea
        Layout.preferredWidth : parent.width * 0.8
        Layout.preferredHeight : parent.height * 0.075
        Layout.row : 2
        Layout.column : 1
        Button {
          id : removeButton
          Layout.alignment : Qt.AlignHCenter
          Layout.preferredHeight : parent.height
          Layout.preferredWidth : parent.width / 5
          text : "Remove Action"
          onClicked : {
            if (scenarioView.currentIndex !== -1){
              builderModel.remove(scenarioView.currentIndex, 2)   //Remove two items to get time block associated with action
              builderModel.updateTimeComponents()
              builderModel.refreshScenarioLength()
              scenarioView.currentIndex = -1
            }
          }
        }
        Item {
          //Wrapping input in an item to break a binding loop (width of text input subcomponents depend on parent width, which depends on width of input subcomponents...)
          id : scenarioNameWrapper
          Layout.preferredWidth : parent.width / 4
          Layout.preferredHeight : parent.height
          Layout.alignment : Qt.AlignHCenter
          UITextInputForm {
            id : scenarioName
            anchors.fill : parent
            name.text : "Scenario Name:  "
            name.font.pointSize : 14
            value.font.pixelSize : 18
          }
        }
        Button {
          id : setPatientButton
          Layout.alignment : Qt.AlignHCenter
          Layout.preferredHeight : parent.height
          Layout.preferredWidth : parent.width / 5
          text : "Set Input "
          onClicked : {
            patientMenu.open()
          }
          Menu {
            id : patientMenu
            closePolicy : Popup.CloseOnEscape | Popup.CloseOnReleaseOutside
            Menu {
              title : "Patient"
              Repeater {
                id : patientSubMenu
                model : root.patientModel.status == FolderListModel.Ready ? root.patientModel : null
                delegate : MenuItem {
                  Button {
                    text : model.fileBaseName
                    flat : true
                    highlighted : false
                    onClicked : {
                      root.scenarioInput = text
                      root.isPatientFile = true
                      patientMenu.close()
                    }
                  }
                }
              }
            }
            Menu {
              title : "Engine State"
              Repeater {
                id : stateSubMenu
                model : root.stateModel.status == FolderListModel.Ready ? root.patientModel : null
                delegate : MenuItem {
                  Button {
                    text : model.fileBaseName
                    anchors.fill : parent
                    flat : true
                    highlighted : false
                    onClicked : {
                      root.scenarioInput = text
                      root.isPatientFile = false
                      patientMenu.close()
                    }
                  }
                }
              }
            }
          }
        }
      }
    } //end first tab
    //------Second Tab-----------
    Rectangle {
      color : "blue"
      Layout.fillWidth : true
      Layout.fillHeight : true
      Layout.preferredHeight : parent.height
      Layout.preferredWidth : parent.width
    }//end second tab
  } //end stack layout
  Rectangle {
    id : optionArea
    color : 'transparent'
    border.color : 'green'
    height : parent.height * 0.075
    width : parent.width
    anchors.bottom : parent.bottom
    border.width : 1
    Button {
      id : saveScenario
      text : "Save"
      anchors.centerIn : parent
      height : parent.height
      width : parent.width / 3
      onClicked : {
        builderModel.setActionQueue()
        let prefix = isPatientFile ? "patients/" : "states/"
        let initialParameters = prefix + scenarioInput
        console.log(initialParameters)
        bg_scenario.create_scenario(root.scenarioName, isPatientFile, initialParameters + ".xml", eventModel);
        root.close()
      }
    }
  }
 MessageDialog {
  id : warningMessage
  icon : StandardIcon.Critical
  standardButtons : StandardButton.Ok
  width : parent.width / 4
  height : parent.height / 5
  text : ""
 }
 //---Components loaded during runtime----------------
 //View delegate for list of actions
  Component {
    id : actionListDelegate
    Rectangle {
      id : delegateWrapper
      height : delegateText.height * 1.4
      width : actionView.width - actionView.scrollWidth //aligns with ListView preferred width
      Layout.alignment : Qt.AlignLeft
      color : ListView.isCurrentItem ? "lightskyblue" : "transparent"
      border.color: "lightskyblue"
      border.width : ListView.isCurrentItem ? 2 : 0
      Text {
          id: delegateText
          anchors.verticalCenter : parent.verticalCenter
          leftPadding: 5
          text : name
          font.pointSize : 12
          Layout.alignment : Qt.AlignVCenter
      }
      MouseArea {
        anchors.fill : parent
        onClicked : {
            actionListView.currentIndex = index;
        }
      }
    }
  }
  //Component used to create time blocks between each action
  Component {
    id : timeGapComponent
    Column {
      id : timeColumn
      property double blockTime_s : 0
      width : builderModel.actionSwitchView.width - builderModel.actionSwitchView.scrollWidth
      height : 60
      spacing : 0
      states : [
        State {
          name : "collapsed"
          PropertyChanges {target : timeColumn; height : 0; visible : false}
          when : blockTime_s == 0
        }
        ,State {
          name : "expanded"
          PropertyChanges {target : timeColumn; height : 60; visible : true}
          when : blockTime_s > 0
        }     
      ]
      Rectangle {
        color : "black"
        width : 2
        height : parent.height/3
        anchors.horizontalCenter : parent.horizontalCenter
      }
      Text {
        id : timeText
        font.pointSize : 12
        anchors.horizontalCenter : parent.horizontalCenter
        text : root.seconds_to_clock_time(parent.blockTime_s)
      }
      Rectangle {
        color : "black"
        width : 2
        height : parent.height/3
        anchors.horizontalCenter : parent.horizontalCenter
      }
    }
  }
  //Component used to create scenario start time block
  Component {
    id : timeStartComponent
    Rectangle {
      id : startRectangle
      height : 40
      width : builderModel.actionSwitchView.width - builderModel.actionSwitchView.scrollWidth
      color : "transparent"
      Rectangle {
        id : textRectangle
        height : parent.height
        width : parent.width / 3
        anchors.horizontalCenter : parent.horizontalCenter
        color : "transparent"
        border.color : "black"
        border.width : 2
        radius : 15
        Text {
          anchors.centerIn : parent
          font.pointSize : 14
          text : "Input: " + root.scenarioInput
        } 
      }
    }
  }
  //Component used to create scenario length time block
  Component {
    id : timeEndComponent
    Column {
      id : timeEndColumn
      objectName : "timeEndColumn"
      property double scenarioLength_s : 0.0
      property double finalAdvanceTime_s : 0.0
      width : builderModel.actionSwitchView.width - builderModel.actionSwitchView.scrollWidth
      spacing : 0
      states : [
        State {
          name : "collapsed"
          PropertyChanges {target : timeEndColumn; height : 0; visible : false}
          when : scenarioLength_s == 0
        }
        ,State {
          name : "expanded"
          PropertyChanges {target : timeEndColumn; height : 100; visible : true}
          when : scenarioLength_s > 0
        }   
      ]
      Rectangle {
        width : parent.width
        height : builderModel.get(0).objectName==="scenarioEnd" ? 0 : 2
        color : "black"
      }
      Rectangle {
        height : 2 * parent.height / 5
        width : parent.width / 3
        anchors.horizontalCenter : parent.horizontalCenter
        color : "transparent"
        border.color : "black"
        border.width : 2
        radius : 15
        UITextInputForm {  
          id : simLengthText
          anchors.centerIn: parent
          property bool editable : false
          property int lastPosition : -1
          name.text : "Scenario Length: "
          name.font.pointSize : 14
          value.text : root.seconds_to_clock_time(scenarioLength_s)
          value.font.pixelSize : 18
          value.enabled : editable
          value.cursorVisible : false
          value.overwriteMode : true
          value.selectedTextColor : "white"
          value.selectionColor : "blue"
          value.maximumLength : 8
          value.cursorDelegate : Rectangle {
            visible : parent.cursorVisible
            width :  parent.cursorRectangle.width
            color : "blue"
          }
          value.onCursorPositionChanged : {
            if (value.text[value.cursorPosition] == ':'){
              if (value.cursorPosition > simLengthText.lastPosition){
                //Moving left
                ++value.cursorPosition;
              }
              else {
                //Moving right
                --value.cursorPosition
              }
            }
            simLengthText.lastPosition = value.cursorPosition
          }
          value.onEditingFinished : {
            if (!simLengthText.editable){
              return;  
            }
            let overrideLength_s = root.clock_time_to_seconds(value.text)
            if (overrideLength_s){
              console.log(builderModel.scenarioLength_s)
              if (overrideLength_s > builderModel.scenarioLength_s){
                builderModel.scenarioLengthOverride_s = overrideLength_s;
                builderModel.refreshScenarioLength()
              } else {
                warningMessage.text = "New scenario length must be longer than the minimum length of " + root.seconds_to_clock_time(builderModel.scenarioLength_s) + " determined by current action durations.";
                warningMessage.open();
              }
            } else {
              warningMessage.text = "Invalid time entry";
              warningMessage.open()
            }
            simLengthText.editable = false
          }
        }
        Image {
          id: increaseTime
          source : "icons/move-up.png"
          sourceSize.width : 15
          sourceSize.height: parent.height - 10
          anchors.right : parent.right
          anchors.rightMargin : 15
          anchors.verticalCenter : parent.verticalCenter
          ToolTip {
            visible : extendMouseArea.containsMouse
            delay : 200
            timeout : 2000
            text : "Extend scenario"
            font.pointSize : 10
          }
          MouseArea {
            id : extendMouseArea
            hoverEnabled: true
            anchors.fill : parent
            cursorShape : Qt.PointingHandCursor
            acceptedButtons : Qt.LeftButton
            onClicked: {
              simLengthText.editable = true
              simLengthText.value.selectAll()
              simLengthText.value.forceActiveFocus(0)
              console.log(simLengthText.value.activeFocus)
            }
          }
        }
      }
      Rectangle {
        color : "black"
        width : 2
        height : parent.height / 5
        anchors.horizontalCenter : parent.horizontalCenter
      }
      Text {
        id : timeText
        height : parent.height / 5
        font.pointSize : 12
        anchors.horizontalCenter : parent.horizontalCenter
        horizontalAlignment : Text.AlignHCenter
        text : root.seconds_to_clock_time(parent.finalAdvanceTime_s)
      }
      Rectangle {
        color : "black"
        width : 2
        height : parent.height / 5
        anchors.horizontalCenter : parent.horizontalCenter
      }
    }
  }
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 