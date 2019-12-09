import QtQuick 2.4
import QtQuick.Controls.Material 2.12

import com.biogearsengine.ui.scenario 1.0

GraphAreaForm {
  signal start()
  signal stop()
  signal pause()

  signal plotUpdates(PatientMetrics metrics)

  onStart : {
    console.log("GraphAreaForm " + "start")
  }

  onStop : {
    console.log("GraphAreaForm " + "stop")
  }

  onPause: {
    console.log("GraphAreaForm " + "pause")
  }

  onPlotUpdates: {
    console.log("Guess What Chicken Butt.")
  }
}
