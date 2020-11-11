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

  property string adminRoute : ""
  property double  dose : 0.0
  property double  concentration : 0.0
  property double rate : 0.0
  property string drug : ""
  property string subClass_str : actionSubClass === EventModel.SubstanceBolus ? "Bolus" : actionSubClass === EventModel.SubstanceInfusion ? "Infusion" : "Oral"

  property bool validBuildConfig : {
    if (actionSubClass === EventModel.SubstanceBolus){
      return (dose > 0.0 && concentration > 0.0 && drug !== "")
    } else if (actionSubClass === EventModel.SubstanceInfusion){
      return (rate > 0.0 && concentration > 0.0 && drug !== "" && actionDuration_s > 0.0)
    } else if (actionSubClass === EventModel.SubstanceOralDose){
      return (dose > 0.0 && drug !== "")
    } else {
      return false
    }
  }
  actionType : "Administration"
  actionClass : EventModel.SubstanceAdministration
  fullName  : {
    if (actionSubClass === EventModel.SubstanceBolus){
      return "<b>%1</b><br>".arg(subClass_str + "-" + adminRoute) + "<br> Dose %1 mL<br> Concentration %2ug/mL".arg(root.dose).arg(root.concentration)
    } else if (actionSubClass === EventModel.SubstanceInfusion) {
      return "<b>%1</b><br>".arg(subClass_str) + "<br> Concentration %1 ug/mL<br> Rate %2mL/min".arg(root.concentration).arg(root.rate)
    } else if (actionSubClass === EventModel.SubstanceOralDose && root.adminRoute.includes("Transmucosal")){
      return "<b>%1</b><br>".arg(subClass_str + "-" + adminRoute) + "<br> Dose %1 ug".arg(root.dose)
    } else if (actionSubClass === EventModel.SubstanceOralDose && root.adminRoute.includes("Gastrointenstinal")){
      return "<b>%1</b><br>".arg(subClass_str + "-" + adminRoute) + "<br> Dose %1 mg".arg(root.dose)
    } else {
      return ""
    }
  }
  shortName : "<font color=\"lightsteelblue\"> %2</font> <b>%1</b>".arg(actionType).arg(drug)
 
  //Builder mode data -- data passed to scenario builder
  buildParams : {
    if (actionSubClass === EventModel.SubstanceBolus){
      return "Substance=" + drug + ";Route=" + adminRoute + ";Concentration=" + concentration + ",ug/mL;Dose=" + dose + ",mL;";
    } else if (actionSubClass === EventModel.SubstanceInfusion){
      return "Substance=" + drug + ";Concentration=" + concentration + ",ug/mL;Rate=" + rate + ",mL/min;";
    } else if (actionSubClass === EventModel.SubstanceOralDose && root.adminRoute.includes("Transmucosal")) {
      return "Substance=" + drug + ";Dose=" + dose + ",ug;Route=" + root.adminRoute + ";";
    } else if (actionSubClass === EventModel.SubstanceOralDose && root.adminRoute.includes("Gastrointestinal")){
      return "Substance=" + drug + ";Dose=" + dose + ",mg;Route=" + root.adminRoute + ";";
    } else {
      return ""
    }
  }
  //Interactive mode -- apply action immediately while running
  onActivate:   { 
    if (root.actionSubClass === EventModel.SubstanceBolus){
      if (root.adminRoute == 'Intraarterial' ) {
        scenario.create_substance_bolus_action(drug, 0, dose, concentration) 
      } else if ( root.adminRoute == 'Intramuscular' ) {
        scenario.create_substance_bolus_action(drug, 1, dose, concentration) 
      } else if ( root.adminRoute == 'Intravenous') {
        scenario.create_substance_bolus_action(drug, 2, dose, concentration) 
      }
    }  else if (root.actionSubClass === EventModel.SubstanceInfusion) {
      scenario.create_substance_infusion_action(drug, concentration, rate) 
    } else if (root.actionSubClass === EventModel.SubstanceBolus){
      if ( root.adminRoute == 'Gastrointestinal') {
        scenario.create_substance_oral_action(drug, 0, dose) 
      } else {
        scenario.create_substance_oral_action(drug, 1, dose) 
      }
    }
  }
  onDeactivate: { 
    if (root.actionSubClass === EventModel.SubstanceInfusion) {
      scenario.create_substance_infusion_action(drug, 0, 0) 
    }
  }

  controlsDetails : Component  {
    GridLayout {
      id: grid
      columns : 4
      rows    : 4
      width : root.width -5
      anchors.centerIn : parent      
      Label {
        font.pointSize : 12
        Layout.columnSpan : 4
        Layout.fillWidth : true
        font.bold : true
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Drug %1 [%2]".arg(subClass_str).arg(root.drug)
      }      
 //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Dose"
        visible : root.actionSubClass === EventModel.SubstanceBolus || root.actionSubClass === EventModel.SubstanceOralDose
        font.pointSize  : 10
      }      
      Slider {
        id: dosage
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1000
        stepSize : 1
        value : root.dose
        visible :  root.actionSubClass === EventModel.SubstanceBolus || root.actionSubClass === EventModel.SubstanceOralDose
		background: Rectangle {
			x: dosage.leftPadding
			y: dosage.topPadding + dosage.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: dosage.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: dosage.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: dosage.leftPadding + dosage.visualPosition * (dosage.availableWidth - width)
			y: dosage.topPadding + dosage.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: dosage.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.dose = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : {
          if (root.adminRoute == 'Intraarterial' ||
              root.adminRoute == 'Intramuscular' || 
              root.adminRoute == 'Intravenous'){
            return "%1 mL".arg(root.dose)
          }
          else if  (root.adminRoute == 'Gastrointestinal'){
            return "%1 mg".arg(root.dose)
          } else if (root.adminRoute == 'Transmucosal'){
            return "%1 ug".arg(root.dose)
          }
          return ""
        }
        font.pointSize : 10
		Layout.leftMargin : 5
		color : "#34495e"
        visible : root.actionSubClass === EventModel.SubstanceBolus || root.actionSubClass === EventModel.SubstanceOralDose
      }
      //Column 3
      Label {
        Layout.row : 2
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Concentration"
        visible : root.actionSubClass === EventModel.SubstanceBolus || root.actionSubClass === EventModel.SubstanceInfusion
        font.pointSize : 10
      }      
      Slider {
        id: concentration
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1000
        stepSize : 1
        value : root.concentration
        visible : root.actionSubClass === EventModel.SubstanceBolus || root.actionSubClass === EventModel.SubstanceInfusion
		background: Rectangle {
			x: concentration.leftPadding
			y: concentration.topPadding + concentration.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: concentration.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: concentration.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: concentration.leftPadding + concentration.visualPosition * (concentration.availableWidth - width)
			y: concentration.topPadding + concentration.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: concentration.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.concentration = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
		Layout.leftMargin : 5
		color : "#34495e"
        text : "%1 ug/mL".arg(root.concentration )
        visible : root.actionSubClass === EventModel.SubstanceBolus || root.actionSubClass === EventModel.SubstanceInfusion
        font.pointSize : 10
     }
    //Column 4
      Label {
        Layout.row : 3
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Flow Rate"
        visible : root.actionSubClass === EventModel.SubstanceInfusion
        font.pointSize : 10
      }      
      Slider {
        id: flowRate
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1000
        stepSize : 1
        value : root.rate
        visible : root.actionSubClass === EventModel.SubstanceInfusion
		background: Rectangle {
			x: flowRate.leftPadding
			y: flowRate.topPadding + flowRate.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: flowRate.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: flowRate.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: flowRate.leftPadding + flowRate.visualPosition * (flowRate.availableWidth - width)
			y: flowRate.topPadding + flowRate.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: flowRate.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.rate = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
		Layout.leftMargin : 5
		color : "#34495e"
        text : "%1 ml/min".arg(root.rate )
        visible : root.actionSubClass === EventModel.SubstanceInfusion
        font.pointSize : 10
      }
    
      // Column 5
      Rectangle {
        id: toggle      
        Layout.row : 4
        Layout.column : 2
        Layout.columnSpan : 2
        Layout.fillWidth : true
        implicitHeight : 30   
        Layout.maximumWidth : grid.width / 4   
		Layout.bottomMargin : 5
		radius : pill.width*0.6
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
			radius : pill.width*0.6
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
  id : drugLoader
  sourceComponent : root.controlsSummary
  state : "collapsedControls"
  states : [
    State {
      name: "expandedControls"
      PropertyChanges { target : drugLoader; sourceComponent: root.controlsDetails}
      PropertyChanges { target : root; collapsed : false}
    }
    ,State {
      name: "collapsedControls"
      PropertyChanges { target : drugLoader; sourceComponent: root.controlsSummary}
      PropertyChanges { target : root; collapsed : true}
    }
    ,State {
      name : "expandedBuilder"
      PropertyChanges {target : drugLoader; sourceComponent : root.actionSubClass === EventModel.SubstanceBolus ? bolusBuilderDetails : root.actionSubClass === EventModel.SubstanceInfusion ? infusionBuilderDetails : oralBuilderDetails}
      PropertyChanges { target : root; collapsed : false}
    }
    ,State {
      name: "collapsedBuilder"
      PropertyChanges { target : drugLoader; sourceComponent: root.builderSummary}
      PropertyChanges { target : root; collapsed : true}
      AnchorChanges { target : drugLoader; anchors.horizontalCenter : root.horizontalCenter}
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
          if ( drugLoader.state === "collapsedBuilder") {
            drugLoader.state = "expandedBuilder"
            root.editing(root.modelIndex)
          }
        } else {
          if ( drugLoader.state === "collapsedControls") {
            drugLoader.state = "expandedControls"
          } else {
            drugLoader.state = "collapsedControls"
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
          text : (drugLoader.state === "collapsedControls")? "Configure" : "Collapse"
          font.pointSize : root.builderMode ? 10 : 6
          onTriggered: {
            //Only using this in controls instance (not in builder mode)
            if (!builderMode) {
              if ( drugLoader.state === "collapsedControls") {
                drugLoader.state = "expandedControls"
              } else {
                drugLoader.state = "collapsedControls"
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
      viewLoader = drugLoader     //Reassign viewLoader property to use drug Loader that will handle multiple views depending on drug admin type
  }
 }
 //----Component for Bolus View in Scenario Builder
 Component {
    id : bolusBuilderDetails
    GridLayout {
      id: grid
      columns : 3
      rows : 4 
      width : root.width - 5
      anchors.centerIn : parent
      columnSpacing : 20
      signal clear()
      onClear : {
        drugCombo.item.currentIndex = -1
        root.drug = ""
        root.dose = 0
        root.concentration = 0
        root.adminRoute = ""
        bolusRadioGroup.radioGroup.checkState = Qt.Unchecked
        startTimeLoader.item.clear()
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
        id : subWrapper
        Layout.row : 1
        Layout.column : 0
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3
        Layout.alignment : Qt.AlignLeft
        Layout.fillHeight : true
        spacing  : 30
        Label {
          id : drugLabel
          leftPadding : 5
          text : "Drug"
          font.pixelSize : 18
        }      
        Loader {
          id : drugCombo
          sourceComponent : comboInput
          property var _combo_model : scenario.get_drugs()
          property var _initial_value : root.drug
          Layout.fillWidth : true
          Layout.maximumWidth : grid.width / 3 - drugLabel.width - parent.spacing
        }
        Connections {
          target : drugCombo.item
          onActivated : {
            root.drug = target.textAt(target.currentIndex)
          }
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
      Rectangle {
        //placeholder for spacing
        color : "transparent"
        Layout.row : 1
        Layout.column : 2
        Layout.preferredHeight : subWrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3 - grid.columnSpacing * 2
        Layout.fillHeight : true
      }
      
      //Row 3
      UIRadioButtonForm {
        id : bolusRadioGroup
        Layout.row : 2
        Layout.column : 0
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3
        Layout.alignment : Qt.AlignVCenter
        Layout.preferredWidth : grid.width / 3
        Layout.preferredHeight : 75
        elementRatio : 0.2
        radioGroup.checkedButton : setButtonState()
        label.text : "Route"
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ['Intraarterial', 'Intramuscular', 'Intravenous']
        radioGroup.onClicked : {
          root.adminRoute = buttonModel[button.buttonIndex]
        }
        function setButtonState(){
          //Each time this item goes out of focus, it is destroyed (property of loader).  When we reload it, we want to make sure we incoprorate any data already set (e.g. left or right checked state)
          for (let i = 0; i < buttonModel.length; ++i){
            if (root.adminRoute===buttonModel[i]){
              return radioGroup.buttons[i]
            }
          }
          return null
        }
      }
      RowLayout {
        id : doseWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 1
        Label {
          id : doseLabel
          leftPadding : 5
          text : "Dose"
          font.pixelSize : 18
        }
        Slider {
          id: doseSlider
          Layout.fillWidth : true
          from : 0
          to : 50
          stepSize : 1
          value : root.dose
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
			x: doseSlider.leftPadding
			y: doseSlider.topPadding + doseSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: doseSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: doseSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: doseSlider.leftPadding + doseSlider.visualPosition * (doseSlider.availableWidth - width)
			y: doseSlider.topPadding + doseSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: doseSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
          onMoved : {
            root.dose = value
          }
        }
        Label {
          text : "%1 mL".arg(root.dose)
          font.pixelSize : 18
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : concentrationWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 2
        Label {
          id : concentrationLabel
          text : "Concentration"
          font.pixelSize : 18
        }
        Slider {
          id: concentrationSlider
          Layout.fillWidth : true
          from : 0
          to : 1000
          stepSize : 10
          value : root.concentration
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
			x: concentrationSlider.leftPadding
			y: concentrationSlider.topPadding + concentrationSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: concentrationSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: concentrationSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: concentrationSlider.leftPadding + concentrationSlider.visualPosition * (concentrationSlider.availableWidth - width)
			y: concentrationSlider.topPadding + concentrationSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: concentrationSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
          onMoved : {
            root.concentration = value
          }
        }
        Label {
          text : "%1 ug/mL".arg(root.concentration)
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
        Layout.preferredHeight : doseWrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3 - grid.columnSpacing * 2
        Layout.fillHeight : true
      }
      Rectangle {
        Layout.row : 3
        Layout.column : 1
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
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
        Layout.column : 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
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
  } //end Bolus View builder component

  //----Component for Infusion View in Scenario Builder
 Component {
    id : infusionBuilderDetails
    GridLayout {
      id: grid
      columns : 6
      rows : 4 
      width : root.width - 5
      anchors.centerIn : parent
      columnSpacing : 20
      signal clear()
      onClear : {
        drugCombo.item.currentIndex = -1
        root.drug = ""
        root.rate = 0
        root.concentration = 0
        startTimeLoader.item.clear()
        durationLoader.item.clear()
      }
      Label {
        id : actionLabel
        Layout.row : 0
        Layout.column : 0
        Layout.columnSpan : 6
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
        id : subWrapper
        Layout.row : 1
        Layout.column : 0
        Layout.columnSpan : 2
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3 - grid.columnSpacing * 2
        Layout.alignment : Qt.AlignLeft
        Layout.fillHeight : true
        spacing  : 30
        Label {
          id : drugLabel
          leftPadding : 5
          text : "Drug"
          font.pixelSize : 18
        }      
        Loader {
          id : drugCombo
          sourceComponent : comboInput
          property var _combo_model : scenario.get_drugs()
          property var _initial_value : root.drug
          Layout.fillWidth : true
          Layout.maximumWidth : grid.width / 3 - drugLabel.width - parent.spacing
        }
        Connections {
          target : drugCombo.item
          onActivated : {
            root.drug = target.textAt(target.currentIndex)
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
          Layout.columnSpan = 2
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
          Layout.column = 4
          Layout.columnSpan = 2
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
        id : rateWrapper
        Layout.maximumWidth : grid.width / 2 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 0
        Layout.columnSpan : 3
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
          to : 50
          stepSize : 1
          value : root.rate
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
			x: rateSlider.leftPadding
			y: rateSlider.topPadding + rateSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: rateSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: rateSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: rateSlider.leftPadding + rateSlider.visualPosition * (rateSlider.availableWidth - width)
			y: rateSlider.topPadding + rateSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: rateSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
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
        id : concentrationWrapper
        Layout.maximumWidth : grid.width / 2 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 3
        Layout.columnSpan : 3
        Layout.alignment : Qt.AlignRight
        Label {
          id : concentrationLabel
          text : "Concentration"
          font.pixelSize : 18
        }
        Slider {
          id: concentrationSlider
          Layout.fillWidth : true
          from : 0
          to : 1000
          stepSize : 10
          value : root.concentration
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
			x: concentrationSlider.leftPadding
			y: concentrationSlider.topPadding + concentrationSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: concentrationSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: concentrationSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: concentrationSlider.leftPadding + concentrationSlider.visualPosition * (concentrationSlider.availableWidth - width)
			y: concentrationSlider.topPadding + concentrationSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: concentrationSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
          onMoved : {
            root.concentration = value
          }
        }
        Label {
          text : "%1 ug/mL".arg(root.concentration)
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
        Layout.preferredHeight : rateWrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3 - grid.columnSpacing * 2
        Layout.fillHeight : true
      }
      Rectangle {
        Layout.row : 3
        Layout.column : 2
        Layout.columnSpan : 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
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
        Layout.column : 4
        Layout.columnSpan : 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
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
  } //end Infusion View builder component

   //----Component for Oral Admin View in Scenario Builder
 Component {
    id : oralBuilderDetails
    GridLayout {
      id: grid
      columns : 3
      rows : 3 
      width : root.width - 5
      anchors.centerIn : parent
      columnSpacing : 20
      rowSpacing : 15
      signal clear()
      onClear : {
        drugCombo.item.currentIndex = -1
        root.adminRoute = ""
        root.drug = ""
        root.dose = 0.0
        startTimeLoader.item.clear()
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
        id : subWrapper
        Layout.row : 1
        Layout.column : 0
        Layout.columnSpan : 1
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3 - grid.columnSpacing * 2
        Layout.alignment : Qt.AlignLeft
        Layout.fillHeight : true
        spacing  : 30
        Label {
          id : drugLabel
          leftPadding : 5
          text : "Drug"
          font.pixelSize : 18
        }      
        Loader {
          id : drugCombo
          sourceComponent : comboInput
          property var _combo_model : scenario.get_drugs()
          property var _initial_value : root.drug
          Layout.fillWidth : true
          Layout.maximumWidth : grid.width / 3 - drugLabel.width - parent.spacing
        }
        Connections {
          target : drugCombo.item
          onActivated : {
            root.drug = target.textAt(target.currentIndex)
          }
        }
      }
      UIRadioButtonForm {
        id : routeRadioGroup
        Layout.row : 1
        Layout.column : 1
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.alignment : Qt.AlignVCenter | Qt.AlignHCenter
        Layout.preferredWidth : grid.width / 3
        Layout.preferredHeight : 75
        elementRatio : 0.2
        radioGroup.checkedButton : setButtonState()
        label.text : "Route"
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ['Gastrointestinal', 'Transmucosal']
        radioGroup.onClicked : {
          root.adminRoute = buttonModel[button.buttonIndex]
        }
        function setButtonState(){
          //Each time this item goes out of focus, it is destroyed (property of loader).  When we reload it, we want to make sure we incoprorate any data already set (e.g. left or right checked state)
          return adminRoute === "Gastrointestinal" ? radioGroup.buttons[0] : oralType === "Transmucosal" ? radioGroup.buttons[1] : null
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
          root.actionStartTime_s = totalTime_s
        }
      }
      
      //Row 3
      RowLayout {
        id : doseWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 0
        Label {
          id : doseLabel
          leftPadding : 5
          text : "Dose"
          font.pixelSize : 18
        }
        Slider {
          id: doseSlider
          Layout.fillWidth : true
          from : 0
          to : 2000
          stepSize : 25
          value : root.dose
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
			x: doseSlider.leftPadding
			y: doseSlider.topPadding + doseSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: doseSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: doseSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: doseSlider.leftPadding + doseSlider.visualPosition * (doseSlider.availableWidth - width)
			y: doseSlider.topPadding + doseSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: doseSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
          onMoved : {
            root.dose = value
          }
        }
        Label {
          text : root.adminRoute === "Transmucosal" ? "%1 ug".arg(root.dose) : "%1 mg".arg(root.dose)
          font.pixelSize : 18
          Layout.alignment : Qt.AlignLeft
        }
      }
      Rectangle {
        Layout.row : 2
        Layout.column : 1
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
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
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
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
  } //end Bolus View builder component
}