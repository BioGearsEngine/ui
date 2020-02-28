import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtCharts 2.3
import QtQml.Models 2.2


Rectangle {
  property alias view : consoleView
  property alias content : consoleArea
  property alias hScrollBar: consoleView.hScrollBar
  property alias vScrollBar: consoleView.vScrollBar
  
  id: root
  Layout.margins: 0
    ScrollView {
    id: consoleView
    property ScrollBar hScrollBar: ScrollBar.horizontal
    property ScrollBar vScrollBar: ScrollBar.vertical

    anchors.left : root.left
    anchors.right : root.right
    anchors.top : root.top
    height: root.height * .70

    TextArea {  
      id: consoleArea
      enabled : false
      height: root.height * .70
      textFormat : TextEdit.RichText
      text :"--> Results Here\n"
    }
  }

  RowLayout {
    id : inputRow
    anchors.top : consoleView.bottom
    anchors.left : root.left
    anchors.right : root.right 

    TextInput {
      id:input
      text :":\> Place Holder"
      clip:true
      Layout.maximumHeight : 25
      Layout.preferredHeight : 25
      Layout.fillWidth : true
    }
    Button {
      text : "Submit"
      Layout.fillWidth : true
      Layout.preferredWidth : 50
      Layout.maximumWidth  : 75
      Layout.maximumHeight : 25
    }
  }
}