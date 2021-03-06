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
  property int genericSubType : -1  //0 = Intensity, 1 = Power
  property double  weight : 0.0
  property double  property_1 : 0.0
  property double  property_2 : 0.0
  property bool validBuildConfig : {
    if (root.type==="Generic"){
      return ((property_1 > 0.0 || property_2 > 0.0) && actionDuration_s > 0.0)
    } else if (root.type==="Strength"){
      return (weight > 0.0 && property_2 > 0.0)
    } else {
      return (property_1 > 0.0 && property_2 > 0.0 && actionDuration_s > 0.0)
    }
  }
    //Builder mode data -- data passed to scenario builder
  buildParams : {
    if (root.type==="Generic"){
      if (property_1 > 0.0){
        return "Intensity=" + property_1 + ";";
      } else {
        return "DesiredWorkRate=" + property_2 + ";";
      }
    } else if (root.type==="Cycling"){
      return "Cadence=" + property_1 + ",1/min;Power=" + property_2 + ",W;AddedWeight=" + weight + ",kg;"
    } else if (root.type==="Running") {
      return "Speed=" + property_1 + ",m/s;Incline=" + property_2+";AddedWeight=" + weight+",kg;"
    } else { 
      return "Weight=" + weight + ",kg;Repetitions=" + property_2 + ";";
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
  actionClass : EventModel.Exercise
  actionSubClass :  {
    if (root.type == 'Generic') {
      return EventModel.GenericExercise
    } else if ( root.type == 'Cycling') {
      return EventModel.CyclingExercise
    } else if ( root.type == 'Running') {
      return EventModel.RunningExercise
    } else {
      return EventModel.StrengthExercise
    }
  }
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
        Layout.leftMargin : 5
		color : "#34495e"
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
		Layout.leftMargin : 5
		color : "#34495e"
        visible : {
          if (root.type === "Generic"){
            return root.property_1 > 0.0
          } else {
            return true;
          }
        }
        text : {
          if ( root.type == "Generic") {
			      return "Intensity"
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
        Layout.row : 1
        Layout.column : 1
        Layout.fillWidth : true
        Layout.columnSpan : 2
        visible : {
          if (root.type === "Generic"){
            return root.property_1 > 0.0
          } else {
            return true;
          }
        }
        from : 0
        to : 100
        stepSize : 1
        value : root.property_1
		background: Rectangle {
			x: property_1.leftPadding
			y: property_1.topPadding + property_1.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: property_1.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: property_1.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: property_1.leftPadding + property_1.visualPosition * (property_1.availableWidth - width)
			y: property_1.topPadding + property_1.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: property_1.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.property_1 = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 1
        Layout.column : 3
		Layout.leftMargin : 5
		color : "#34495e"
        visible : {
          if (root.type === "Generic"){
            return root.property_1 > 0.0
          } else {
            return true;
          }
        }
        text : {
          if ( root.type == "Generic") {
            return "%1".arg(root.property_1)
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
		Layout.leftMargin : 5
		color : "#34495e"
        visible : {
          if (root.type === "Generic"){
            return root.property_2 > 0.0
          } else {
            return true;
          }
        }
        text : {
          if ( root.type == "Generic") {
            return "Work"
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
        Layout.row : 2
        Layout.column : 1
        Layout.columnSpan : 2
        visible : {
          if (root.type === "Generic"){
            return root.property_2 > 0.0
          } else {
            return true;
          }
        }
        from : 0
        to : 100
        stepSize : 1
        value : root.property_2
		background: Rectangle {
			x: property_2.leftPadding
			y: property_2.topPadding + property_2.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: property_2.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: property_2.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: property_2.leftPadding + property_2.visualPosition * (property_2.availableWidth - width)
			y: property_2.topPadding + property_2.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: property_2.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.property_2 = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 2
        Layout.column : 3
		Layout.leftMargin : 5
		color : "#34495e"
        visible : {
          if (root.type === "Generic"){
            return root.property_2 > 0.0
          } else {
            return true;
          }
        }
        text : {
           if ( root.type == "Generic") {
            return "%1 W".arg(root.property_2)
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
		Layout.leftMargin : 5
		color : "#34495e"
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
		background: Rectangle {
			x: weight_slider.leftPadding
			y: weight_slider.topPadding + weight_slider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: weight_slider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: weight_slider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: weight_slider.leftPadding + weight_slider.visualPosition * (weight_slider.availableWidth - width)
			y: weight_slider.topPadding + weight_slider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: weight_slider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.weight = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
		Layout.leftMargin : 5
		color : "#34495e"
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
		Layout.bottomMargin : 5		
		radius: pill.width*0.6
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
            radius: pill.width*0.6  
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
    sourceComponent : root.controlsSummary
    state : "collapsedControls"
    states : [
      State {
        name: "expandedControls"
        PropertyChanges { target : exerciseLoader; sourceComponent: root.controlsDetails}
        PropertyChanges { target : root; collapsed : false}
      }
      ,State {
        name: "collapsedControls"
        PropertyChanges { target : exerciseLoader; sourceComponent: root.controlsSummary}
        PropertyChanges { target : root; collapsed : true}
      }
      ,State {
        name : "expandedBuilder"
        PropertyChanges {target : exerciseLoader; sourceComponent : root.type==="Generic" ? genericBuilderDetails : (root.type==="Running" || root.type==="Cycling") ? cycleRunBuilderDetails : strengthBuilderDetails}
        PropertyChanges { target : root; collapsed : false}
      }
      ,State {
        name: "collapsedBuilder"
        PropertyChanges { target : exerciseLoader; sourceComponent: root.builderSummary}
        PropertyChanges { target : root; collapsed : true}
        AnchorChanges { target : exerciseLoader; anchors.horizontalCenter : root.horizontalCenter}
      }
    ]
    MouseArea {
      id: actionMouseArea
      anchors.fill: parent
      z: -1
      acceptedButtons:  Qt.LeftButton | Qt.RightButton
      onClicked : {
        if ( mouse.button == Qt.RightButton) {
          contextMenu.popup()
        }
        selected(root.modelIndex)
      }
      onDoubleClicked: { // Double Clicking Window
        if ( mouse.button === Qt.LeftButton ){
          if (builderMode){
            if ( exerciseLoader.state === "collapsedBuilder") {
              exerciseLoader.state = "expandedBuilder"
              root.editing(root.modelIndex)
            }
          } else {
            if ( exerciseLoader.state === "collapsedControls") {
              exerciseLoader.state = "expandedControls"
            } else {
              exerciseLoader.state = "collapsedControls"
            }
          }
        } else {
          mouse.accepted = false
        }
      }
      Menu {
      id : contextMenu
      MenuItem {
          visible : !builderMode
          height : builderMode ? 0 : removeItem.height
          text : (exerciseLoader.state === "collapsedControls")? "Configure" : "Collapse"
          font.pointSize : root.builderMode ? 10 : 6
          onTriggered: {
            //Only using this in controls instance (not in builder mode)
            if (!builderMode) {
              if ( exerciseLoader.state === "collapsedControls") {
                exerciseLoader.state = "expandedControls"
              } else {
                exerciseLoader.state = "collapsedControls"
              }
            }
          }
        }
      MenuItem {
        id : removeItem
        text : "Remove"
        font.pointSize : root.builderMode ? 10 : 6
        onTriggered: {
          root.remove( root.uuid )
        }
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
      property int subType : root.genericSubType     //0 = Intensity, 1 = Power
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
        root.genericSubType = -1
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
        Layout.preferredWidth: grid.width / 3
        Layout.preferredHeight : 50
        elementRatio : 0.35
        radioGroup.checkedButton : grid.subType == -1 ? null : radioGroup.buttons[grid.subType]
        label.text : "Input Type"
        label.font.pointSize : 13
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ['Intensity (0-1)', 'Power Output (W)']
        radioGroup.onClicked : {
          root.genericSubType = button.buttonIndex
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
          root.actionStartTime_s = totalTime_s
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
          root.actionDuration_s = totalTime_s
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
          font.pixelSize : 18
        }
        Slider {
          id: inputSlider
          Layout.fillWidth : true
          from : 0
          to : grid.subType==1 ? 1000 : 1
          stepSize : grid.subType ==1 ? 25 : 0.05
          value : grid.subType == 0 ? root.property_1 : grid.subType == 1 ? root.property_2 : 0
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
			x: inputSlider.leftPadding
			y: inputSlider.topPadding + inputSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: inputSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: inputSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: inputSlider.leftPadding + inputSlider.visualPosition * (inputSlider.availableWidth - width)
			y: inputSlider.topPadding + inputSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: inputSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
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
          font.pixelSize : 18
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
              viewLoader.state = "collapsedBuilder"
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
          font.pixelSize : 18
        }
        Slider {
          id: prop1Slider
          Layout.fillWidth : true
          from : 0
          to : root.type === "Cycling" ? 100.0 : 10.0
          stepSize : root.type === "Cycling" ? 5 : 0.5
          value : root.property_1
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
			x: prop1Slider.leftPadding
			y: prop1Slider.topPadding + prop1Slider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: prop1Slider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: prop1Slider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: prop1Slider.leftPadding + prop1Slider.visualPosition * (prop1Slider.availableWidth - width)
			y: prop1Slider.topPadding + prop1Slider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: prop1Slider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
          onMoved : {
              root.property_1 = value     
          }
        }
        Label {
          text : root.type === "Cycling" ? "%1 RPM".arg(root.property_1) : "%1 m/s".arg(root.property_1)
          font.pixelSize : 18
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
          root.actionStartTime_s = totalTime_s
        }
      }
      Loader {
        id : durationLoader
        sourceComponent : timeEntry
        onLoaded : {
          item.entryName = "Duration"
          Layout.row = 1
          Layout.column = 3
          Layout.alignment = Qt.AlignHCenter
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
          root.actionDuration_s = totalTime_s
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
          font.pixelSize : 18
        }
        Slider {
          id: prop2Slider
          Layout.fillWidth : true
          from : 0
          to : root.type === "Cycling" ? 300 : 45
          stepSize : root.type === "Cycling" ? 10 : 1
          value : root.property_2
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
			x: prop2Slider.leftPadding
			y: prop2Slider.topPadding + prop2Slider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: prop2Slider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: prop2Slider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: prop2Slider.leftPadding + prop2Slider.visualPosition * (prop2Slider.availableWidth - width)
			y: prop2Slider.topPadding + prop2Slider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: prop2Slider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
          onMoved : {
              root.property_2 = value
          }
        }
        Label {
          text : root.type === "Cycling" ? "%1 W".arg(property_2) : "%1 %".arg(property_2)
          font.pixelSize : 18
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
          font.pixelSize : 18
        }
        Slider {
          id: weightSlider
          Layout.fillWidth : true
          from : 0
          to : 50
          stepSize : 1
          value : root.weight
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
			x: weightSlider.leftPadding
			y: weightSlider.topPadding + weightSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: weightSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: weightSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: weightSlider.leftPadding + weightSlider.visualPosition * (weightSlider.availableWidth - width)
			y: weightSlider.topPadding + weightSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: weightSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
          onMoved : {
              root.weight = value
          }
        }
        Label {
          text : "%1 kg".arg(root.weight)
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
          font.pixelSize : 18
        }
        Slider {
          id: prop1Slider
          Layout.fillWidth : true
          from : 0
          to : 60 
          stepSize : 1
          value : root.weight
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
			x: prop1Slider.leftPadding
			y: prop1Slider.topPadding + prop1Slider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: prop1Slider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: prop1Slider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: prop1Slider.leftPadding + prop1Slider.visualPosition * (prop1Slider.availableWidth - width)
			y: prop1Slider.topPadding + prop1Slider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: prop1Slider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
          onMoved : {
              root.weight = value     
          }
        }
        Label {
          text : "%1 kg".arg(root.weight)
          font.pixelSize : 18
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
          root.actionStartTime_s = totalTime_s
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
		  background: Rectangle {
			x: repsSlider.leftPadding
			y: repsSlider.topPadding + repsSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: repsSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: repsSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: repsSlider.leftPadding + repsSlider.visualPosition * (repsSlider.availableWidth - width)
			y: repsSlider.topPadding + repsSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: repsSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
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
              viewLoader.state = "collapsedBuilder"
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