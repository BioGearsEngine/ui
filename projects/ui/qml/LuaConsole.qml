
import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtCharts 2.3
import QtQml.Models 2.2

import com.biogearsengine.ui.scenario 1.0


LuaConsoleForm{
  id:root
  property LogForward feeds  

  function clear() {
     content.text = ""
  }

  onFeedsChanged : {
    feeds.messageReceived.connect(messageHandler)
  }

  Component.onCompleted : {
    scrollTo(Qt.Vertical,1.0)
  }

  onHeightChanged : {
    scrollTo(Qt.Vertical,1.0)
  }
  function messageHandler(message){
    content.text += message + "\n"
    scrollTo(Qt.Vertical,1.0)
  }

  /**
  * @param type [Qt.Horizontal, Qt.Vertical]
  * @param ratio 1.0 to 1.0
  */
  function scrollTo(type, ratio) {
      var scrollFunc = function (bar, ratio) {
          bar.position = ratio - bar.size
      }
      scrollFunc(view.ScrollBar.vertical, ratio)
  }
}
