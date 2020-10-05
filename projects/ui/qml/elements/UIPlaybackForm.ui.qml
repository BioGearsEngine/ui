import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

ColumnLayout {
  id: root
  signal pauseClicked()
  signal playClicked()
  signal restartClicked()
  signal rateToggleClicked(int speed)

  property string simulationTime : "0:00:00"
  property alias rate : forward.rate
  property alias playing : pause_play.playing;
  property alias paused  : pause_play.paused;

  property alias resetButton : reset
  property alias simButton: pause_play
  property alias speedButton : forward

  RowLayout {
    spacing: 10
    implicitHeight : timeText.implicitHeight * 1.2 
    Layout.alignment : Qt.AlignHCenter
    Label {
      id : timeText
      text: "Time:"
      font.pixelSize : 15
    }
    Text {
      text: root.simulationTime
      font.pixelSize : 15
    }
  }
  RowLayout {
    spacing : 15
    UIBioGearsButtonForm {
      id: reset
      implicitHeight : 40
      implicitWidth : 75
      padding : 5
      text: "reset"
      display: AbstractButton.IconOnly
      contentItem : Image {
        id : resetImage
        fillMode : Image.PreserveAspectFit
        source: "icons/reset.png"
        height : 30
      }
      onClicked: {root.restartClicked()}
    }
    UIBioGearsButtonForm {
      id: pause_play
      implicitHeight : 40
      implicitWidth : 75
      padding : 5
      property bool playing : false;
      property bool paused  : false;
      text: "Simulate"
      display: AbstractButton.IconOnly
      contentItem : Image {
        id : pausePlayImage
        fillMode : Image.PreserveAspectFit
        source: "icons/play.png"
        height : 30
      }
      state : "Stopped"
      onClicked: {
        console.log("UIPlaybackForm %1 %2".arg(playing).arg(paused))
        if(playing) {
          if(paused){
             state = "Simulating"
          } else {
            state = "Paused"
          }
          root.pauseClicked()
        } else {
          state = "Simulating"
          root.playClicked()
        }
      }
      states: [
       State{
          name: "Stopped"
          PropertyChanges { target: pausePlayImage; source: "icons/play.png" }
          PropertyChanges { target: pause_play; text: "Play" }
          PropertyChanges { target: pause_play; playing: false }
          PropertyChanges { target: pause_play; paused: false }
       }
        ,State {
          name: "Simulating"
          PropertyChanges { target: pausePlayImage; source: "icons/pause.png" }
          PropertyChanges { target: pause_play; text: "Pause" }
          PropertyChanges { target: pause_play; playing: true }
          PropertyChanges { target: pause_play; paused: false }
          }
        ,State {
          name: "Paused"
          PropertyChanges { target: pausePlayImage; source: "icons/play.png" }
          PropertyChanges { target: pause_play; text: "Resume" }
          PropertyChanges { target: pause_play; playing: true }
          PropertyChanges { target: pause_play; paused: true }
        }
      ]
    }
    UIBioGearsButtonForm {
      id: forward
      implicitHeight : 40
      implicitWidth : 75
      property int rate : 1
      font.capitalization: Font.AllLowercase
      display: AbstractButton.IconOnly
      padding : 5
      contentItem : Image {
        id : forwardImage
        fillMode : Image.PreserveAspectFit
        source: "icons/clock-realtime.png"
        height : 30
      }
      state : "realtime"
      onClicked: {
        if(rate == 2) {
          state = "realtime"
        } else {
          state = "max"
        }
        root.rateToggleClicked(rate)
      }
      states: [
        State {
          name: "realtime"
          PropertyChanges { target: forwardImage; source: "icons/clock-realtime.png" }
          PropertyChanges { target: forward; rate: 1 }
        }
        ,State {
          name: "max"
          PropertyChanges { target: forwardImage; source: "icons/clock-max.png" }
          PropertyChanges { target: forward; rate: 2 }
        }
      ]
    }
  }
}

/*##^## Designer {
  D{i:0;height:62;width:271}
}
 ##^##*/
