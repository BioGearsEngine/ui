import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

Page {
  id : compoundWizard
  anchors.fill : parent
  property alias doubleValidator : doubleValidator
  property alias fractionValidator : fractionValidator
  property alias environmentDataModel : environmentDataModel
  property alias ambientGasListModel : ambientGasListModel 
  property alias aerosolListModel : aerosolListModel
  property alias environmentGridView : environmentGridView
  property alias ambientGasGridView : ambientGasGridView
 // property alias aerosolGridView : aerosolGridView

  GridView {
    id: environmentGridView
    clip : true
    model : environmentDataModel
    anchors.top : parent.top
    anchors.left : parent.left
    anchors.right : parent.right
    width : parent.width
    height : cellHeight * Math.ceil(environmentDataModel.count / 2)
    cellHeight : 60
    cellWidth : parent.width / 2

    delegate : Item {
      //Wrapping scalar entry in an item helps us center the rectangle inside the gridview cell.  If we tried to
      // anchor in center without this, every delegate instance would center itself in the middle of the view (not
      // the middle of the individual cell)
      id: delegateWrapper
      width : environmentGridView.cellWidth
      height : environmentGridView.cellHeight
      UIUnitScalarEntry {
        anchors.centerIn : parent
        prefWidth : environmentGridView.cellWidth * 0.9
        prefHeight : environmentGridView.cellHeight * 0.95
        label : root.displayFormat(model.name)
        unit : model.unit
        type : model.type
        hintText : model.hint
        entryValidator : root.assignValidator(model.type)
        onInputAccepted : {
          root.environmentData[model.name] = input
          if (model.name === "Name" && root.editMode && !nameWarningFlagged){
            root.nameEdited()
            nameWarningFlagged = true
          }
        }
        Component.onCompleted : {
          //Binds the "valid" role of each element with the validInput property of the entry, with the exception of 
          //"Name" (required field, need to make sure it's filled)
          if (model.name === "Name"){
            model.valid = Qt.binding(function() {return (entry.userInput[0]!= null && entry.userInput[0].length > 0)})
          } else { 
            model.valid = Qt.binding(function() {return entry.validInput}) 
          }
          //Connect load function of wizard (called when opening an existing environment) to individual entries
          root.onLoadConfiguration.connect(function (patient) { setEntry (environment[model.name]) } )
          //Connect wizard reset button to entry reset functions -- if we are editing an existing environment, then restore
          //the loaded value on reset.  If loaded file had no data for this field (null check), or if we are not in edit mode, then full reset
          root.onResetConfiguration.connect(function () { if ( root.editMode && resetData[model.name][0]!=null) { setEntry(root.resetData[model.name]); } else { reset(); } } )
        }
      }
    }
  }

  Label {
    id : ambientGasLabel
    width : parent.width
    height : implicitHeight
    anchors.top : environmentGridView.bottom
    anchors.topMargin : 15
    anchors.left : parent.left
    anchors.right : parent.right
    text : "Ambient Gases"
    font.pointSize : 10
    horizontalAlignment : Text.AlignHCenter
  }

  GridView {
    id: ambientGasGridView
    clip : true
    width : parent.width
    height : targetGridHeight < maxGridHeight ? targetGridHeight : maxGridHeight
    model : ambientGasListModel
    anchors.top : ambientGasLabel.bottom
    anchors.topMargin : 10
    anchors.left : parent.left
    anchors.right : parent.right
    currentIndex: -1
    property var targetGridHeight : (Math.floor(count / 2) + count % 2) * cellHeight
    property var maxGridHeight : parent.height - (environmentGridView.height + ambientGasLabel.height + addAmbientGas.height + 25 )
    cellHeight : 70
    cellWidth : width / 2
    ScrollIndicator.vertical: ScrollIndicator { }
    delegate : Item {
      //Wrapping scalar entry in an item helps us center the rectangle inside the gridview cell.  If we tried to
      // anchor in center without this, every delegate instance would center itself in the middle of the view (not
      // the middle of the individual cell)
      id: delegateWrapper
      width : ambientGasGridView.cellWidth
      height : ambientGasGridView.cellHeight
      UISubstanceEntry {
        id : substanceEntryDelegate
        anchors.centerIn : parent
        prefWidth : ambientGasGridView.cellWidth * 0.875 //Tuned to get the remove icon to fit
        prefHeight : ambientGasGridView.cellHeight * 0.85
        unit : model.unit
        type : model.type
        hintText : model.hint
        entryValidator : fractionValidator
        Component.onCompleted : {
          setComponentList()    //Make sure the list of substances is populated
          root.onResetConfiguration.connect( function() { if (!root.editMode) { reset() } } )   //If "new" compound (!edit), then reset wipes out all data
          model.valid = Qt.binding(function() {return entry.validInput})
        }
        onInputAccepted : {
          //Returned "input" is an array [substance, concentration, unit]
          let gas = input[0]
          //If the name in the list model and the name in the data map are out of sync, we either changed the substance
          // name (and need to update the map key), or the substance has not been added to the map yet
          if (model.name!==gas){
            if (root.ambientGasData.hasOwnProperty(gas)){
              //Another component field has already set up this substance.  Do not allow duplicate collisions
              root.invalidConfiguration("Duplicate ambient gas definitions")
              substanceUpdateRejected(model.name)
            } else {
              if (root.ambientGasData.hasOwnProperty(model.name)){
                //This component field is mapped to the right place in the data map, but we changed the substance name
                //Delete map entry and reset to correct name
                delete root.ambientGasData[model.name]
              }
              let newGas = {[gas] : input.slice(1,input.length)}
              Object.assign(root.ambientGas, newComponent)
              ambientGasListModel.set(index, {"name" : substance}) //Update List model name to match current substance
            }
          } else {
            //Substance name in data map in sync with list model.  Find sub in map and update values
            root.ambientGasData[gas] = input.slice(1, input.length)
          }
          root.getGasList()
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
            let gasToRemove = ambientGasListModel.get(index).name
            //If name is not empty, then we have previously added substance to data map and need to remove it
            if (gasToRemove !== ""){
              delete root.ambientGasData[gasToRemove]
            }
            //Remove entry from model
            ambientGasListModel.remove(index)
            root.getGasList()
          }
        }
      }
    }  
  }
  
  Rectangle {
    id : addAmbientGas
    width: parent.width
    height : 20
    anchors.top : ambientGasGridView.bottom
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
      sourceSize.width : 20
      sourceSize.height: 20
      anchors.verticalCenter : parent.verticalCenter
      anchors.right : parent.right
      anchors.rightMargin : sourceSize.width / 2
      MouseArea {
        anchors.fill : parent
        cursorShape : Qt.PointingHandCursor
        acceptedButtons : Qt.LeftButton
        onClicked: {
          //Add element to model so that grid view displays it
          let newComponent = {name: "", unit: "", type: "0To1", hint: "", valid: true}
          ambientGasListModel.append(newComponent)
        }
      }
    }
  }

  DoubleValidator {
    id : doubleValidator
    bottom : 0
  }

  DoubleValidator {
    id : fractionValidator
    bottom : 0
    top : 1.0
    decimals : 3
  }

  ListModel {
    id : environmentDataModel
    ListElement {name : "Name"; unit: ""; type : "string"; hint : "*Required"; valid : true}
    ListElement {name : "SurroundingType"; unit : "medium"; type : "enum"; hint : ""; valid : true}
    ListElement {name : "AirDensity";  unit : "concentration"; type : "double"; hint : "Enter a value"; valid : true }
    ListElement {name : "AirVelocity"; unit : "velocity"; type : "double"; hint : "Enter a value"; valid : true}
    ListElement {name : "AmbientTemperature";  unit : "temperature"; type : "double"; hint : "Enter a value"; valid : true }
    ListElement {name : "MeanRadiantTemperature";  unit : "temperature"; type : "double"; hint : "Enter a value"; valid : true }
    ListElement {name : "RespirationAmbientTemperature";  unit : "temperature"; type : "double"; hint : "Enter a value"; valid : true}
    ListElement {name : "AtmosphericPressure"; unit : "pressure"; type : "double"; hint : "Enter a value"; valid : true}
    ListElement {name : "RelativeHumidity";  unit : ""; type : "0To1"; hint : "Enter a value in range [0,1]"; valid : true}
    ListElement {name : "Emissivity";  unit : ""; type : "0To1"; hint : "Enter a value in range [0,1]"; valid : true}
    ListElement {name : "ClothingResistance";  unit : "clothing"; type : "double"; hint : "Enter a value"; valid : true }
  }

  ListModel {
    id : ambientGasListModel
  }
  ListModel {
    id : aerosolListModel
  }
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 