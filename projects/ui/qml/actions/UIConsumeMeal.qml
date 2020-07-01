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


  //Begin Action Properties
  property string name : "Default"
  property double carbohydrate_g : 1
  property double fat_g : 1
  property double protien_g : 1
  property double calcium_g : 1
  property double sodium_g  : 1
  property double water_ml : 1

  //End Action Properties
  property Timer delaytimer : root.delaytimer

  actionType : "Consume Meal"
  fullName  : "<b>Consume <font color=\"lightsteelblue\">%1</font>  Meal</b>".arg(root.name)
  shortName : "<b>Consume <font color=\"lightsteelblue\">%1</font> </b>".arg(root.name)

  Timer {
    id : delaytimer
    interval : 5000
    running : false
    repeat : false

    onTriggered : {
      root.active = false
    }
  }

  summary : Component {
    RowLayout {
      id : actionRow
      spacing : 5
      height : childrenRect.height
      width : root.width
      Label {
        id : actionLabel
        width : parent.width * 3/4 - actionRow.spacing / 2
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
        width  : 40
        height : 20
        text : "Feed"
        MouseArea {
          id: mouseArea
          anchors.fill: parent
          enabled : !root.active
          onClicked: {
            root.active = true
            delaytimer.running = true
          }// emit
        }
      }
    }
  } // End Summary Component

  details : Component {
    id : details

    GridLayout {
      id: grid
      columns : 4
      rows    : 15
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
        text : "[%1]".arg(root.name)
        Layout.alignment : Qt.AlignHCenter
      }
      
      //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
        text : "Carbohydrates"
      }
      Slider {
        id: carboydrates
    
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 500
        stepSize : 1
        value : root.carbohydrate_g

        onMoved : {
          root.carbohydrate_g = value
          if ( root.active )
            root.active = false;
        }
      }
      Label {
        text : "%1".arg(root.carbohydrate_g)
      }
      //Column 3
      Label {
        Layout.row : 2
        Layout.column : 0
        text : "Fat"
      }
      Slider {
        id: fat
    
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 500
        stepSize : 1
        value : root.fat_g

        onMoved : {
          root.fat_g = value
          if ( root.active )
            root.active = false;
        }
      }
      Label {
        text : "%1".arg(root.fat_g)
      }
      //Column 4
      Label {
        Layout.row : 3
        Layout.column : 0
        text : "Carbohydrates"
      }
      Slider {
        id: protien
    
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 500
        stepSize : 1
        value : root.protien_g

        onMoved : {
          root.protien_g = value
          if ( root.active )
            root.active = false;
        }
      }
      Label {
        text : "%1".arg(root.protien_g)
      }
      //Column 5
      Label {
        Layout.row : 4
        Layout.column : 0
        text : "Calcium"
      }
      Slider {
        id: calcium
    
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 500
        stepSize : 1
        value : root.calcium_g

        onMoved : {
          root.calcium_g = value
          if ( root.active )
            root.active = false;
        }
      }
      Label {
        text : "%1".arg(root.calcium_g)
      }
      //Column 6
      Label {
        Layout.row : 5
        Layout.column : 0
        text : "Sodium"
      }
      Slider {
        id: sodium
    
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 500
        stepSize : 1
        value : root.sodium_g

        onMoved : {
          root.sodium_g = value
          if ( root.active )
            root.active = false;
        }
      }
      Label {
        text : "%1".arg(root.sodium_g)
      }
      //Column 7
      Label {
        Layout.row : 6
        Layout.column : 0
        text : "Water"
      }
      Slider {
        id: water
    
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 500
        stepSize : 1
        value : root.water_ml

        onMoved : {
          root.water_ml = value
          if ( root.active )
            root.active = false;
        }
      }
      Label {
        text : "%1".arg(root.water_ml)
      }
      // Column 8
      Button {
        id : activate
        enabled : !root.active
        text : "Feed"
        onClicked: {
          root.active = true
          delaytimer.running = true
        }
      }
    }
  }// Details Component

  onActivate:   { console.log("Feeding the patient %1".arg(name));scenario.create_consume_nutrients(carbohydrate_g, fat_g, protien_g, calcium_g, sodium_g, water_ml)  }
  onDeactivate: {   }
}