import QtQuick 2.4
import QtQuick.Controls.Material 2.12

GraphAreaForm {
  signal start()
  signal stop()
  signal pause()

  onStart : {
    console.log("GraphAreaForm " + "start")
    graph1.timerOn = true
    graph2.timerOn = true
    graph3.timerOn = true
  }

  onStop : {
    console.log("GraphAreaForm " + "stop")
    graph2.clear()
    graph3.clear()
    graph1.clear()
  }

  onPause: {
    console.log("GraphAreaForm " + "pause")
    graph1.timerOn = false
    graph2.timerOn = false
    graph3.timerOn = false
  }
}
