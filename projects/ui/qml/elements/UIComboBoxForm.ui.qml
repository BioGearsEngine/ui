import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

/*
Brief:  A label and comboBox (dropdown menu) laid out in a row
*/

RowLayout {
  id: root
  //Properties -- used to customize look/functionality of component
  property real elementRatio : 0.5          //Element ratio used to adjust relative sizes of label and box. Default is to split available space evenly
  property real prefWidth : parent.width
  property real prefHeight
  property int colSpan : 1
  property int rowSpan : 1
  property bool required : true
  property bool available : true
  spacing : 20
  property string splitToken //When we use ComboBox with a FolderModel, we often want to only use part of file name.  fileBaseName property helps get rid of file type (like .xml), but sometimes there is still info appended to name that
                                            //we do not want to display (e.g. PatientState@0s vs PatientState).  This splitToken tells which character to split the file name at.  
  property bool folderModel : false
  //Property aliases -- used to access subcomponents outside form file
  property alias label: name
  property alias comboBox: value
  //Layout options
  Layout.preferredHeight : prefHeight ? prefHeight : root.implicitHeight   //If no preferred height, use implicit height determined by layout
  Layout.preferredWidth : prefWidth
  Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter

  //States
  state : "available" //Initial state is available
  states : [
    State {
      //When the field is available for input it is fully opaque and enabled
      name : "available" ; when : root.available
      PropertyChanges {target : name; opacity : 1.0; enabled : true}
      PropertyChanges {target : value; opacity : 1.0; enabled : true}
     },
    State {
      //When the field is unavailble for editing, turn down opacity ("ghost" out) and disable so that it cannot accept input
      name : "unavailable"; when : !root.avaialble
      PropertyChanges {target : name; opacity : 0.5; enabled : false}
      PropertyChanges {target : value; opacity : 0.5; enabled : false}
    }
    ]

  Label {
    id: name
    text: "Unset"
    Layout.fillHeight : true
    Layout.alignment : Qt.AlignVCenter
    verticalAlignment : Text.AlignVCenter
    horizontalAlignment : Text.AlignLeft
    font.pixelSize : 18
  }
  ComboBox {
    id: value
    Layout.maximumWidth : root.prefWidth * (1.0 - elementRatio)
    Layout.alignment : Qt.AlignRight | Qt.AlignVCenter
    Layout.fillWidth : true
    implicitHeight : 40
    topInset : 0
    bottomInset : 0
    padding : 0
    font.weight: Font.Medium
    font.pixelSize : 18
    editable: true 
    currentIndex : -1
    contentItem : Text {
      //Controls the look of text that is currently displayed in the combo box
      anchors.left : value.left
      width : value.width - indicator.width
      height : parent.height
      text : value.displayText
      font : value.font
      verticalAlignment : Text.AlignVCenter;
      horizontalAlignment : Text.AlignHCenter;
    }
    delegate : ItemDelegate {
      id : comboDelegate
      contentItem : Text {
        text : comboDelegate.setText()
        verticalAlignment : Text.AlignVCenter;
        horizontalAlignment : Text.AlignHCenter;
        font: value.font;
      }
      height : value.height
      width : parent.width
      highlighted : value.highlightedIndex === index;
      function setText(){
        if (!value.textRole){
          //Just an array of strings, so return modelData
          return modelData
        } else {
          if (root.splitToken){
            //ListModel with named roles and a delimiter we want to split on
            return model[value.textRole].split(root.splitToken)[0]
          }
          else {
            //ListModel with named roles
            return model[value.textRole]
          }
        }
      }
    }
    popup : Popup {
      y : value.height
      x : 0
      padding : 0
      width : value.width - value.indicator.width
      implicitHeight : contentItem.implicitHeight
      contentItem : ListView {
        clip : true
        implicitHeight : contentHeight
        model : value.popup.visible ? value.delegateModel : null
        currentIndex : value.highlightedIndex
      }
    }
    background : Rectangle {
      id : comboBackground
      border.color : "#2980b9"
      border.width : 1
    }
    indicator: Rectangle {
      id: indicator
      anchors.right : parent.right
      y: 0
      height : value.height
      width : height
      color : "#2980b9"
      border.color : "#2980b9"
      Image {
        source : "icons/comboIndicatorWhite.png"
        height : parent.height / 4
        fillMode : Image.PreserveAspectFit
        anchors.centerIn : parent
      }
     }
  }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/