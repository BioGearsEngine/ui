import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import com.biogearsengine.ui.scenario 1.0

Page {
  id : compoundWizard
  anchors.fill : parent
  property alias doubleValidator : doubleValidator
  property alias compoundDataModel : compoundDataModel 
  property alias compoundGridView : compoundGridView

  UIUnitScalarEntry {
    id : compoundName
    prefWidth : parent.width / 2 * 0.9
    prefHeight : 60 * 0.95
    anchors.top : parent.top
    anchors.horizontalCenter : parent.horizontalCenter
    label : "Compound Name"
    unit : ""
    type : "string"
    hintText : "Required*"
    onInputAccepted : {
      root.compoundName = input[0]
      if (root.editMode && !nameWarningFlagged){
        root.nameEdited()
        nameWarningFlagged = true
      }
    }
    Component.onCompleted : {
      root.onResetConfiguration.connect(function () { if (root.editMode) { setEntry ([root.resetName, ""]) } else { reset() } })
      root.onLoadConfiguration.connect(function () { setEntry([root.compoundName, ""]) } ) //Scalar Entry expects a value:unit combo, so pass as array
    }
  }

  GridView {
    id: compoundGridView
    clip : true
    width : parent.width
    height : targetGridHeight < maxGridHeight ? targetGridHeight : maxGridHeight
    model : compoundDataModel
    anchors.top : compoundName.bottom
    anchors.topMargin : 10
    anchors.left : parent.left
    anchors.right : parent.right
    currentIndex: -1
    property var targetGridHeight : (Math.floor(count / 2) + count % 2) * cellHeight
    property var maxGridHeight : parent.height - addComponent.height
    cellHeight : 70
    cellWidth : width / 2
    ScrollIndicator.vertical: ScrollIndicator { }
    delegate : Item {
      //Wrapping scalar entry in an item helps us center the rectangle inside the gridview cell.  If we tried to
      // anchor in center without this, every delegate instance would center itself in the middle of the view (not
      // the middle of the individual cell)
      id: delegateWrapper
      width : compoundGridView.cellWidth
      height : compoundGridView.cellHeight
      UISubstanceEntry {
        id : substanceEntryDelegate
        anchors.centerIn : parent
        prefWidth : compoundGridView.cellWidth * 0.875 //Tuned to get the remove icon to fit
        prefHeight : compoundGridView.cellHeight * 0.85
        unit : model.unit
        type : model.type
        hintText : model.hint
        entryValidator : doubleValidator
        Component.onCompleted : {
          setComponentList('All')    //Make sure the list of substances is populated
          root.onResetConfiguration.connect( function() { if (!root.editMode) { reset() } } )   //If "new" compound (!edit), then reset wipes out all data
          model.valid = Qt.binding(function() {return entry.validInput})
          if (root.editMode && model.name !== ""){
            let sub = model.name //Name is set to substance name when loading from file
            let concentration = compoundList[sub][0]
            let unit = compoundList[sub][1]
            setEntry([sub, concentration, unit])
          }
        }
        onInputAccepted : {
          //Returned "input" is an array [substance, concentration, unit]
          let substance = input[0]
          //If the name in the list model and the name in the data map are out of sync, we either changed the substance
          // name (and need to update the map key), or the substance has not been added to the map yet
          if (model.name!==substance){
            if (root.compoundList.hasOwnProperty(substance)){
              //Another component field has already set up this substance.  Do not allow duplicate collisions
              root.invalidConfiguration("Cannot define multiple components with the same substance name")
              substanceUpdateRejected(model.name)
            } else {
              if (root.compoundList.hasOwnProperty(model.name)){
                //This component field is mapped to the right place in the data map, but we changed the substance name
                //Delete map entry and reset to correct name
                delete root.compoundList[model.name]
              }
              let newComponent = {[substance] : input.slice(1,input.length)}
              Object.assign(root.compoundList, newComponent)
              compoundDataModel.set(index, {"name" : substance}) //Update List model name to match current substance
            }
          } else {
            //Substance name in data map in sync with list model.  Find sub in map and update values
            root.compoundList[substance] = input.slice(1, input.length)
          }
        }
      }
      Image {
        id: removeIcon
        source : "icons/remove.png"
        sourceSize.width : 10
        sourceSize.height: 10
        MouseArea {
          anchors.fill : parent
          cursorShape : Qt.PointingHandCursor
          acceptedButtons : Qt.LeftButton
          onClicked: {
            //Which substance are we removing?
            let substanceToRemove = compoundDataModel.get(index).name
            //If name is not empty, then we have previously added substance to data map and need to remove it
            if (substanceToRemove !== ""){
              delete compoundList[substanceToRemove]
            }
            //Remove entry from model
            compoundDataModel.remove(index)
          }
        }
      }
    }  
  }
  
  Rectangle {
    id : addComponent
    width: parent.width
    height : 40
    anchors.top : compoundGridView.bottom
    color : "transparent"
    Rectangle {
      id : lineRectangle
      width : parent.width - 60
      height : 2
      anchors.left : parent.left
      anchors.verticalCenter : parent.verticalCenter
      border.color : "black"
      color : "black"
    }
    Image {
      id: addIcon
      source : "icons/add.png"
      sourceSize.width : 30
      sourceSize.height: 30
      anchors.verticalCenter : parent.verticalCenter
      anchors.right : parent.right
      anchors.rightMargin : sourceSize.width / 2
      MouseArea {
        anchors.fill : parent
        cursorShape : Qt.PointingHandCursor
        acceptedButtons : Qt.LeftButton
        onClicked: {
          //Add element to model so that grid view displays it
          let newComponent = {name: "", unit: "concentration", type: "double", hint: "", valid: true}
          compoundDataModel.append(newComponent)
        }
      }
    }
  }

  DoubleValidator {
    id : doubleValidator
    bottom : 0
  }

  ListModel {
    id : compoundDataModel
  }
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 