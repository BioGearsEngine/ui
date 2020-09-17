import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

UIActionForm {
  id: root
  color: "transparent"
  border.color: "black"


  property double volume : 0
  property double rate : 0
  property string blood_type : ""
  property bool validBuildConfig : blood_type !=="" && rate > 0.0 && volume > 0.0
  
  actionType : "Transfusion"
  actionClass : EventModel.SubstanceAdministration
  actionSubClass : EventModel.Transfusion
  fullName  : "<b>%1</b><br> Volume = %2<br> Rate = %3".arg(actionType).arg(volume).arg(rate)
  shortName : "[<font color=\"lightsteelblue\"> %2</font>] <b>%1</b>".arg(actionType).arg(blood_type)

  //Builder mode data -- data passed to scenario builder
  buildParams: "SubstanceCompound=" + blood_type + ";BagVolume=" + volume + ",mL;Rate=" + rate + ",mL/min;"
  //Interactive mode -- apply action immediately while running
  onActivate:   { scenario.create_blood_transfusion_action(blood_type, volume, rate)  }
  onDeactivate: { scenario.create_blood_transfusion_action(blood_type, 0, 0)  }

  controlsDetails : Component  {
    GridLayout {
      id: grid
      columns : 4
      rows    : 4
      width : root.width -5
      anchors.centerIn : parent      
      Label {
        font.pixelSize : 10
        font.bold : true
        color : "blue"
        text : "%1".arg(actionType)
      }      
      Label {
        font.pixelSize : 10
        font.bold : false
        color : "steelblue"
        text : "[%1]".arg(root.blood_type)
        Layout.alignment : Qt.AlignHCenter
      }
      //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
        text : "Volume"
      }      
      Slider {
        id: bagVolume      
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1
        stepSize : 0.05
        value : root.volume

        onMoved : {
          root.volume = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : "%1 ml".arg(root.volume )
      }
      //Column 3
      Label {
        Layout.row : 2
        Layout.column : 0
        text : "Flow Rate"
      }      
      Slider {
        id: flowRate
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1
        stepSize : 0.05
        value : root.rate

        onMoved : {
          root.rate = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : "%1 ml/min".arg(root.rate )
      }
      // Column 4
      Rectangle {
        id: toggle      
        Layout.row : 3
        Layout.column : 2
        Layout.columnSpan : 2
        Layout.fillWidth : true
        Layout.preferredHeight : 30      
        color:        root.active? 'green': 'red' // background
        opacity:      active  &&  !mouseArea.pressed? 1: 0.3 // disabled/pressed state      
        Text {
          text:  root.active?    'On': 'Off'
          color: root.active? 'white': 'white'
          horizontalAlignment : Text.AlignHCenter
          width : pill.width
          x:    root.active ? 0: pill.width
          font.pixelSize: 0.5 * toggle.height
          anchors.verticalCenter: parent.verticalCenter
        }
        Rectangle { // pill
            id: pill
    
            x: root.active ? pill.width: 0 // binding must not be broken with imperative x = ...
            width: parent.width * .5;
            height: parent.height // square
            border.width: parent.border.width
    
        }
        MouseArea {
            id: mouseArea
    
            anchors.fill: parent
    
            drag {
                target:   pill
                axis:     Drag.XAxis
                maximumX: toggle.width - pill.width
                minimumX: 0
            }
    
            onReleased: { // Did we drag the button far enough.
              if( root.active) {
                  if(pill.x < toggle.width - pill.width) {
                    root.active = false // right to left
                  }
              } else {
                  if(pill.x > toggle.width * 0.5 - pill.width * 0.5){
                    root.active = true // left  to right
                } 
              }
            }
            onClicked: {
              root.active = !root.active
            }// emit
        }
      }
    }
  }// End Details Component

  builderDetails : Component {
    GridLayout {
      id: grid
      columns : 4
      rows : 3
      width : root.width - 5
      anchors.centerIn : parent
      columnSpacing : 20
      signal clear()
      onClear : {
        compoundCombo.currentIndex = -1
        root.compound = ""
        root.rate = 0
        root.volume = 0
        startTimeLoader.item.clear()
      }
      Label {
        id : actionLabel
        Layout.row : 0
        Layout.column : 0
        Layout.columnSpan : 4
        Layout.fillHeight : true
        Layout.fillWidth : true
        Layout.preferredWidth : grid.width * 0.5
        font.pixelSize : 20
        font.bold : true
        color : "blue"
        leftPadding : 5
        text : "%1".arg(actionType)
      }    
      //Row 2
      RowLayout {
        id : compoundWrapper
        Layout.row : 1
        Layout.column : 0
        Layout.columnSpan : 2
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3
        Layout.alignment : Qt.AlignLeft
        Layout.fillHeight : true
        spacing  : 30
        Label {
          id : compoundLabel
          leftPadding : 5
          text : "Compound"
          font.pixelSize : 18
        }      
        Loader {
          id : compoundCombo
          sourceComponent : comboInput
          property var _combo_model : scenario.get_transfusion_products()
          property var _initial_value : root.blood_type
          Layout.fillWidth : true
          Layout.maximumWidth : grid.width / 2 - 1.5 * compoundLabel.width - parent.spacing
        }
        Connections {
          target : compoundCombo.item
          onActivated : {
            root.blood_type = target.textAt(target.currentIndex)
          }
        }
      }
      Loader {
        id : startTimeLoader
        sourceComponent : timeEntry
        onLoaded : {
          item.entryName = "Start Time"
          Layout.row = 1
          Layout.column = 2
          Layout.alignment = Qt.AlignHCenter
          Layout.fillWidth = true
          Layout.fillHeight = true
          Layout.maximumWidth = grid.width / 5
          if (actionStartTime_s > 0.0){
            item.reload(actionStartTime_s)
          }
        }
      }
      Connections {
        target : startTimeLoader.item
        onTimeUpdated : {
          root.actionStartTime_s = totalTime_s
        }
      }
      Rectangle {
        //placeholder for spacing
        color : "transparent"
        Layout.row : 1
        Layout.column : 3
        Layout.preferredHeight : compoundWrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 4
        Layout.fillHeight : true
      }

      //Row 3
      RowLayout {
        id : rateWrapper
        Layout.maximumWidth : grid.width / 2 - grid.columnSpacing / 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.alignment : Qt.AlignLeft
        Layout.row : 2
        Layout.column : 0
        Layout.columnSpan : 2
        Label {
          id : rateLabel
          leftPadding : 5
          text : "Rate"
          font.pixelSize : 18
        }
        Slider {
          id: rateSlider
          Layout.fillWidth : true
          from : 0
          to : 250
          stepSize : 10
          value : root.rate
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.rate = value
          }
        }
        Label {
          text : "%1 mL/min".arg(root.rate)
          font.pixelSize : 18
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : volumeWrapper
        Layout.maximumWidth : grid.width / 2 - grid.columnSpacing / 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 2
        Layout.columnSpan : 2
        Label {
          id : volumeLabel
          leftPadding : 5
          text : "Volume"
          font.pixelSize : 18
        }
        Slider {
          id: volumeSlider
          Layout.fillWidth : true
          from : 0
          to : 2000
          stepSize : 25
          value : root.volume
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.volume = value
          }
        }
        Label {
          text : "%1 mL".arg(root.volume)
          font.pixelSize : 18
          Layout.alignment : Qt.AlignLeft
        }
      }
      //Row 4
      Rectangle {
        //placeholder for spacing
        color : "transparent"
        Layout.row : 3
        Layout.column : 0
        Layout.columnSpan : 2
        Layout.preferredHeight : compoundWrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
        Layout.fillWidth : true
        Layout.maximumWidth : grid.width / 2 - grid.columnSpacing / 2
        Layout.fillHeight : true
      }
      Rectangle {
        Layout.row : 3
        Layout.column : 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 4 - grid.columnSpacing / 2
        color : "transparent"
        border.width : 0
        Layout.alignment : Qt.AlignHCenter
        Button {
          text : "Set Action"
          opacity : validBuildConfig ? 1 : 0.4
          anchors.centerIn : parent
          height : parent.height 
          width : parent.width / 2
          onClicked : {
            if (validBuildConfig){
              viewLoader.state = "collapsedBuilder"
              root.buildSet(root)
            }
          }
        }
      }
      Rectangle {
        Layout.row : 3
        Layout.column : 3
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 4 - grid.columnSpacing
        color : "transparent"
        border.width : 0
        Layout.alignment : Qt.AlignHCenter
        Button {
          text : "Clear Fields"
          anchors.centerIn : parent
          height : parent.height
          width : parent.width / 2
          onClicked : {
            grid.clear()
          }
        }
      }
    }
  } //end transfusion builder component
}