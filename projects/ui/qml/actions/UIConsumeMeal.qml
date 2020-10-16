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

  property string actionType : "Consume Nutrients"
  actionClass : EventModel.ConsumeNutrients

  //Begin Action Properties
  property string name : "Default"
  property string sourceFile : ""
  property double carbs_g : 0
  property double fat_g : 0
  property double protein_g : 0
  property double calcium_mg : 0
  property double sodium_mg  : 0
  property double water_mL : 0
  property bool validBuildConfig : true   //No required fields and action does not have a duration

  fullName  : "<b>Consume <font color=\"lightsteelblue\">%1</font>  Meal</b>".arg(root.name)
  shortName : "<b>Consume Meal <font color=\"lightsteelblue\">%1</font> </b>".arg(root.name)

  //Builder mode data -- data passed to scenario builder
  buildParams : "Carboyhdrate=" + carbs_g + ",g;Fat=" + fat_g + ",g;Protein=" + protein_g + ",g;Calcium=" + calcium_mg + ",mg;Sodium=" + sodium_mg + ",mg;Water=" + water_mL + ",mL;";
  //Interactive mode -- apply action immediately while running
  onActivate:   { scenario.create_consume_meal_action(name, carbs_g, fat_g, protein_g, sodium_mg, calcium_mg, water_mL)  }
  onDeactivate: { }
  //End Action Properties
  property alias delayTimer : delayTimer

  Timer {
    id : delayTimer
    interval : 5000
    running : false
    repeat : false
    onTriggered : {
      if (root.active){
        root.active = false
      }
    }
  }

  controlsSummary : Component {
    RowLayout {
      id : actionRow
      spacing : 5
      height : childrenRect.height
      width : root.parent.width
      Label {
        id : actionLabel
        Layout.preferredWidth : parent.width * 2/4 - actionRow.spacing / 2
        color : '#1A5276'
        text : root.shortName
        elide : Text.ElideRight
        font.pointSize : builderMode ? 15 : 8
        font.bold : true
        horizontalAlignment  : Text.AlignLeft
        leftPadding : 5
        verticalAlignment : Text.AlignVCenter
        background : Rectangle {
            id : labelBackground
            anchors.fill : parent
            color : 'transparent'
            border.color : 'grey'
            border.width : 0
        }
        MouseArea {
            id : labelMouseArea
            anchors.fill : parent
            hoverEnabled : true
            propagateComposedEvents :true
            Timer {
              id : infoTimer
              interval: 500; running: false; repeat: false
              onTriggered:  actionTip.visible  = true
            }
            onEntered: {
              infoTimer.start()
              actionTip.visible  = false
            }
            onPositionChanged : {
              infoTimer.restart()
              actionTip.visible  = false
            }
            onExited : {
              infoTimer.stop()
              actionTip.visible  = false
            }
        }
        ToolTip {
          id : actionTip
          parent : actionLabel
          x : 0
          y : parent.height + 5
          visible : false
          text : root.fullName
          contentItem : Text {
            text : actionTip.text
            color : '#1A5276'
            font.pointSize : 10
          }
          background : Rectangle {
            color : "white"
            border.color : "black"
          }
        }
      }
      Rectangle {
        Layout.fillWidth : true
      }
      UIBioGearsButtonForm {
        id: toggle
        visible : !builderMode
        Layout.preferredWidth : parent.width * 1/4 - actionRow.spacing 
        Layout.rightMargin : 20
        Layout.preferredHeight : parent.height
        enabled : !root.active
        text : "Feed"
        MouseArea {
          id: mouseArea
          anchors.fill: parent
          enabled : !root.active
          onClicked: {
            root.active = true
            root.delayTimer.restart()
          }// emit
        }
      }
    }
  } // End Summary Component

  controlsDetails : Component  {
    GridLayout {
      id: grid
      columns : 4
      rows    : 8
      width : root.width -5
      anchors.centerIn : parent
      Label {
        font.pointSize : 12
        Layout.columnSpan : 4
        Layout.fillWidth : true
        color : "blue"
        text : "%1".arg(actionType)
        Layout.maximumHeight : root.parent.height / grid.rows
      }      
      //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
        text : "Carbohydrate (g)"
        Layout.maximumHeight : root.parent.height / grid.rows
        font.pointSize : 10
      }      
      Slider {
        id: carbSlider
        Layout.row : 1
        Layout.column : 1
        Layout.fillWidth : true
        Layout.maximumHeight : root.parent.height / grid.rows
        Layout.columnSpan : 2
        from : 0
        to : 300          //300 g is reasonable amount for one day
        stepSize : 5
        value : root.carbs_g

        onMoved : {
          root.carbs_g = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 1
        Layout.column : 3
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "%1".arg(root.carbs_g)
        font.pointSize : 10
      }
      //Column 3
      Label {
        Layout.row : 2
        Layout.column : 0
        text : "Fat (g)"
        Layout.maximumHeight : root.parent.height / grid.rows
        font.pointSize : 10
      }      
      Slider {
        id: fatSlider
        Layout.row : 2
        Layout.column : 1
        Layout.maximumHeight : root.parent.height / grid.rows
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 80          //80 g is reasonable amount for one day
        stepSize : 5
        value : root.fat_g

        onMoved : {
          root.fat_g = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 2
        Layout.column : 3
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "%1".arg(root.fat_g)
        font.pointSize : 10
      }
    //Column 4
      Label {
        Layout.row : 3
        Layout.column : 0
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "Protein (g)"
        font.pointSize : 10
      }      
      Slider {
        id: proteinSlider
        Layout.row : 3
        Layout.column : 1
        Layout.maximumHeight : root.parent.height / grid.rows
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 100          //60ish g is reasonable amount / day for sedentary person, bump up to 100 account for active
        stepSize : 5
        value : root.protein_g

        onMoved : {
          root.protein_g = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 3
        Layout.column : 3
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "%1".arg(root.protein_g)
        font.pointSize : 10
      }
      //Column 5
      Label {
        Layout.row : 4
        Layout.column : 0
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "Calcium (mg)"
        font.pointSize : 10
      }      
      Slider {
        id: calciumSlider
        Layout.row : 4
        Layout.column : 1
        Layout.fillWidth : true
        Layout.columnSpan : 2
        Layout.maximumHeight : root.parent.height / grid.rows
        from : 0
        to : 2000         //2000 mg is reasonable upper limit for one day
        stepSize : 100
        value : root.calcium_mg

        onMoved : {
          root.calcium_mg = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 4
        Layout.column : 3
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "%1".arg(root.calcium_mg)
        font.pointSize : 10
      }
      //Column 6
      Label {
        Layout.row : 5
        Layout.column : 0
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "Sodium (mg)"
        font.pointSize : 10
      }      
      Slider {
        id: sodiumSlider
        Layout.row : 5
        Layout.column : 1
        Layout.fillWidth : true
        Layout.columnSpan : 2
        Layout.maximumHeight : root.parent.height / grid.rows
        from : 0
        to : 3000         //3000 mg is more than recommended amount, but most people go above recommendations
        stepSize : 100
        value : root.sodium_mg

        onMoved : {
          root.sodium_mg = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 5
        Layout.column : 3
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "%1".arg(root.sodium_mg)
        font.pointSize : 10
      }
      //Column 7
      Label {
        Layout.row : 6
        Layout.column : 0
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "Water (mL)"
        font.pointSize : 10
      }      
      Slider {
        id: waterSlider
        Layout.row : 6
        Layout.column : 1
        Layout.fillWidth : true
        Layout.columnSpan : 2
        Layout.maximumHeight : root.parent.height / grid.rows
        from : 0
        to : 3000         //3000 mL is more than recommended amount per day
        stepSize : 100
        value : root.water_mL

        onMoved : {
          root.water_mL = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 6
        Layout.column : 3
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "%1".arg(root.water_mL)
        font.pointSize : 10
      }
      // Column 8
      Button {
        id : activate
        Layout.preferredHeight : root.parent.height / grid.rows
        Layout.rightMargin : 10
        Layout.row : 7
        Layout.column : 2
        Layout.columnSpan : 2
        enabled : !root.active
        text : "Feed"
        onClicked: {
          root.active = true
          root.delayTimer.restart()
        }
      }
    }
  }// End Details Component

   builderDetails : Component {
    id : builderDetails
    GridLayout {
      id: grid
      columns : 3
      rows : 5 
      width : root.width -5
      anchors.centerIn : parent
      columnSpacing : 15
      signal clear()
      onClear : {
        carbs_g = 0.0;
        fat_g = 0.0;
        protein_g = 0.0;
        sodium_mg = 0.0;
        calcium_mg = 0.0;
        water_mL = 0.0;
        fileCombo.currentIndex = -1
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
        text : "%1".arg(actionType) + "[%1]".arg(root.compartment)
      }    
      //Row 2
      RowLayout {
        id : fileWrapper
        Layout.row : 1
        Layout.column : 0
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3 - grid.columnSpacing * 2
        Layout.alignment : Qt.AlignHCenter
        Layout.fillHeight : true
        Label {
          leftPadding : 5
          text : "Source (optional)"
          font.pixelSize : 15
        }      
        ComboBox {
          id : fileCombo
          currentIndex : -1    //Need this because when loader changes source, this combo box is destroyed.  When it gets remade (reopened), we need to get root location to pick up where we left off.
          textRole : "file"
          model : null
          function setCurrentIndex(){
            let fileNames = scenario.get_nutrition();
            for (let i = 0; i < fileNames.length; ++i){
              if (fileNames[i]===root.sourceFile){
                return i;
              }
            }
            return -1;
          }
          onActivated : {
            sourceFile = textAt(index)
            //Load in data from file
            let l_nutritionInfo = scenario.load_nutrition_for_meal(sourceFile)
            carbs_g = l_nutritionInfo.Carbohydrate
            protein_g = l_nutritionInfo.Protein
            fat_g = l_nutritionInfo.Fat
            calcium_mg = l_nutritionInfo.Calcium
            sodium_mg = l_nutritionInfo.Sodium
            water_mL = l_nutritionInfo.Water
          }
          Component.onCompleted : {
            let listModel = Qt.createQmlObject("import QtQuick.Controls 2.12; import QtQuick 2.12; ListModel {}", fileCombo, 'ListModelErrorString')
            let modelData = scenario.get_nutrition()
            for (let i = 0; i < modelData.length; ++i){
              let element = { "file" : modelData[i] }
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
          Layout.fillWidth = true
          Layout.fillHeight = true
          Layout.maximumWidth = grid.width / 5
          Layout.alignment = Qt.AlignHCenter
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
        Layout.preferredHeight : fileWrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3
        Layout.fillHeight : true
      }
      //Row 3
      RowLayout {
        id : carbWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 0
        Layout.alignment : Qt.AlignHCenter
        Label {
          id : carbLabel
          leftPadding : 5
          text : "Carbs"
          font.pixelSize : 15
        }
        Slider {
          id: carbSlider
          Layout.fillWidth : true
          from : 0
          to : 300
          stepSize : 5
          value : root.carbs_g
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.carbs_g = value
          }
        }
        Label {
          text : "%1 g".arg(root.carbs_g)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : proteinWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 1
        Layout.alignment : Qt.AlignHCenter
        Label {
          id : proteinLabel
          leftPadding : 5
          text : "Protein"
          font.pixelSize : 15
        }
        Slider {
          id: proteinSlider
          Layout.fillWidth : true
          from : 0
          to : 100
          stepSize : 5
          value : root.protein_g
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.protein_g = value
          }
        }
        Label {
          text : "%1 g".arg(root.protein_g)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : fatWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 2
        Layout.alignment : Qt.AlignHCenter
        Label {
          id : fatLabel
          leftPadding : 5
          text : "Fat"
          font.pixelSize : 15
        }
        Slider {
          id: fatSlider
          Layout.fillWidth : true
          from : 0
          to : 80
          stepSize : 5
          value : root.fat_g
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.fat_g = value
          }
        }
        Label {
          text : "%1 g".arg(root.fat_g)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      //Row 4
      RowLayout {
        id : sodiumWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 3
        Layout.column : 0
        Layout.alignment : Qt.AlignHCenter
        Label {
          id : sodiumLabel
          leftPadding : 5
          text : "Sodium"
          font.pixelSize : 15
        }
        Slider {
          id: sodiumSlider
          Layout.fillWidth : true
          from : 0
          to : 3000
          stepSize : 25
          value : root.sodium_mg
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.sodium_mg = value
          }
        }
        Label {
          text : "%1 mg".arg(root.sodium_mg)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : calciumWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 3
        Layout.column : 1
        Layout.alignment : Qt.AlignHCenter
        Label {
          id : calciumLabel
          leftPadding : 5
          text : "Calcium"
          font.pixelSize : 15
        }
        Slider {
          id: calciumSlider
          Layout.fillWidth : true
          from : 0
          to : 2000
          stepSize : 25
          value : root.calcium_mg
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.calcium_mg = value
          }
        }
        Label {
          text : "%1 mg".arg(root.calcium_mg)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : waterWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 3
        Layout.column : 2
        Layout.alignment : Qt.AlignHCenter
        Label {
          id : waterLabel
          leftPadding : 5
          text : "Water"
          font.pixelSize : 15
        }
        Slider {
          id: waterSlider
          Layout.fillWidth : true
          from : 0
          to : 2000
          stepSize : 25
          value : root.water_mL
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.water_mL = value
          }
        }
        Label {
          text : "%1 mL".arg(root.water_mL)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      //Row 5
      Rectangle {
        //placeholder for spacing
        color : "transparent"
        Layout.row : 4
        Layout.column : 0
        Layout.preferredHeight : waterWrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3 - grid.columnSpacing * 2
        Layout.fillHeight : true
      }
      Rectangle {
        Layout.row : 4
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
        Layout.row : 4
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
  } //end builder details component
}