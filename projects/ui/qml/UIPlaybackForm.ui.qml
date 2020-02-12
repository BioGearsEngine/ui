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
  property alias rate : foward.rate
  property alias playing : pause_play.playing;
  property alias paused  : pause_play.paused;

  property alias resetButton : reset
  property alias simButton: pause_play
  property alias speedButton : foward
  RowLayout {
    spacing: 10
    Label {
      text: "Time:"
    }
    Text {
      text: root.simulationTime
    }
    Text {
      text: "Data"
    }
  }

  RowLayout {

    Button {
        id: reset
        text: "reset"
        display: AbstractButton.IconOnly
        icon.source: "qrc:/icons/reset.png"
        icon.name: "terminate"
        icon.color: "transparent"
        onClicked: {root.restartClicked()}
    }
    Button {
      id: pause_play
      property bool playing : false;
      property bool paused  : false;
      text: "Simulate"
      display: AbstractButton.IconOnly
      icon.source: "qrc:/icons/play.png"
      icon.name: "simulate"
      icon.color: "transparent"
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
          PropertyChanges { target: pause_play; icon.source: "icons/play.png" }
          PropertyChanges { target: pause_play; icon.name: "Play" }
          PropertyChanges { target: pause_play; text: "Play" }
          PropertyChanges { target: pause_play; playing: false }
          PropertyChanges { target: pause_play; paused: false }
       }
        ,State {
          name: "Simulating"
          PropertyChanges { target: pause_play; icon.source: "icons/pause.png" }
          PropertyChanges { target: pause_play; icon.name: "Pause" }
          PropertyChanges { target: pause_play; text: "Pause" }
          PropertyChanges { target: pause_play; playing: true }
          PropertyChanges { target: pause_play; paused: false }
          }
        ,State {
          name: "Paused"
          PropertyChanges { target: pause_play; icon.source: "icons/play.png" }
          PropertyChanges { target: pause_play; icon.name: "Resume" }
          PropertyChanges { target: pause_play; text: "Resume" }
          PropertyChanges { target: pause_play; playing: true }
          PropertyChanges { target: pause_play; paused: true }
        }
      ]
    }

    Button {
      id: foward
      property int rate : 1
      text: "RateToggle"
      font.capitalization: Font.AllLowercase
      display: AbstractButton.IconOnly
      icon.source: "icons/clock-realtime.png"
      icon.name: "rate-toggle"
      icon.color: "transparent"
      Layout.preferredWidth: pause_play.width
      Layout.preferredHeight: pause_play.height
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
          PropertyChanges { target: foward; icon.source: "icons/clock-realtime.png" }
          PropertyChanges { target: foward; rate: 1 }
        }
        ,State {
          name: "max"
          PropertyChanges { target: foward; icon.source: "icons/clock-max.png" }
          PropertyChanges { target: foward; rate: 2 }
        }
      ]
    }
  }
}

/*##^## Designer {
  D{i:0;height:62;width:271}
}
 ##^##*/
