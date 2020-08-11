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

  property bool validBuildConfig : {
    if (root.adminRoute.includes("Bolus")){
      return (dose > 0.0 && concentration > 0.0 && drug !== "" && actionStartTime_s > 0.0)
    } else if (adminRoute==="Infusion"){
      return (rate > 0.0 && concentration > 0.0 && drug !== "" && actionStartTime_s > 0.0 && actionDuration_s > 0.0)
    } else {
      return (dose > 0.0 && drug !== "" && actionStartTime_s > 0.0)
    }
  }
  actionType : "Administration"
  fullName  : {
    let tmp =  "<b>%1 %2</b><br>".arg(adminRoute).arg(actionType)
    if (root.adminRoute == 'Bolus-Intraarterial' ||
           root.adminRoute == 'Bolus-Intramuscular' || 
           root.adminRoute == 'Bolus-Intravenous')
    {
      tmp += "<br> Dose %1 mL<br> Concentration %2ug/mL".arg(root.dose).arg(root.concentration)
    } else if ( root.adminRoute == 'Infusion-Intravenous') {
      tmp += "<br> Concentration %1 ug/mL<br> Concentration %2mL/min".arg(root.concentration).arg(root.rate)
    } else {
      tmp += "<br> Dose %1 mg".arg(root.dose)
    }
    return tmp
  }
  shortName : "<font color=\"lightsteelblue\"> %2</font> <b>%1</b>".arg(actionType).arg(drug)
 
  //Builder mode data -- data passed to scenario builder
  activateData : {
    if (builderMode){
      if (root.adminRoute.includes("Bolus") !== -1){
        return {"name" : root.adminRoute, "time" : actionStartTime_s, "drug" : drug, "dose" : dose, "concentration" : concentration};
      } else if (root.adminRoute.includes("Infusion")){
        return {"name" : root.adminRoute, "time" : actionStartTime_s, "drug" : drug, "rate" : rate, "concentration" : concentration};
      } else {
        return {"name" : root.adminRoute, "time" : actionStartTime_s, "drug" : drug, "dose" : dose};
      }
    } else {
      return ({})
    }
  }
  deactivateData : {
    if (builderMode){
      if (root.adminRoute.includes("Bolus") !== -1){
        return null;
      } else if (root.adminRoute.includes("Infusion")){
        return {"name" : root.adminRoute, "time" : actionStartTime_s + actionDuration_s, "drug" : drug, "rate" : 0.0, "concentration" : 0.0};
      } else {
        return null;
      }
    } else {
      return ({})
    }
  }
  //Interactive mode -- apply action immediately while running
  onActivate:   { 
    if (root.adminRoute == 'Bolus-Intraarterial' ) {
      scenario.create_substance_bolus_action(drug, 0, dose, concentration) 
    } else if ( root.adminRoute == 'Bolus-Intramuscular' ) {
      scenario.create_substance_bolus_action(drug, 1, dose, concentration) 
    } else if ( root.adminRoute == 'Bolus-Intravenous') {
      scenario.create_substance_bolus_action(drug, 2, dose, concentration) 
    }  else if ( root.adminRoute == 'Infusion-Intravenous') {
      scenario.create_substance_infusion_action(drug, concentration, rate) 
    } else if ( root.adminRoute == 'Oral') {
      scenario.create_substance_oral_action(drug, 0, dose) 
    } else {
      scenario.create_substance_oral_action(drug, 1, dose) 
    }
  }
  onDeactivate: { 
       if (root.adminRoute == 'Bolus-Intraarterial' ) {
      scenario.create_substance_bolus_action(drug, 0, 0, 0) 
    } else if ( root.adminRoute == 'Bolus-Intramuscular' ) {
      scenario.create_substance_bolus_action(drug, 1, 0, 0) 
    } else if ( root.adminRoute == 'Bolus-Intravenous') {
      scenario.create_substance_bolus_action(drug, 2, 0, 0) 
    }  else if ( root.adminRoute == 'Infusion-Intravenous') {
      scenario.create_substance_infusion_action(drug, 0, 0) 
    } else if ( root.adminRoute == 'Oral') {
      scenario.create_substance_oral_action(drug, 0, 0) 
    } else {
      scenario.create_substance_oral_action(drug, 1, 0) 
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
        font.pixelSize : 10
        font.bold : true
        color : "blue"
        text : "%1".arg(actionType)
      }      
      Label {
        font.pixelSize : 10
        font.bold : false
        color : "steelblue"
        text : "[%1]".arg(root.compartment)
        Layout.alignment : Qt.AlignHCenter
      }
 //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
        text : "Dose"
        visible : dosage.concentration
      }      
      Slider {
        id: dosage
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1000
        stepSize : 1
        value : root.dose

        visible :  (root.adminRoute!=  'Infusion-Intravenous') ?  true : false

        onMoved : {
          root.dose = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : {
              if (root.adminRoute == 'Bolus-Intraarterial' ||
                  root.adminRoute == 'Bolus-Intramuscular' || 
                  root.adminRoute == 'Bolus-Intravenous')
                return "%1 mL".arg(root.dose)
              else (root.adminRoute == 'Oral' || root.adminRoute == 'Transmucosal')
                return "%1 mg".arg(root.dose)
          }
          visible : dosage.concentration
      }
      //Column 3
      Label {
        Layout.row : 2
        Layout.column : 0
        text : "Concentration"
        visible : flowRate.concentration
      }      
      Slider {
        id: concentration
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1000
        stepSize : 1
        value : root.concentration
        visible : {
          if ( root.adminRoute == 'Oral' || root.adminRoute == 'Transmucosal') {
            return false;
          } else {
            return true;
          }
        }
        onMoved : {
          root.concentration = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : "%1 ug/mL".arg(root.concentration )
        visible : flowRate.concentration
      }
    //Column 4
      Label {
        Layout.row : 3
        Layout.column : 0
        text : "Flow Rate"
        visible : flowRate.visible
      }      
      Slider {
        id: flowRate
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1000
        stepSize : 1
        value : root.rate
        visible : {
          if ( root.adminRoute == 'Infusion-Intravenous' ) {
            return true;
          } else {
            return false;
          }
        }
        onMoved : {
          root.rate = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : "%1 ml/min".arg(root.rate )
        visible : flowRate.visible
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
  id : drugLoader
  sourceComponent : root.summary
  state : "collapsed"
  states : [
     State {
        name : "expandedBuilder"
        PropertyChanges {target : drugLoader; sourceComponent : root.adminRoute.includes("Bolus") ? bolusBuilderDetails : root.adminRoute.includes("Infusion") ? infusionBuilderDetails : oralBuilderDetails}
      }
      ,State {
        name: "collapsed"
        PropertyChanges { target : drugLoader; sourceComponent: root.summary}
      }
    ]
    MouseArea {
      id: actionMouseArea
      anchors.fill: parent
      z: -1
      acceptedButtons:  Qt.LeftButton | Qt.RightButton
      
      onDoubleClicked: { // Double Clicking Window
        if ( mouse.button === Qt.LeftButton ){
          if (drugLoader.state === "collapsed") {
            drugLoader.state = "expandedBuilder"
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
        subCombo.currentIndex = -1
        root.drug = ""
        root.dose = 0
        rote.concentration = 0
        root.adminRoute = "Bolus-"
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
          leftPadding : 5
          text : "Drug"
          font.pixelSize : 15
        }      
        ComboBox {
          id : subCombo
          currentIndex : -1    //Need this because when loader changes source, this combo box is destroyed.  When it gets remade (reopened), we need to get root location to pick up where we left off.
          textRole : "drug"
          model : null
          function setCurrentIndex(){
            let drugNames = scenario.get_drugs();
            for (let i = 0; i < drugNames.length; ++i){
              if (drugNames[i]===root.drug){
                return i;
              }
            }
            return -1;
          }
          onActivated : {
            root.drug = textAt(index)
          }
          Component.onCompleted : {
            let listModel = Qt.createQmlObject("import QtQuick.Controls 2.12; import QtQuick 2.12; ListModel {}", subCombo, 'ListModelErrorString')
            let modelData = scenario.get_drugs()
            for (let i = 0; i < modelData.length; ++i){
              let element = { "drug" : modelData[i] }
              listModel.append(element)
            }
            model = listModel
            currentIndex = setCurrentIndex()
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
          root.actionStartTime_s = seconds + 60 * minutes + 3600 * hours
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
        prefWidth : grid.width / 3
        prefHeight : 75
        elementRatio : 0.2
        radioGroup.checkedButton : setButtonState()
        label.text : "Route"
        label.font.pointSize : 11
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ['Intraarterial', 'Intramuscular', 'Intravenous']
        radioGroup.onClicked : {
          root.adminRoute = "Bolus-" + buttonModel[button.buttonIndex]
        }
        function setButtonState(){
          //Each time this item goes out of focus, it is destroyed (property of loader).  When we reload it, we want to make sure we incoprorate any data already set (e.g. left or right checked state)
          let bolusType = root.adminRoute.split("-")[1] //split at "-" should return array [Bolus, Type], and we want the second element
          for (let i = 0; i < buttonModel.length; ++i){
            if (bolusType===buttonModel[i]){
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
          font.pixelSize : 15
        }
        Slider {
          id: doseSlider
          Layout.fillWidth : true
          from : 0
          to : 50
          stepSize : 1
          value : root.dose
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.dose = value
          }
        }
        Label {
          text : "%1 mL".arg(root.dose)
          font.pixelSize : 15
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
          font.pixelSize : 15
        }
        Slider {
          id: concentrationSlider
          Layout.fillWidth : true
          from : 0
          to : 1000
          stepSize : 10
          value : root.concentration
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.concentration = value
          }
        }
        Label {
          text : "%1 ug/mL".arg(root.concentration)
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
              viewLoader.state = "collapsed"
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
        subCombo.currentIndex = -1
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
          leftPadding : 5
          text : "Drug"
          font.pixelSize : 15
        }      
        ComboBox {
          id : subCombo
          currentIndex : -1    //Need this because when loader changes source, this combo box is destroyed.  When it gets remade (reopened), we need to get root location to pick up where we left off.
          textRole : "drug"
          model : null
          function setCurrentIndex(){
            let drugNames = scenario.get_drugs();
            for (let i = 0; i < drugNames.length; ++i){
              if (drugNames[i]===root.drug){
                return i;
              }
            }
            return -1;
          }
          onActivated : {
            root.drug = textAt(index)
          }
          Component.onCompleted : {
            let listModel = Qt.createQmlObject("import QtQuick.Controls 2.12; import QtQuick 2.12; ListModel {}", subCombo, 'ListModelErrorString')
            let modelData = scenario.get_drugs()
            for (let i = 0; i < modelData.length; ++i){
              let element = { "drug" : modelData[i] }
              listModel.append(element)
            }
            model = listModel
            currentIndex = setCurrentIndex()
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
          root.actionStartTime_s = seconds + 60 * minutes + 3600 * hours
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
          root.actionDuration_s = seconds + 60 * minutes + 3600 * hours
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
          font.pixelSize : 15
        }
        Slider {
          id: rateSlider
          Layout.fillWidth : true
          from : 0
          to : 50
          stepSize : 1
          value : root.rate
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.rate = value
          }
        }
        Label {
          text : "%1 mL/min".arg(root.rate)
          font.pixelSize : 15
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
          font.pixelSize : 15
        }
        Slider {
          id: concentrationSlider
          Layout.fillWidth : true
          from : 0
          to : 1000
          stepSize : 10
          value : root.concentration
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.concentration = value
          }
        }
        Label {
          text : "%1 ug/mL".arg(root.concentration)
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
              viewLoader.state = "collapsed"
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
        subCombo.currentIndex = -1
        root.adminRoute = "Oral-"
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
          leftPadding : 5
          text : "Drug"
          font.pixelSize : 15
        }      
        ComboBox {
          id : subCombo
          currentIndex : -1    //Need this because when loader changes source, this combo box is destroyed.  When it gets remade (reopened), we need to get root location to pick up where we left off.
          textRole : "drug"
          model : null
          function setCurrentIndex(){
            let drugNames = scenario.get_drugs();
            for (let i = 0; i < drugNames.length; ++i){
              if (drugNames[i]===root.drug){
                return i;
              }
            }
            return -1;
          }
          onActivated : {
            root.drug = textAt(index)
          }
          Component.onCompleted : {
            let listModel = Qt.createQmlObject("import QtQuick.Controls 2.12; import QtQuick 2.12; ListModel {}", subCombo, 'ListModelErrorString')
            let modelData = scenario.get_drugs()
            for (let i = 0; i < modelData.length; ++i){
              let element = { "drug" : modelData[i] }
              listModel.append(element)
            }
            model = listModel
            currentIndex = setCurrentIndex()
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
        prefWidth : grid.width / 3
        prefHeight : 50
        elementRatio : 0.2
        radioGroup.checkedButton : setButtonState()
        label.text : "Route"
        label.font.pointSize : 11
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ['Gastrointestinal', 'Transmucosal']
        radioGroup.onClicked : {
          root.adminRoute = "Oral-" + buttonModel[button.buttonIndex]
        }
        function setButtonState(){
          //Each time this item goes out of focus, it is destroyed (property of loader).  When we reload it, we want to make sure we incoprorate any data already set (e.g. left or right checked state)
          let oralType = root.adminRoute.split("-")[1] //split at "-" should return array [Bolus, Type], and we want the second element
          return oralType === "Gastrointestinal" ? radioGroup.buttons[0] : oralType === "Transmucosal" ? radioGroup.buttons[1] : null
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
          text : "dose"
          font.pixelSize : 15
        }
        Slider {
          id: doseSlider
          Layout.fillWidth : true
          from : 0
          to : 2000
          stepSize : 25
          value : root.dose
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.dose = value
          }
        }
        Label {
          text : root.adminRoute === "Oral-Transmucosal" ? "%1 ug".arg(root.dose) : "%1 mg".arg(root.dose)
          font.pixelSize : 15
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