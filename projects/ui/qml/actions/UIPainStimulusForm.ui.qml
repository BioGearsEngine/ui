import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0


Rectangle {
  id: root
  color: "transparent"
  border.color: "black"

  height : loader.height

  signal activate()
  signal deactivate()
  signal adjust( var list)

  property double intesity : 0.0
  property string location : "LeftArm"
  property bool enabled : false
  property bool collapsed : true
  Loader {
    id : loader

    Component {
      id : details
      Rectangle {
        height : 200
        width : root.width

        color : "red"
        border.color : "yellow"
      }
    }
    Component {
      id : summary
      Rectangle {
        height : 100
        width  : root.width

        color : "steelblue"
        border.color: "black"
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
      propagateComposedEvents : true

      onDoubleClicked: { // Double Clicking Window
        console.log("Double Clicked")
        if ( mouse.button === Qt.LeftButton ){
          console.log("Left Double Clicked")
          if ( loader.state === "collapsed") {
            console.log("Expanding")
            loader.state = "expanded"
          } else {
            console.log("Collapsing")
            loader.state = "collapsed"
          }
        } else {
          mouse.accepted = false
        }
      }
    }
  }
}