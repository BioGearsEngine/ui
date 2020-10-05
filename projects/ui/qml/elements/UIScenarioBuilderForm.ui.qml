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
  property string samplingFrequency : "1;s"
  property string scenarioInput : "DefaultTemplateMale"
  property string scenarioName : ""
  property bool isPatientFile : true     //false ---> input = engine state file
  property Scenario bg_scenario
  //Non-visual elements defined in UIScenarioBuilder.qml
  property ActionModel builderModel
  property DataRequestModel bgRequests
  property EventModel eventModel
  property FolderListModel patientModel
  property FolderListModel stateModel
  property ListModel actionModel
  property ObjectModel activeRequestsModel
  //Components used to create time-based objects in builder model
  property Component timeGapComponent : timeGapComponent
  property Component timeStartComponent : timeStartComponent
  property Component timeEndComponent : timeEndComponent
  //Property aliases
  property alias actionDelegate : actionListDelegate
  property alias tabBar : tabBar
  property alias activeRequestView : activeRequestView
  property alias actionView : actionListView
  property alias scenarioView : scenarioListView
  property alias requestView : requestListView
  property alias warningMessage : warningMessage

  Page {
    id : windowPage
    anchors.fill : parent
    header : GridLayout {
      id : headerLayout
      rowSpacing : 10
      columnSpacing : 10
      rows : 2
      columns : 3
      TabBar {
        id : tabBar
        Layout.fillWidth : true
        implicitHeight : 40
        Layout.row : 0
        Layout.column : 0
        Layout.columnSpan : 3
        TabButton {
          text : "Set Actions"
          font.pixelSize : 18
          background : Rectangle {
            color: tabBar.currentIndex == 0 ? "#2980b9" : "lightgray"
          }
          contentItem : Text {
            text : parent.text
            font : parent.font
            color : tabBar.currentIndex == 0 ? "white" : "darkgray"
            verticalAlignment : Text.AlignVCenter
            horizontalAlignment : Text.AlignHCenter
          }
        }
        TabButton {
          text : "Set Data Requests"
          font.pixelSize : 18
          background : Rectangle {
            color: tabBar.currentIndex == 1 ? "#2980b9" : "lightgray"
          }
          contentItem : Text {
            text : parent.text
            font : parent.font
            color : tabBar.currentIndex == 1 ? "white" : "gray"
            verticalAlignment : Text.AlignVCenter
            horizontalAlignment : Text.AlignHCenter
          }
        }
      }
      RowLayout{
        Layout.fillWidth : true
        Layout.maximumWidth : scenarioBuilder.width / 2
        Layout.row : 1
        Layout.column : 0
        Label {
          id : nameLabel
          text : "Scenario Name:  "
          font.pixelSize : 18
          bottomPadding : 8
          Layout.leftMargin : 20
          Layout.alignment : Qt.AlignRight
          verticalAlignment : Text.AlignVCenter
          horizontalAlignment : Text.AlignRight
        }
        TextField {
          id : nameInput
          placeholderText: "Name"
          text : root.scenarioName
          font.pixelSize : 18
          wrapMode : TextInput.WordWrap
          Layout.fillWidth : true
          horizontalAlignment : Text.AlignHCenter
          Layout.alignment : Qt.AlignLeft
          onEditingFinished : {
            root.scenarioName = text
          }
        }
      }
      Label {
        id :samplingLabel
        Layout.row : 1
        Layout.column : 1
        text : "Sampling Frequency:  "
        font.pixelSize : 18
        bottomPadding : 6
        Layout.alignment : Qt.AlignRight
        verticalAlignment : Text.AlignVCenter
        horizontalAlignment : Text.AlignRight
      }
      ComboBox {
        id : samplingCombo
        Layout.row : 1
        Layout.column : 2
        currentIndex : setCurrentIndex() == -1 ? 4 : setCurrentIndex()    //Default to 1 Hz (index 4)
        Layout.alignment : Qt.AlignLeft | Qt.AlignVCenter
        implicitWidth : 150
        Layout.rightMargin : implicitWidth
        Layout.preferredHeight : samplingLabel.height * 1.2
        bottomInset : 0
        topInset : 0
        model : ["50;Hz", "25;Hz", "10;Hz", "5;Hz", "1;s", "10;s", "30;s", "60;s"]
        flat : false
        contentItem : Text {
          width : samplingCombo.width
          height : samplingCombo.height
          text : samplingCombo.displayText.replace(";", " ")
          font.pointSize : 12
          verticalAlignment : Text.AlignVCenter
          horizontalAlignment : Text.AlignHCenter
        }
        delegate : ItemDelegate {
          width : samplingCombo.popup.width
          contentItem : Text {
            width : parent.width
            text : modelData.replace(";", " ")
            font.pointSize : 12
            verticalAlignment : Text.AlignVCenter
            horizontalAlignment : Text.AlignHCenter
            }
          background : Rectangle {
            anchors.fill : parent
            color : "transparent"
            border.color : "green"
            border.width : samplingCombo.highlightedIndex === index ? 2 : 0
          }
        }
        popup : Popup {
          y : samplingCombo.height
          x : 0
          padding : 0
          width : samplingCombo.width - samplingCombo.indicator.width
          implicitHeight : contentItem.implicitHeight
          contentItem : ListView {
            clip : true
            implicitHeight : contentHeight
            model : samplingCombo.popup.visible ? samplingCombo.delegateModel : null
            currentIndex : samplingCombo.highlightedIndex
          }
        }
        background : Rectangle {
          id : samplingBackground
          //Height and width of this rectangle established by Layout preferred dimensions assigned in Loader
          border.color : "black"
          border.width : 1
        }
        onActivated : {
          root.samplingFrequency = currentText;
        }
        function setCurrentIndex(){
          if (model){
            for (let i = 0; i < model.length; ++i){
              if (model[i]===root.samplingFrequency){
                return i;
              }
            }
          }
          return -1;
        }
      }
    }
    StackLayout {
      id: builderStack
      width : scenarioBuilder.width
      height : windowPage.height - windowPage.implicitHeaderHeight - windowPage.implicitFooterHeight
      currentIndex : tabBar.currentIndex
      //-----First Tab-------------------- 
      Item {
        //Wrapping grid layout in item helps break binding loops that can occur with nested layouts (RowLayout inside StackLayout)
        id : firstTab
        Layout.fillWidth : true
        Layout.fillHeight : true
        RowLayout {
          id : actionLayout
          anchors.fill : parent
          Rectangle {
            Layout.fillHeight : true
            Layout.preferredWidth : actionLayout.width * 0.2 - actionLayout.spacing / 2
            color : "transparent"
            border.color : "grey"
            border.width : 1
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
            Layout.fillHeight : true
            Layout.fillWidth : true
            Layout.maximumWidth : actionLayout.width * 0.8 - actionLayout.spacing / 2
            color : "transparent"
            border.color : "grey"
            border.width : 1
            ListView {
              id : scenarioListView
              property double scrollWidth : scenarioScroll.width
              anchors.top : parent.top
              anchors.topMargin : 15
              anchors.bottom : parent.bottom
              anchors.left : parent.left
              anchors.right : parent.right
              clip : true
              currentIndex : -1
              spacing : 5
              model : builderModel
              header : timeEndComponent
              footer : timeStartComponent
              ScrollBar.vertical : ScrollBar {
                id : scenarioScroll
                policy : ScrollBar.AlwaysOn
              }
              move : Transition {
                NumberAnimation {properties: "x,y"; duration : 500; easing.type: Easing.Linear}
              }
              moveDisplaced : Transition {
                NumberAnimation {properties : "y"; duration : 500; easing.type : Easing.Linear}
              }
              addDisplaced : Transition {
                NumberAnimation {properties : "y"; duration : 500; easing.type : Easing.Linear}
              }
            }
          }

        } //end first tab content
      } //end first tab wrapper
      //------Second Tab-----------
      Item {
        //Wrapping grid layout in item helps break binding loops that can occur with nested layouts (Row inside Grid inside Stack)
        id : secondTab
        Layout.fillWidth : true
        Layout.fillHeight : true
        RowLayout {
          id : dataRequestLayout
          anchors.fill : parent
          spacing : 5
          Rectangle {
            id : requestMenu
            Layout.fillHeight : true
            Layout.preferredWidth : parent.width / 3
            border.color : "grey"
            border.width : 1
            ListView {
              id : requestListView
              anchors.topMargin : 2
              anchors.leftMargin : 2
              anchors.fill : parent
              property double scrollWidth : requestScroll.width
              model : DelegateModel {
                id : requestModel
                model : root.bgRequests
                //rootIndex defaults to topmost node, which is what we want
                delegate : Component {
                  Loader {
                    id : requestLoader
                    width : requestListView.width - requestListView.scrollWidth
                    sourceComponent : dataRequestNode
                    property var _model_data : root.bgRequests
                    property var _node_index : requestModel.modelIndex(index)
                    property int _indent_level : 0
                    onLoaded : {
                      if (!_model_data.data(_node_index, DataRequestModel.CollapsedRole)){
                        item.toggleCollapsedView(_model_data.data(_node_index, DataRequestModel.CollapsedRole))
                      }
                      item.width = requestListView.width
                    }
                    Connections {
                      target : root
                      //Only need to call clear/load at the top level because loaded components of top level nodes will get released and, the next
                      //time they are set, will detect that the data model was changed.
                      onClearScenario : {requestLoader.item.toggleCollapsedView(true)}
                      onScenarioLoaded : {requestLoader.item.toggleCollapsedView(requestLoader._model_data.data(requestLoader._node_index, DataRequestModel.CollapsedRole))}
                    }
                  }
                }
              }
              currentIndex : -1
              clip : true
              ScrollBar.vertical : ScrollBar {
                id : requestScroll
                policy : ScrollBar.AlwaysOn
              }   
            }// end list view
          } // end list view container
          Rectangle { 
            id : requestPanel
            Layout.fillHeight : true
            Layout.fillWidth : true
            Layout.maximumWidth : 2 * windowPage.width / 3
            border.color : "grey"
            border.width : 1
            ListView {
              id : activeRequestView
              anchors.left : parent.left
              anchors.right : parent.right
              anchors.top : parent.top
              anchors.topMargin : 5
              anchors.bottom : parent.bottom
              property double scrollWidth : activeRequestScroll.width
              model : activeRequestsModel
              currentIndex : -1
              clip : true
              ScrollBar.vertical : ScrollBar {
                id : activeRequestScroll
                policy : ScrollBar.AlwaysOn
              }
            }
          }//end list view container
        }//end second tab content
      } //end second tab wrapper
    } //end stack layout
    footer : RowLayout {
      id : optionArea
      spacing : 50
      UIBioGearsButtonForm {
        id : saveScenario
        text : "Save Scenario"
        font.pixelSize : 16
        implicitHeight : 40
        Layout.preferredWidth : parent.width / 4 - 2 * spacing
        Layout.alignment : Qt.AlignHCenter
        Layout.topMargin : 5
        Layout.bottomMargin : 5
        onClicked : {
          root.saveScenario()
        }
      }
      UIBioGearsButtonForm {
        id : loadScenario
        text : "Load Scenario"
        font.pixelSize : 16
        implicitHeight : 40
        Layout.preferredWidth : parent.width / 4 - 2 * spacing
        Layout.alignment : Qt.AlignHCenter
        Layout.topMargin : 5
        Layout.bottomMargin : 5
        onClicked : {
          if (builderModel.count > 0 || activeRequestsModel.count > 0){
            let warningDefinition = 'import QtQuick.Dialogs 1.3; MessageDialog {width : 800; title : "Overwrite?"; text : "Loading a scenario will overwrite current scenario definition.";
                informativeText : "Do you wish to continue?"; icon : StandardIcon.Warning; standardButtons : StandardButton.Yes | StandardButton.No}'
            let overwriteMsg = Qt.createQmlObject(warningDefinition, scenarioBuilder, 'OverwriteMessage');
            overwriteMsg.onYes.connect(function() {root.clearScenario(); bg_scenario.edit_scenario()})
            overwriteMsg.onNo.connect(function() {overWriteMsg.close(); return})
            overwriteMsg.open()
          } else {
            root.clearScenario()
            bg_scenario.edit_scenario()
          }
        }
      }
      UIBioGearsButtonForm {
        id : resetScenario
        text : "Reset Scenario"
        font.pixelSize : 16
        implicitHeight : 40
        Layout.preferredWidth : parent.width / 4 - 2 * spacing
        Layout.alignment : Qt.AlignHCenter
        Layout.topMargin : 5
        Layout.bottomMargin : 5
        onClicked : {
          root.clearScenario()
        }
      }
    }
    MessageDialog {
      id : warningMessage
      icon : StandardIcon.Critical
      standardButtons : StandardButton.Ok
      width : parent.width / 3
      text : ""
      visible : false
    }
  }
 //---Components loaded during runtime----------------
 //View delegate for list of actions
  Component {
    id : actionListDelegate
    Rectangle {
      id : delegateWrapper
      height : delegateText.height * 1.4
      width : actionView.width - actionView.scrollWidth  //aligns with ListView preferred width
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
          actionView.currentIndex = index;
        }
        onDoubleClicked : {
          builderModel.createAction(actionModel.get(actionView.currentIndex))
          actionView.currentIndex = -1
        }
      }
    }
  }
  //Component used to create time blocks between each action
  Component {
    id : timeGapComponent
    ColumnLayout {
      id : timeColumn
      property double blockTime_s : 0
      property int index : -1   //Note that this index counts up from the bottom of the scenario builder
      width : scenarioView.width - scenarioView.scrollWidth
      spacing : 0
      states : [
        State {
          name : "collapsed"
          PropertyChanges {target : timeColumn; height : 0; visible : false}
          when : blockTime_s == 0 && index > 1  //Normally, if there is no time between actions we will not display a clock event. The exception is the first time block (bottom most) between the patient block and the first action
        }
        ,State {
          name : "expanded"
          PropertyChanges {target : timeColumn; height : 60; visible : true}
          when : blockTime_s > 0 || index == 1
        }     
      ]
      Rectangle {
        id : topLine
        color : "black"
        Layout.preferredWidth : 2
        implicitHeight : 20
        Layout.alignment : Qt.AlignHCenter
      }
      Text {
        id : timeText
        Layout.alignment : Qt.AlignHCenter
        font.pointSize : 12
        text : root.seconds_to_clock_time(parent.blockTime_s)
      }
      Rectangle {
        id : bottomLine
        color : "black"
        Layout.preferredWidth : 2
        implicitHeight : 20
        Layout.alignment : Qt.AlignHCenter
      }
    }
  }
  //Component used to create patient input block
  Component {
    id : timeStartComponent
    Rectangle {
      id : startRectangle
      height : 40
      width : scenarioView.width - scenarioView.scrollWidth
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
          font.pixelSize : 18
          text : "Input: " + root.scenarioInput
        } 
        ToolTip {
          visible : inputMouseArea.containsMouse
          delay : 200
          timeout : 2000
          text : "Change patient"
          font.pointSize : 10
        }
        MouseArea {
          id : inputMouseArea
          hoverEnabled: true
          anchors.fill : parent
          cursorShape : Qt.PointingHandCursor
          acceptedButtons : Qt.LeftButton
          onClicked: {
            patientMenu.open()
          }
        }
        Menu {
          id : patientMenu
          closePolicy : Popup.CloseOnEscape | Popup.CloseOnReleaseOutside
          delegate : MenuItem {
            font.pixelSize : 15
            background : Rectangle {
              color : "transparent"
              border.color : "#1A5276"
              border.width : highlighted ? 2 : 0
            }
          }
          Menu {
            title : "Patient"
            Repeater {
              id : patientSubMenu
              model : root.patientModel.status == FolderListModel.Ready ? root.patientModel : null
              delegate : MenuItem {
                id : patientDelegate
                text : model.fileBaseName
                contentItem : Text {
                  text : patientDelegate.text
                  font.pixelSize : 15
                  horizontalAlignment : Qt.AlignHCenter
                }
                width : parent.width
                onTriggered : {
                  root.scenarioInput = text
                  root.isPatientFile = true
                  patientMenu.close()
                }
                background : Rectangle {
                  color : "transparent"
                  border.color : "#1A5276"
                  border.width : patientDelegate.highlighted ? 2 : 0
                }
              }
            }
          }
          Menu {
            title : "Engine State"
            Repeater {
              id : stateSubMenu
              model : root.stateModel.status == FolderListModel.Ready ? root.stateModel : null
              delegate : MenuItem {
                id : stateDelegate
                text : model.fileBaseName
                contentItem : Text {
                  text : stateDelegate.text
                  font.pixelSize : 15
                  horizontalAlignment : Qt.AlignHCenter
                }
                width : parent.width
                onTriggered : {
                  root.scenarioInput = text
                  root.isPatientFile = false
                  patientMenu.close()
                }
                background : Rectangle {
                  anchors.fill : parent
                  color : "transparent"
                  border.color : "#1A5276"
                  border.width : stateDelegate.highlighted ? 2 : 0
                }
              }
            }
          }
        }
      }
    }
  }
  //Component used to create scenario length time block
  Component {
    id : timeEndComponent
    Column {
      id : timeEndColumn
      property double scenarioLength_s : builderModel.scenarioLength_s
      property double finalAdvanceTime_s : 0.0
      width : scenarioView.width - scenarioView.scrollWidth
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
        height : 2 * parent.height / 5
        width : parent.width / 3
        anchors.horizontalCenter : parent.horizontalCenter
        color : "transparent"
        border.color : "black"
        border.width : 2
        radius : 15
        RowLayout {
          id: simLength
          property bool editable : false
          property alias simLengthText : simLengthText
          anchors.centerIn : parent
          Label {
            id: simLengthLabel
            text: "Simluation Length: "
            font.pixelSize : 18
            font.weight: Font.DemiBold
            font.bold: true
          }
          TextInput {
            id: simLengthText
            property int lastPosition : -1
            text: root.seconds_to_clock_time(scenarioLength_s)
            font.weight: Font.Medium
            font.pixelSize: 18
            enabled : parent.editable
            cursorVisible : parent.editable
            overwriteMode : true
            selectedTextColor : "white"
            selectionColor : "blue"
            maximumLength : 8
            cursorDelegate : Rectangle {
              visible : parent.cursorVisible
              width :  parent.cursorRectangle.width
              color : "blue"
              opacity : 0.3
            }
            Keys.onPressed : {
              //Prevent user from deleting time--only allow overwriting
              if (event.key == Qt.Key_Backspace || event.key == Qt.Key_Delete){
                event.accepted = true   //accepting swallows the key event and keeps it local to this Keys block, meaning it won't get propagated up to text input
              } else {
                event.accepted = false
              }
            }
            onCursorPositionChanged : {
              if (text[cursorPosition] == ':'){
                if (cursorPosition > simLengthText.lastPosition){
                  //Moving left
                  ++cursorPosition;
                }
                else {
                  //Moving right
                  --cursorPosition
                }
              }
              lastPosition = cursorPosition
            }
            onEditingFinished : {
              if (!parent.editable){
                return;  
              }
              let overrideLength_s = root.clock_time_to_seconds(text)
              if (overrideLength_s){
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
              parent.editable = false
            }
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
              simLength.editable = true
              simLengthText.selectAll()
              simLengthText.forceActiveFocus(0)
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
  }//end time component

  //Component for data request delegates
  Component {
    id : dataRequestNode
    Column {
      id : nodeWrapper
      property var model : _model_data
      property var index : _node_index
      property int indentLevel : _indent_level
      property string imageSource : "icons/collapsed.png"
      function toggleCollapsedView(nextCollapsed){
        model.setData(index, nextCollapsed, DataRequestModel.CollapsedRole)
        if (nextCollapsed){
          nestedNodeLoader.sourceComponent = undefined
          nestedNodeLoader.visible = false
          nodeWrapper.imageSource = "icons/collapsed.png"
        } else {
          nodeWrapper.imageSource = "icons/expanded.png"
          nestedNodeLoader.sourceComponent = nestedComponent
          nestedNodeLoader.visible = true
        }
      }
      Rectangle {
        property bool selected : false
        width : parent.width
        height : 30
        border.color : "blue"   //just to visualize positioning while testing (change width to something other than 0 to see)
        border.width : 0
        Image {
          id: toggleSubMenu
          x : 15 + 45 * nodeWrapper.indentLevel
          source : nodeWrapper.imageSource
          sourceSize.width : 15
          sourceSize.height: 15
          anchors.verticalCenter : parent.verticalCenter
          MouseArea {
            id : toggleMouseArea
            anchors.fill : parent
            cursorShape : Qt.PointingHandCursor
            acceptedButtons : Qt.LeftButton
            onClicked: {
              let nextCollapsed = !nodeWrapper.model.data(nodeWrapper.index, DataRequestModel.CollapsedRole)
              nodeWrapper.toggleCollapsedView(nextCollapsed)  
            }
          }
        }
        Text {
          text : root.displayFormat(model.data(index, DataRequestModel.NameRole))
          font.pixelSize : 16
          height : parent.height
          verticalAlignment : Text.AlignVCenter
          anchors.left : toggleSubMenu.right
          anchors.leftMargin : 15
        }
      }
      //Nested nodes will appear below their parent
      Loader {
        id: nestedNodeLoader
        width : parent.width
        visible : false
        property int _indent_level : nodeWrapper.indentLevel + 1
        property var _nested_model : model
        property var _root_index : index
        onLoaded : {
          item.active = visible
        }
        Component {
          id : nestedComponent
          Column {
            id : nestedNode
            signal resetNested()
            property int indentLevel : _indent_level
            property var nestedModel : _nested_model
            property var root : _root_index
            property bool active : false   //Don't set true until component is loaded so that we make sure data further up in hierarchy is defined first
            Repeater {
              model : DelegateModel {
                id : nestedDelegate
                model : nestedNode.nestedModel
                rootIndex : nestedNode.root
                delegate : Loader {
                  width : parent.width
                  visible : active
                  property bool subQuantity : _model_data.data(_node_index, DataRequestModel.NameRole) === "SubstanceQuantity"
                  property var _node_index : nestedDelegate.modelIndex(index)
                  property var _model_data : nestedModel
                  property int _indent_level : indentLevel
                  sourceComponent : active ? (model.hasModelChildren ? dataRequestNode : subQuantity ? substanceQuantityNode : dataRequestLeaf ) : undefined
                  onLoaded : {
                    if (!_model_data.data(_node_index, DataRequestModel.CollapsedRole)){
                      item.toggleCollapsedView(_model_data.data(_node_index, DataRequestModel.CollapsedRole))
                    }
                  }
                }
              } //end delegate model
            } //end repeater
          }// end nested node column
        }//end nested node component
      }//end nested node loader
    }// end column wrapper (visual component)
  } // end data request node component
  Component {
    id : dataRequestLeaf
    Rectangle {
      id : leafWrapper
      property var model : _model_data   
      property var index : _node_index
      property int indentLevel : _indent_level
      property string path : model.dataPath(index)
      width : parent.width 
      height : 30
      CheckBox {
        id : leafCheckBox
        x : 15 + indentLevel * 45
        height : parent.height
        width : parent.width - x - 15   //extra padding so text doesn't run into scroll bar
        text : root.displayFormat(model.data(index, DataRequestModel.NameRole))
        font.pixelSize : 16
        checkable : true
        checked : model.data(index, Qt.CheckStateRole)
        contentItem : Text {
            id : textContent
            anchors.left : leafCheckBox.indicator.right
            leftPadding : 5
            text : width > 0 ? leafCheckBox.text : ""    //Text elide does not work correctly on loading unless a width non-zero (width = 0 happens momentarily while building components
            font : leafCheckBox.font
            width : leafCheckBox.width - leafCheckBox.indicator.width - leftPadding
            height : parent.height
            elide : Text.ElideRight
            verticalAlignment : Text.AlignVCenter
            MouseArea {
              id : leafMouseArea
              width : parent.width
              height : leafCheckBox.height
              cursorShape : Qt.PointingHandCursor
              hoverEnabled : true
            }
            ToolTip {
              x : 10
              y : leafCheckBox.height / 2
              visible : (leafMouseArea.containsMouse && leafCheckBox.contentItem.truncated)
              delay : 500
              timeout : 2000
              text : leafCheckBox.text
              font.pointSize : 10
            }
          }
        onClicked : {
          model.setData(index, checkState, Qt.CheckStateRole)
          if (checkState == Qt.Checked){
            activeRequestsModel.addRequest(path, model.data(index, DataRequestModel.TypeRole))
          } else {
            activeRequestsModel.removeRequest(path)
          }
        }
      }
    }
  }
  Component {
    id : substanceQuantityNode
    Column {
      id : leafWrapper
      width : parent.width
      property var model : _model_data   
      property var index : _node_index
      property int indentLevel : _indent_level
      property string path : model.dataPath(index)
      property string imageSource : "icons/add_plain.png"
      property alias subModel : subQuantityModel
      property var subQList : []
      function loadSubstanceQuantity(loadPath, substance, quantity, unit, precision){
        if (loadPath===leafWrapper.path){
          let requestPath = leafWrapper.path + "-" + subModel.count
          subModel.append({"substance" : substance, "quantity" : quantity, "unit" : unit, "precision" : precision, "path" : requestPath})
        }
      }
      Connections {
        target : activeRequestsModel
        onSubstanceQuantityLoaded : { if (pathId===leafWrapper.path) {loadSubstanceQuantity(pathId, sub, quantity, unit, precision)} }
      }
      Rectangle {  
        width : parent.width
        height : 30
        Image {
          id: toggleSubMenu
          x : 25 + 45 * leafWrapper.indentLevel
          source : leafWrapper.imageSource
          sourceSize.width : 15
          sourceSize.height: 15
          anchors.verticalCenter : parent.verticalCenter
          MouseArea {
            id : toggleMouseArea
            hoverEnabled : true
            anchors.fill : parent
            cursorShape : Qt.PointingHandCursor
            acceptedButtons : Qt.LeftButton
            onClicked: {
              let requestPath = leafWrapper.path + "-" + subModel.count
              subModel.append({"substance" : "", "quantity" : "", "unit" : "", "precision" : "", "path" : requestPath})
            }
          }
          ToolTip {
            x : -1.2 * width
            y : -height / 4
            visible : toggleMouseArea.containsMouse
            delay : 500
            timeout : 2000
            text : "Add"
            font.pointSize : 10
          }
        }
        Text {
          text : root.displayFormat(model.data(index, DataRequestModel.NameRole))
          font.pixelSize : 16
          height : parent.height
          verticalAlignment : Text.AlignVCenter
          anchors.left : toggleSubMenu.right
          anchors.leftMargin : 10
        }
      }
      ListModel {
        id : subQuantityModel
      }
      ListView {
        id : subQuantityView
        model : subQuantityModel
        width : parent.width
        height : count > 0 ? count * (20 + spacing) + 10 : 0
        delegate : CheckBox {
          id : subCheckBox
          x : 15 + (indentLevel + 1 ) * 45
          width : ListView.view.width - x - 15  //extra padding so text doesn't run into scroll bar
          text : model.substance + " - " + model.quantity
          contentItem : Text {
            id : subContent
            anchors.left : subCheckBox.indicator.right
            leftPadding : 5
            text : width > 0 ? subCheckBox.text : ""    //Text elide does not work correctly on loading unless width is non-zero (width = 0 happens momentarily while building components)
            font : subCheckBox.font
            width : subCheckBox.width - subCheckBox.indicator.width - leftPadding
            height : parent.height
            elide : Text.ElideRight
            verticalAlignment : Text.AlignVCenter
            MouseArea {
              id : requestMouseArea
              width : parent.width
              height : subCheckBox.height
              cursorShape : Qt.PointingHandCursor
              hoverEnabled : true
            }
            ToolTip {
              x : 10
              y : subCheckBox.height / 2
              visible : requestMouseArea.containsMouse
              delay : 500
              timeout : 2000
              text : subCheckBox.text
              font.pointSize : 10
            }
          }
          font.pixelSize : 16
          checkable : true
          tristate : true
          checkState : (model.substance !== "" && model.quantity!=="") ? Qt.Checked : Qt.PartiallyChecked
          height : 20
          function updateText(sub, quantity){
            ListView.view.model.set(index, {"substance" : sub, "quantity" : quantity})
          }
          function removeMe(){
            if (ListView.view){
              ListView.view.model.remove(index,1);
            }
          }
          onClicked : {
            activeRequestsModel.removeRequest(model.path);
            removeMe();
          }
          ListView.onAdd : {
            let req = activeRequestsModel.addRequest(model.path, "", model.unit, model.precision, model.substance, model.quantity)
            subQList.push(req)
            subQList[subQList.length-1].substanceQuantityChanged.connect(updateText)
            root.clearScenario.connect(removeMe)
          }
          ListView.onRemove : {
            root.clearScenario.disconnect(removeMe)
          }
        }
      }
    }
  }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 