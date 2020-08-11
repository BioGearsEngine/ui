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

  property string type : ""
  property double  weight : 0.0
  property double  property_1 : 0.0
  property double  property_2 : 0.0
  property bool validBuildConfig : {
    if (root.type==="Generic"){
      return ((property_1 > 0.0 || property_2 > 0.0) && actionStartTime_s > 0.0 && actionDuration_s > 0.0)
    } else if (root.type==="Strength"){
      return (weight > 0.0 && property_2 > 0.0 && actionStartTime_s > 0.0)
    } else {
      return (property_1 > 0.0 && property_2 > 0.0 && actionStartTime_s > 0.0 && actionDuration_s > 0.0)
    }
  }
    //Builder mode data -- data passed to scenario builder
  activateData : {
    if (builderMode){
      if (root.type==="Generic"){
        if (property_1 > 0.0){
          return {"name" : "Exercise-Generic", "time" : actionStartTime_s, "intensity" : property_1};
        } else {
          return {"name" : "Exercise-Generic", "time" : actionStartTime_s, "workRate" : property_2};
        }
      } else if (root.type==="Cycling"){
        return {"name" : "Exercise-Cycling", "time" : actionStartTime_s, "cadence" : property_1, "power" : property_2, "weight" : weight};
      } else if (root.type==="Running") {
        return {"name" : "Exercise-Running", "time" : actionStartTime_s, "velocity" : property_1, "incline" : property_2, "weight" : weight};
      } else { 
        return ({});
      }
    } else {
      return ({})
    }
  }
  deactivateData : {
    if (builderMode){
      if (root.type==="Generic"){
        if (property_1 > 0.0){
          return {"name" : "Exercise-Generic", "time" : actionStartTime_s + actionDuration_s, "intensity" : 0.0};
        } else {
          return {"name" : "Exercise-Generic", "time" : actionStartTime_s + actionDuration_s, "workRate" : 0.0};
        }
      } else if (root.type==="Cycling"){
        return {"name" : "Exercise-Cycling", "time" : actionStartTime_s + actionDuration_s, "cadence" : 0.0, "power" : 0.0, "weight" : 0.0};
      } else if (root.type==="Running") {
        return {"name" : "Exercise-Running", "time" : actionStartTime_s + actionDuration_s, "velocity" : 0.0, "incline" : 0.0, "weight" : 0.0};
      } else { 
        return {"name" : "Exercise-Strength", "time" : actionStartTime_s + actionDuration_s, "weight" : 0.0, "repetitions" : 0.0};
      }
    } else {
      return ({})
    }
  }
  //Interactive mode -- apply action immediately while running
  onActivate:   { 
    let type_v = 0
    if ( root.type == "Generic") {
      type_v = 0
    } else if ( root.type == "Cycling") {
      type_v = 1
    } else if ( root.type == "Running" ) {
      type_v = 2
    } else {
      type_v = 3
    }
    scenario.create_exercise_action(type_v, weight, property_1, property_2) 
  }
  onDeactivate: { 
      scenario.create_exercise_action(0, 0, 0, 0) 

  }

  actionType : "Exercise"
  //fullName  :  "<b>%1 %2</b><br>".arg(type).arg(actionType)
  fullName  : {
    let tmp =  "<b>%1 %2</b><br>".arg(type).arg(actionType)
    if (root.type == 'Generic') {
      if (root.property_1 > 0) {
		tmp += "<br> Desired Work Rate  %1 W".arg(root.property_1)
	  } else {
		tmp += "<br> Intensity  %1".arg(root.property_2)
	  }
    } else if ( root.type == 'Cycling') {
      tmp += "<br> Cadence %1 Hz<br> Power %2 W<br> WeightPack %3 kg".arg(root.property_1).arg(root.property_2).arg(root.weight)
    } else if ( root.type == 'Running') {
      tmp += "<br> Velocity %1 m/s<br> Incline %2 <br> WeightPack %3 kg".arg(root.property_1).arg(root.property_2).arg(root.weight)
    } else if ( root.type == 'Strength') {
      tmp += "<br> Weight %1 kg<br> Repetitions %2".arg(root.property_1).arg(root.property_2)
    }
    return tmp
  }
  shortName : "<font color=\"lightsteelblue\"> %2</font> <b>%1</b>".arg(actionType).arg(type)

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
        text : "[%1]".arg(root.type)
        Layout.alignment : Qt.AlignHCenter
      }
 //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
        text : {
          if ( root.type == "Generic") {
			return "Work Rate"
          } else if ( root.type == "Cycling") {
            return "Cadence"
          } else if ( root.type == "Running" ) {
            return "Velocity"
          } else {
            return "Weight"
          }
        }
      }      
      Slider {
        id: property_1
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 100
        stepSize : 1
        value : root.property_1
        onMoved : {
          root.property_1 = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : {
          if ( root.type == "Generic") {
            return "%1 W".arg(root.property_1)
          } else if ( root.type == "Cycling") {
            return "%1 Hz".arg(root.property_1)
          } else if ( root.type == "Running" ) {
            return "%1 m/s".arg(root.property_1)
          } else {
            return "%1 kg".arg(root.property_1)
          }
        }
      }
      //Column 3
      Label {
        Layout.row : 2
        Layout.column : 0
        text : {
          if ( root.type == "Generic") {
            return "Intensity"
          } else if ( root.type == "Cycling") {
            return "Power Cycle"
          } else if ( root.type == "Running" ) {
            return "Incline"
          } else {
            return "Repitition"
          }
        }
      }      
      Slider {
        id: property_2
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 100
        stepSize : 1
        value : root.property_2
        onMoved : {
          root.property_2 = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : {
           if ( root.type == "Generic") {
            return "%1".arg(property_2)
          } else if ( root.type == "Cycling") {
            return "%1 W".arg(root.property_2)
          } else if ( root.type == "Running" ) {
            return "%1".arg(root.property_2)
          } else {
            return "%1".arg(root.property_2)
          }
        }
      }
    //Column 4
      Label {
        Layout.row : 3
        Layout.column : 0
        text : "Weight"
        visible : ( root.type == "Running" || root.type == "Cycling") ? true : false
      }      
      Slider {
        id: weight_slider
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1000
        stepSize : 1
        value : root.weight
        visible : ( root.type == "Running" || root.type == "Cycling") ? true : false
        onMoved : {
          root.weight = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : "%1 kg".arg(weight)
        visible : ( root.type == "Running" || root.type == "Cycling") ? true : false
      }
    
      // Column 5
      Rectangle {
        id: toggle      
        Layout.row : 4
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
 
  Loader {
    id : exerciseLoader
    sourceComponent : root.summary
    state : "collapsed"
    states : [
       State {
          name : "expandedBuilder"
          PropertyChanges {target : exerciseLoader; sourceComponent : root.type==="Generic" ? genericBuilderDetails : (root.type==="Running" || root.type==="Cycling") ? cycleRunBuilderDetails : strengthBuilderDetails}
        }
        ,State {
          name: "collapsed"
          PropertyChanges { target : exerciseLoader; sourceComponent: root.summary}
        }
      ]
      MouseArea {
        id: actionMouseArea
        anchors.fill: parent
        z: -1
        acceptedButtons:  Qt.LeftButton | Qt.RightButton
      
        onDoubleClicked: { // Double Clicking Window
          if ( mouse.button === Qt.LeftButton ){
            if (exerciseLoader.state === "collapsed") {
              exerciseLoader.state = "expandedBuilder"
            } else {
              //Not allowing double click to expand right now -- use "Set Action" button instead so that we can check that action is defined in build mode
              //loader.state = "collapsed"
            }
          } else {
            mouse.accepted = false
          }
        }
      }
    Component.onCompleted : {
      viewLoader.state = "unset"   //"Unset" state in base loader class unloads anything that was already there
      viewLoader = exerciseLoader     //Reassign viewLoader property to use exercise Loader that will handle multiple views depending on drug admin type
    }
  }
 //----Component for Generic Exercise
 Component {
    id : genericBuilderDetails
    GridLayout {
      id: grid
      columns : 3
      rows : 3 
      width : root.width - 5
      anchors.centerIn : parent
      columnSpacing : 20
      rowSpacing : 15
      property int subType : root.property_1 > 0.0 ? 0 : root.property_2 > 0.0 ? 1 : -1      //0 = Intensity, 1 = Power
      onSubTypeChanged : {
        if (subType==0){
          property_2 = 0.0
        } else {
          property_1 = 0.0
        }
      }
      signal clear()
      onClear : {
        root.property_1 = 0.0
        root.property_2 = 0.0
        subType = -1
        typeRadioGroup.radioGroup.checkState = Qt.Unchecked
        startTimeLoader.item.clear()
        durationLoader.item.clear()
      }
      Label {
        id : actionLabel
        Layout.row : 0
        Layout.column : 0
        Layout.columnSpan : 3
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
      UIRadioButtonForm {
        id : typeRadioGroup
        Layout.row : 1
        Layout.column : 0
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3
        Layout.alignment : Qt.AlignVCenter | Qt.AlignHCenter
        prefWidth : grid.width / 3
        prefHeight : 50
        elementRatio : 0.25
        radioGroup.checkedButton : grid.subType == -1 ? null : radioGroup.buttons[grid.subType]
        label.text : "Input Type"
        label.font.pointSize : 11
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ['Intensity (0-1)', 'Power Output (W)']
        radioGroup.onClicked : {
          grid.subType = button.buttonIndex
        }
      }
      Loader {
        id : startTimeLoader
        sourceComponent : timeEntry
        onLoaded : {
          item.entryName = "Start Time"
          Layout.row = 1
          Layout.column = 1
          Layout.alignment = Qt.AlignLeft
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
      Loader {
        id : durationLoader
        sourceComponent : timeEntry
        onLoaded : {
          item.entryName = "Duration"
          Layout.row = 1
          Layout.column = 2
          Layout.alignment = Qt.AlignLeft
          Layout.fillWidth = true
          Layout.fillHeight = true
          Layout.maximumWidth = grid.width / 5
          if (actionDuration_s > 0.0){
            item.reload(actionDuration_s)
          }
        }
      }
      Connections {
        target : durationLoader.item
        onTimeUpdated : {
          root.actionDuration_s = seconds + 60 * minutes + 3600 * hours
        }
      }
      //Row 3
      RowLayout {
        id : inputWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing / 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 0
        Label {
          id : inputLabel
          leftPadding : 5
          text : grid.subType == 0 ? "Intensity" : grid.subType == 1 ? "Power" : ""
          font.pixelSize : 15
        }
        Slider {
          id: inputSlider
          Layout.fillWidth : true
          from : 0
          to : grid.subType==1 ? 1000 : 1
          stepSize : grid.subType ==1 ? 25 : 0.05
          value : grid.subType == 0 ? root.property_1 : grid.subType == 1 ? root.property_2 : 0
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            if (grid.subType==0){
              root.property_1 = value
            } else {
              root.property_2 = value
            }
          }
        }
        Label {
          text : grid.subType === 0 ? "%1".arg(root.property_1) : grid.subType ===1 ? "%1 W".arg(root.property_2) : ""
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      Rectangle {
        Layout.row : 2
        Layout.column : 1
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing / 2
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
              viewLoader.state = "collapsed"
              root.buildSet(root)
            }
          }
        }
      }
      Rectangle {
        Layout.row : 2
        Layout.column : 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing
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
  } //end generic builder component

  //----Component for Cycling/Running
 Component {
    id : cycleRunBuilderDetails
    GridLayout {
      id: grid
      columns : 4
      rows : 4 
      width : root.width - 5
      anchors.centerIn : parent
      columnSpacing : 20
      rowSpacing : 10
      signal clear()
      onClear : {
        root.property_1 = 0.0
        root.property_2 = 0.0
        root.weight = 0.0
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
        text : "%1".arg(actionType)
      }    
      //Row 2
      RowLayout {
        id : prop1Wrapper
        Layout.maximumWidth : grid.width / 2 - grid.columnSpacing / 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 1
        Layout.column : 0
        Layout.columnSpan : 2
        Label {
          id : prop1Label
          leftPadding : 5
          text : root.type === "Cycling" ? "Cadence" : "Velocity"
          font.pixelSize : 15
        }
        Slider {
          id: prop1Slider
          Layout.fillWidth : true
          from : 0
          to : root.type === "Cycling" ? 100.0 : 10.0
          stepSize : root.type === "Cycling" ? 5 : 0.5
          value : root.property_1
          Layout.alignment : Qt.AlignLeft
          onMoved : {
              root.property_1 = value     
          }
        }
        Label {
          text : root.type === "Cycling" ? "%1 RPM".arg(root.property_1) : "%1 m/s".arg(root.property_1)
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
          Layout.alignment = Qt.AlignLeft
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
      Loader {
        id : durationLoader
        sourceComponent : timeEntry
        onLoaded : {
          item.entryName = "Duration"
          Layout.row = 1
          Layout.column = 3
          Layout.alignment = Qt.AlignLeft
          Layout.fillWidth = true
          Layout.fillHeight = true
          Layout.maximumWidth = grid.width / 5
          if (actionDuration_s > 0.0){
            item.reload(actionDuration_s)
          }
        }
      }
      Connections {
        target : durationLoader.item
        onTimeUpdated : {
          root.actionDuration_s = seconds + 60 * minutes + 3600 * hours
        }
      }
      //Row 3
      RowLayout {
        id : prop2Wrapper
        Layout.maximumWidth : grid.width / 2 - grid.columnSpacing / 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 0
        Layout.columnSpan : 2
        Label {
          id : prop2Label
          leftPadding : 5
          text : root.type === "Cycling" ? "Power" : "Incline"
          font.pixelSize : 15
        }
        Slider {
          id: prop2Slider
          Layout.fillWidth : true
          from : 0
          to : root.type === "Cycling" ? 300 : 45
          stepSize : root.type === "Cycling" ? 10 : 1
          value : root.property_2
          Layout.alignment : Qt.AlignLeft
          onMoved : {
              root.property_2 = value
          }
        }
        Label {
          text : root.type === "Cycling" ? "%1 W".arg(property_2) : "%1 %".arg(property_2)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : weightWrapper
        Layout.maximumWidth : grid.width / 2 - grid.columnSpacing / 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 2
        Layout.columnSpan : 2
        Label {
          id : weightLabel
          leftPadding : 5
          text : "Weight Pack (opt)"
          font.pixelSize : 15
        }
        Slider {
          id: weightSlider
          Layout.fillWidth : true
          from : 0
          to : 50
          stepSize : 1
          value : root.weight
          Layout.alignment : Qt.AlignLeft
          onMoved : {
              root.weight = value
          }
        }
        Label {
          text : "%1 kg".arg(root.weight)
          font.pixelSize : 15
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
        Layout.preferredHeight : prop1Wrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3 - grid.columnSpacing / 2
        Layout.fillHeight : true
      }
      Rectangle {
        Layout.row : 3
        Layout.column : 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing / 2
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
              viewLoader.state = "collapsed"
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
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing
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
  } //end cycling/running builder component

  //----Component for Strength Training
 Component {
    id : strengthBuilderDetails
    GridLayout {
      id: grid
      columns : 3
      rows : 3 
      width : root.width - 5
      anchors.centerIn : parent
      columnSpacing : 20
      rowSpacing : 10
      signal clear()
      onClear : {
        root.property_2 = 0.0
        root.weight = 0.0
        startTimeLoader.item.clear()
        durationLoader.item.clear()
      }
      Label {
        id : actionLabel
        Layout.row : 0
        Layout.column : 0
        Layout.columnSpan : 3
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
        id : weightWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing / 3
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 1
        Layout.column : 0
        Label {
          id : prop1Label
          leftPadding : 5
          text : "Weight"
          font.pixelSize : 15
        }
        Slider {
          id: prop1Slider
          Layout.fillWidth : true
          from : 0
          to : 60 
          stepSize : 1
          value : root.weight
          Layout.alignment : Qt.AlignLeft
          onMoved : {
              root.weight = value     
          }
        }
        Label {
          text : "%1 kg".arg(root.weight)
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
          Layout.column = 1
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
        Layout.column : 2
        Layout.preferredHeight : weightWrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3
        Layout.fillHeight : true
      }
      //Row 3
      RowLayout {
        id : repsWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing / 3
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 0
        Label {
          id : repsLabel
          leftPadding : 5
          text : "Repetitions"
          font.pixelSize : 15
        }
        Slider {
          id: repsSlider
          Layout.fillWidth : true
          from : 0
          to : 50
          stepSize : 1
          value : root.property_2
          Layout.alignment : Qt.AlignLeft
          onMoved : {
              root.property_2 = value
          }
        }
        Label {
          text : property_2
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      Rectangle {
        Layout.row : 2
        Layout.column : 1
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing / 2
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
              viewLoader.state = "collapsed"
              root.buildSet(root)
            }
          }
        }
      }
      Rectangle {
        Layout.row : 2
        Layout.column : 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing
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
  } //end strength builder component

}