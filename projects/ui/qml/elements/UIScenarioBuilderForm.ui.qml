import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import QtQml.Models 2.12
import com.biogearsengine.ui.scenario 1.0

Window {
  id : scenarioBuilder
  title : "Scenario Builder"
  property alias actionDelegate : actionListDelegate
  property alias actionView : actionListView
  property alias scenarioView : scenarioListView
  property Scenario bg_scenario
  //Non-visual elements defined in UIScenarioBuilder.qml
  property ListModel actionModel
  property ActionModel builderModel
  property EventModel eventModel

  TabBar {
    id : tabBar
    width : parent.width
    TabButton {
      text : "Set Actions"
    }
    TabButton {
      text : "Set Data Requests"
    }
    TabButton {
      text : "Set Patient Data"
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

      Item {
        id : actionLabel
        Layout.row : 0
        Layout.column : 0
        Layout.preferredHeight : parent.height * 0.05
        Layout.preferredWidth : parent.width * 0.2
        Label {
          id : actionLabelText
          anchors.centerIn: parent
          text : "Actions"
          font.pointSize : 16
        }  
      }
      Item {
        id : scenarioLabel
        Layout.row : 0
        Layout.column : 1
        Layout.preferredHeight : parent.height * 0.05
        Layout.preferredWidth : parent.width * 0.8
        Label {
          id : scenarioLabelText
          anchors.centerIn: parent
          text : "Scenario"
          font.pointSize : 16
        }  
      }

      Rectangle {
        Layout.row : 1
        Layout.column : 0
        Layout.preferredHeight : parent.height * 0.75
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
        border.color : 'blue'
        Layout.preferredHeight : parent.height * 0.75
        Layout.preferredWidth : parent.width * 0.8
        border.width : 1
        Layout.row : 1
        Layout.column : 1
        ListView {
          id : scenarioListView
          property double scrollWidth : scenarioScroll.width
          anchors.fill : parent
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

      Item {
        id : scenarioButtonArea
        Layout.preferredWidth : parent.width * 0.8
        Layout.preferredHeight : parent.height * 0.075
        Layout.row : 2
        Layout.column : 1
        RowLayout {
          width : parent.width / 2
          height : parent.height
          anchors.centerIn : parent
          spacing : 5
          Button {
            id : removeButton
            Layout.preferredHeight : parent.height
            Layout.preferredWidth : parent.width / 4
            text : "Remove"
            onClicked : {
              if (scenarioView.currentIndex !== -1){
                builderModel.remove(scenarioView.currentIndex, 1)
                scenarioView.currentIndex = -1
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
    //------Third Tab------------
    Rectangle {
      color : "green"
      Layout.fillWidth : true
      Layout.fillHeight : true
      Layout.preferredHeight : parent.height
      Layout.preferredWidth : parent.width
    } //end third tab
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
        root.close()
      }
    }
  }
 
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
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 