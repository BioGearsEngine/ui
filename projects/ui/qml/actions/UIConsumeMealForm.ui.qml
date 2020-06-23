import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

//NOTE: NOt Tested Needs Validation on Implementation of Consume Meal 
//      I think we should lock in digestion rate but allow people to increase/decrease portions
Rectangle {
  id: root
  color: "transparent"
  border.color: "black"
  height : loader.item.height

  signal activate()
  signal deactivate()
  signal remove( string uuid )
  signal adjust( var list)

  property double intensity : 0.0
  property string actionType : "Consume Meal"

  //Begin Action Properties
  property string name : "Default"
  property double carbohydrate_mass : 1
  property double fat_mass : 1
  property double protien_mass : 1
  property double calcium_mass : 1
  property double sodium_mass  : 1
  property double water_volume : 1

  property double carbohydrate_rate : 1
  property double fat_rate : 1
  property double protien_rate : 1
  //End Action Properties

  property string uuid : ""
  property bool active : false
  property bool collapsed : true

  property string fullName  : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>]".arg(actionType).arg(name)
  property string shortName : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>]<br/>Carbohdrate %3g<br/>Fat %4g<br/>Protien %5g<br/>Calcium %6g<br/>Socium %7g<br/>Water %8ml<br/>".arg(actionType).arg(name).arg(carbohydrate_mass).arg(fat_mass).arg(protien_mass).arg(calcium_mass).arg(sodium_mass).arg(water_volume)

  onActiveChanged : {
    if ( active) {
      console.log ("active")
      root.activate()
    } else {
      root.deactivate();
      console.log ("inactive")
    }
  }

  Loader {
    id : loader

    Component {
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
          id: stimulus
      
          Layout.fillWidth : true
          Layout.columnSpan : 2
          from : 0
          to : 10
          stepSize : 1
          value : root.intensity

          onMoved : {
            root.intensity = value
            if ( root.active )
               root.active = false;
          }
        }
        Label {
          text : "%1".arg(root.carbohydrate_mass)
        }
        //Column 3
        Label {
          Layout.row : 2
          Layout.column : 0
          text : "Fat"
        }
      
        Slider {
          id: stimulus
      
          Layout.fillWidth : true
          Layout.columnSpan : 2
          from : 0
          to : 10
          stepSize : 1
          value : root.intensity

          onMoved : {
            root.intensity = value
            if ( root.active )
               root.active = false;
          }
        }
        Label {
          text : "%1".arg(root.fat_mass)
        }
      //Column 4
        Label {
          Layout.row : 3
          Layout.column : 0
          text : "Carbohydrates"
        }
      
        Slider {
          id: stimulus
      
          Layout.fillWidth : true
          Layout.columnSpan : 2
          from : 0
          to : 10
          stepSize : 1
          value : root.intensity

          onMoved : {
            root.intensity = value
            if ( root.active )
               root.active = false;
          }
        }
        Label {
          text : "%1".arg(root.protien_mass)
        }
        
      //Column 5
        Label {
          Layout.row : 4
          Layout.column : 0
          text : "Calcium"
        }
      
        Slider {
          id: stimulus
      
          Layout.fillWidth : true
          Layout.columnSpan : 2
          from : 0
          to : 10
          stepSize : 1
          value : root.intensity

          onMoved : {
            root.intensity = value
            if ( root.active )
               root.active = false;
          }
        }
        Label {
          text : "%1".arg(root.calcium_mass)
        }
        //Column 6
        Label {
          Layout.row : 5
          Layout.column : 0
          text : "Sodium"
        }
      
        Slider {
          id: stimulus
      
          Layout.fillWidth : true
          Layout.columnSpan : 2
          from : 0
          to : 10
          stepSize : 1
          value : root.intensity

          onMoved : {
            root.intensity = value
            if ( root.active )
               root.active = false;
          }
        }
        Label {
          text : "%1".arg(root.sodium_mass)
        }
        //Column 7
        Label {
          Layout.row : 6
          Layout.column : 0
          text : "Water"
        }
      
        Slider {
          id: stimulus
      
          Layout.fillWidth : true
          Layout.columnSpan : 2
          from : 0
          to : 10
          stepSize : 1
          value : root.intensity

          onMoved : {
            root.intensity = value
            if ( root.active )
               root.active = false;
          }
        }
        Label {
          text : "%1".arg(root.water_volume)
        }
        
        // Column 8
        Button {
          id : activate
          onClicked: root.activate()
        }
      }

    }
    Component {
      id : summary
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
        Button {
          id : activate
          onClicked: root.activate()
        }
      }
    }
    sourceComponent : details
    state  : "expanded"

    states : [
      State {
        name: "expanded"
        PropertyChanges { target : loader; sourceComponent: details}
      }

      ,State {
        name: "collapsed"
        PropertyChanges { target : loader; sourceComponent: summary}
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
      }

      onDoubleClicked: { // Double Clicking Window
        if ( mouse.button === Qt.LeftButton ){
          if ( loader.state === "collapsed") {
            loader.state = "expanded"
          } else {
            loader.state = "collapsed"
          }
        } else {
          mouse.accepted = false
        }
      }

      Menu {
        id : contextMenu
        MenuItem {
          text : (loader.state === "collapsed")? "Configure" : "Collapse"
           onTriggered: {
             if ( loader.state === "collapsed"){
               loader.state = "expanded"
             } else {
               loader.state = "collapsed"
             }

           }
        }
        MenuItem {
          text : "Remove"
           onTriggered: {
            root.deactivate()
            root.remove( root.uuid )
           }
        }
      }
    }
  }
  Component.onCompleted : {
    console.log(width,height)
  }
}