import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtCharts 2.3
import QtQml.Models 2.2


Rectangle {
  property alias view : consoleView
  property alias content : consoleArea

  id: root
  Layout.margins: 0
    ScrollView {
    id: consoleView

    anchors.left : root.left
    anchors.right : root.right
    anchors.top : root.top
    height: root.height * .93
    
    // contentWidth : consoleArea.contentWidth

    TextArea {  
      id: consoleArea
      height: root.height * .93
      width : root.width
      readOnly : true
      textFormat : TextEdit.RichText
      placeholderText :"--> Results Here\n"
    }
  }
  //Removing Until we have real LUA Scripting
  // RowLayout {
  //   id : inputRow
  //   anchors.top : consoleView.bottom
  //   anchors.left : root.left
  //   anchors.right : root.right 

  //   TextInput {
  //     id:input
  //     text :":\> Place Holder"
  //     clip:true
  //     Layout.maximumHeight : 25
  //     Layout.preferredHeight : 25
  //     Layout.fillWidth : true
  //   }
  //   Button {
  //     text : "Submit"
  //     Layout.fillWidth : true
  //     Layout.preferredWidth : 50
  //     Layout.maximumWidth  : 75
  //     Layout.maximumHeight : 25
  //   }
  // }
}