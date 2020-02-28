
import QtQuick 2.4
import QtQuick.Controls.Material 2.12
import QtCharts 2.3
import QtQml.Models 2.2

import com.biogearsengine.ui.scenario 1.0


LuaConsoleForm{
  id:root
  property LogForward feeds  

  onFeedsChanged : {
    feeds.messageReceived.connect(messageHandler)
  }

  function messageHandler(message){
    content.text += message
    scrollTo(Qt.Vertical,1.0)
    // flickableItem.contentX = flickableItem.contentWidth / 2 - width / 2
  }

  /**
  * @param type [Qt.Horizontal, Qt.Vertical]
  * @param ratio 1.0 to 1.0
  */
  function scrollTo(type, ratio) {
      var scrollFunc = function (bar, ratio) {
          bar.setPosition(ratio - bar.size)
      }
      switch(type) {
      case Qt.Horizontal:
          scrollFunc(root.hScrollBar, ratio)
          break;
      case Qt.Vertical:
          scrollFunc(root.vScrollBar, ratio)
          break;
      }
  }
}
