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

  property string actionType : "Consume Meal"

  //Begin Action Properties
  property string name : "Default"
  property double carbs_g : 0
  property double fat_g : 0
  property double protein_g : 0
  property double calcium_mg : 0
  property double sodium_mg  : 0
  property double water_mL : 0

  fullName  : "<b>Consume <font color=\"lightsteelblue\">%1</font>  Meal</b>".arg(root.name)
  shortName : "<b>Consume <font color=\"lightsteelblue\">%1</font> </b>".arg(root.name)
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

  summary : Component {
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
        font.pointSize : 8
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
      Button {
        id: toggle
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

  details : Component  {
    GridLayout {
      id: grid
      columns : 4
      rows    : 8
      width : root.width -5
      anchors.centerIn : parent
      Label {
        font.pixelSize : 10
        font.bold : true
        color : "blue"
        text : "%1".arg(actionType)
        Layout.maximumHeight : root.parent.height / grid.rows
      }      
      Label {
        font.pixelSize : 10
        font.bold : false
        color : "steelblue"
        text : "[%1]".arg(root.location)
        Layout.alignment : Qt.AlignHCenter
        Layout.maximumHeight : root.parent.height / grid.rows
      }
      //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
        text : "Carbohydrate (g)"
        Layout.maximumHeight : root.parent.height / grid.rows
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
      }
      //Column 3
      Label {
        Layout.row : 2
        Layout.column : 0
        text : "Fat (g)"
        Layout.maximumHeight : root.parent.height / grid.rows
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
      }
    //Column 4
      Label {
        Layout.row : 3
        Layout.column : 0
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "Protein (g)"
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
      }
      //Column 5
      Label {
        Layout.row : 4
        Layout.column : 0
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "Calcium (mg)"
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
      }
      //Column 6
      Label {
        Layout.row : 5
        Layout.column : 0
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "Sodium (mg)"
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
      }
      //Column 7
      Label {
        Layout.row : 6
        Layout.column : 0
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "Water (mL)"
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

  onActivate:   { scenario.create_consume_meal_action(name, carbs_g, fat_g, protein_g, sodium_mg, calcium_mg, water_mL)  }
  onDeactivate: { }
}