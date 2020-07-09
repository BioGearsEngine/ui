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
  property real fontSize : 12
  property int colSpan : 1
  property int rowSpan : 1
  property bool required : true
  property bool available : true
  property string splitToken                //When we use ComboBox with a FolderModel, we often want to only use part of file name.  fileBaseName property helps get rid of file type (like .xml), but sometimes there is still info appended to name that
                                            //we do not want to display (e.g. PatientState@0s vs PatientState).  This splitToken tells which character to split the file name at.  
  //Property aliases -- used to access subcomponents outside form file
  property alias label: name
  property alias comboBox: value
  //Layout options
  Layout.preferredHeight : prefHeight ? prefHeight : root.implicitHeight   //If no preferred height, use implicit height determined by layout
  Layout.preferredWidth : prefWidth
  Layout.columnSpan : colSpan
  Layout.rowSpan : rowSpan
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
    Layout.maximumWidth : root.prefWidth * elementRatio
    Layout.fillWidth : true
    Layout.fillHeight : true
    Layout.maximumHeight : root.prefHeight ? root.prefHeight : -1    //If no preferred height, set to -1, which flags Qml Layout to use implicit maximum height
    text: "Unset"
    verticalAlignment : Text.AlignVCenter
    horizontalAlignment : Text.AlignHCenter
    font.pointSize: root.fontSize
  }
  ComboBox {
    id: value
    Layout.maximumWidth : root.prefWidth * (1.0 - elementRatio)
    Layout.fillWidth : true
    Layout.fillHeight : true
    Layout.maximumHeight : root.prefHeight ? root.prefHeight : -1     //If no preferred height, set to -1, which flags Qml Layout to use implicit maximum height
    font.weight: Font.Medium
    font.pointSize: root.fontSize
    editable: true 
    currentIndex : -1
    contentItem : Text {
      //Controls the look of text that is currently displayed in the combo box
      text : value.displayText
      font : value.font
      verticalAlignment : Text.AlignVCenter;
      horizontalAlignment : Text.AlignHCenter;
      anchors.fill : parent
    }
    delegate : ItemDelegate {
      //Controls the look of text in the combo box menu.  The 'textRole' property of ComboBox MUST be set by the instantiating item.  This property tells the menu which role
      //of the combo box model to display.  Ex:  A ListModel might have role called 'name', in which case you must set textRole : 'name' after setting the combo box model.
      //If splitToken is defined, we assume that we want everything up to the token (not after). For example: splitToken = '@' will output StandardMale from StandardMale@0s.  
      //If we ever want something after the token instead, we will need to revisit this code.
      contentItem : Text {
        text : splitToken ? model[value.textRole].split(splitToken)[0] : model[value.textRole]
        verticalAlignment : Text.AlignVCenter;
        horizontalAlignment : Text.AlignHCenter;
        font: value.font;
      }
      height : value.height
      width : parent.width
      highlighted : value.highlightedIndex === index;
    }
  }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/