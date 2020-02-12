import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

/*
Brief:  A label and comboBox (dropdown menu) laid out in a row
*/

RowLayout {
  id: root

  property alias label: name
  property alias comboBox: value
  property real elementRatio : 0.5    //Element ratio used to adjust relative sizes of label and box. Default is to split available space evenly
  property string splitToken          //When we use ComboBox with a FolderModel, we often want to only use part of file name.  fileBaseName property helps get rid of file type (like .xml), but sometimes there is still info appended to name that
                                      //we do not want to display (e.g. PatientState@0s vs PatientState).  This splitToken tells which character to split the file name at.  
  Layout.preferredWidth : parent.width
  

  Label {
    id: name
    Layout.preferredWidth : root.Layout.preferredWidth * elementRatio
    Layout.fillWidth : true
    Layout.fillHeight : true
    text: "Unset"
    font.pointSize: 10
    font.weight: Font.DemiBold
    font.bold: false
  }

  ComboBox {
    id: value
    Layout.preferredWidth : root.Layout.preferredWidth * (1.0 - elementRatio)
    Layout.fillWidth : true
    Layout.fillHeight : true
    font.weight: Font.Medium
    font.pointSize: 10
    editable: true 
    contentItem : Text {
      //Controls the look of text that is currently displayed in the combo box
      text : value.displayText
      font : value.font
      verticalAlignment : Text.AlignVCenter;
      horizontalAlignment : Text.AlignHCenter;
    }
    delegate : ItemDelegate {
      //Controls the look of text in the combo box menu.  The 'textRole' property of ComboBox MUST be set by the instantiating item.  This property tells the menu which role
      //of the combo box model to display.  Ex:  A ListModel might have role called 'name', in which case you must set textRole : 'name' after setting the combo box model.
      //If splitToken is defined, we assume that we want everything up to the token (not after). For example: splitToken = '@' will output StandardMale from StandardMale@0s.  
      //If we ever want something after the token instead, we will need to revisit this code.
      width : parent.width;
      text : splitToken ? model[value.textRole].split(splitToken)[0] : model[value.textRole]
      contentItem : Text {
        text : parent.text
        verticalAlignment : Text.AlignVCenter;
        horizontalAlignment : Text.AlignHCenter;
        font: value.font;
      }
      height : value.height
      highlighted : value.highlightedIndex === index;
    }
  }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
