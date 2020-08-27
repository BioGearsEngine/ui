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

  property int severity : -1
  property double mic : 0.0
  property string location : ""
  property string severity_str :  (severity == -1) ? "" : (severity == 0) ?"None" : (severity == 1) ?"Mild" : (severity == 2) ?"Moderate" : "Severe"
  property bool validBuildConfig : (severity !== -1 && location !=="" && mic > 0.0 && actionStartTime_s)

  actionType : "Bacterial Infection"
  actionClass : EventModel.Infection
  fullName  : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>] <br> Severity = %3 <br> MIC = %4".arg(actionType)
             .arg(location)
             .arg(severity_str)
             .arg(mic)
  shortName : " [<font color=\"lightsteelblue\"> %3</font>] <b>%1</b>  <font color=\"lightsteelblue\">%2</font>".arg(actionType).arg(location).arg(severity_str)

  //Builder mode data -- data passed to scenario builder
  buildParams : "Location:" + location + ";Severity:" + severity + ";MinimumInhibitoryConcentration:" + mic + ",mg/L;"
  //Interactive mode -- apply action immediately while running
  onActivate:   { scenario.create_infection_action(location, severity, mic)  }
  onDeactivate: { scenario.create_infection_action(location, 0, 0 )  }

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
        text : "[%1]".arg(root.location)
        Layout.alignment : Qt.AlignHCenter
      }
      //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
        text : "Severity"
      }      
      Slider {
        id: severity
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 3
        stepSize : 1
        value : root.severity

        onMoved : {
          root.severity = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : severity_str
      }
          //Column 3
      Label {
        Layout.row : 2
        Layout.column : 0
        text : "MIC"
      }      
      Slider {
        id: mic
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 500
        stepSize : 10
        value : root.mic

        onMoved : {
          root.mic = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : "%1 mg/L".arg(root.mic)
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
    id : builderDetails
    GridLayout {
      id: grid
      columns : 4
      rows : 3 
      width : root.width -5
      anchors.centerIn : parent
      signal clear()
      onClear : {
        root.severity = 0
        severityRadioGroup.radioGroup.checkState = Qt.Unchecked
        locationCombo.currentIndex = -1
        startTimeLoader.item.clear()
        durationLoader.item.clear()
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
        text : "%1".arg(actionType) + "[%1]".arg(root.compartment)
      }    
      //Row 2
      RowLayout {
        id : micWrapper
        Layout.maximumWidth : grid.width / 3
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 1
        Layout.columnSpan : 2
        Layout.column : 0
        Label {
          id : micLabel
          leftPadding : 5
          text : "MIC"
          font.pixelSize : 15
        }
        Slider {
          id: micSlider
          Layout.fillWidth : true
          from : 0
          to : 150
          stepSize : 5
          value : root.mic
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.mic = value
          }
        }
        Label {
          text : "%1 mg/L".arg(root.mic)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
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
          root.actionStartTime_s = seconds + 60 * minutes + 3600 * hours
        }
      }
      Rectangle {
        //placeholder for spacing
        color : "transparent"
        Layout.row : 1
        Layout.column : 3
        Layout.preferredHeight : micWrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3
        Layout.fillHeight : true
      }
      
      //Row 3
      UIRadioButtonForm {
        id : severityRadioGroup
        Layout.row : 2
        Layout.column : 0
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.alignment : Qt.AlignVCenter
        prefWidth : grid.width / 5
        prefHeight : 75
        elementRatio : 0.4
        radioGroup.checkedButton : setButtonState()
        label.text : "Type"
        label.font.pointSize : 11
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ['Mild', 'Moderate', 'Severe']
        radioGroup.onClicked : {
          severity = button.buttonIndex
        }
        function setButtonState(){
          //Each time this item goes out of focus, it is destroyed (property of loader).  When we reload it, we want to make sure we incoprorate any data already set (e.g. left or right checked state)
          if (root.severity == -1){
            return null
          } else {
            return radioGroup.buttons[severity]
          }
        }
      }
      RowLayout {
        Layout.row : 2
        Layout.column : 1
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 5
        Layout.fillHeight : true
        spacing : 15
        Label {
          leftPadding : 5
          text : "Location"
          font.pixelSize : 15
        }      
        ComboBox {
          id : locationCombo
          currentIndex : setCurrentIndex()    //Need this because when loader changes source, this combo box is destroyed.  When it gets remade (reopened), we need to get root location to pick up where we left off.
          function setCurrentIndex(){
            for (let i = 0; i < model.length; ++i){
              if (model[i]===root.location){
                return i;
              }
            }
            return -1;
          }
          model : ['Gut', 'LeftArm','LeftLeg','RightArm','RightLeg']
          onActivated : {
            location = textAt(index)
          }
        }
      }
      Rectangle {
        Layout.row : 2
        Layout.column : 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 4
        color : "transparent"
        border.width : 0
        Button {
          text : "Set Action"
          opacity : validBuildConfig ? 1 : 0.4
          anchors.centerIn : parent
          height : parent.height * 0.6
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
        Layout.row : 2
        Layout.column : 3
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 4
        color : "transparent"
        border.width : 0
        Button {
          text : "Clear Fields"
          anchors.centerIn : parent
          height : parent.height * 0.6
          width : parent.width / 2
          onClicked : {
            grid.clear()
          }
        }
      }
    }
  } //end builder details component
}