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

  TabBar {
    id : environmentTabBar
    width : parent.width
    height : 40
    TabButton {
      id : baseDataButton
      text : "Base Data"
      onClicked : {
        environmentStackLayout.currentIndex = TabBar.index
      }
    }
    TabButton {
      id : gasDataButton
      text : "Substances"
      onClicked : {
        environmentStackLayout.currentIndex = TabBar.index
      }
    }
  }

  StackLayout {
    id : environmentStackLayout
    width : parent.width
    height : parent.height - environmentTabBar.height
    anchors.top : environmentTabBar.bottom
    currentIndex : 0
    Item {
      id : baseDataTab
      Layout.fillWidth : true
      Layout.fillHeight : true
      GridView {
        id: environmentGridView
        clip : true
        model : environmentDataModel
        anchors.top : parent.top
        anchors.topMargin : 10
        anchors.left : parent.left
        anchors.right : parent.right
        width : parent.width
        height : parent.height
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
              root.onLoadConfiguration.connect(function (environment) { setEntry (environment[model.name]) } )
              //Connect wizard reset button to entry reset functions -- if we are editing an existing environment, then restore
              //the loaded value on reset.  If loaded file had no data for this field (null check), or if we are not in edit mode, then full reset
              root.onResetConfiguration.connect(function () { if ( root.editMode && resetData[model.name][0]!=null) { setEntry(root.resetData[model.name]); } else { reset(); } } )
            }
          }
        }
      }
    }
    Item {
      id : substanceDataTab
      Layout.fillWidth : true
      Layout.fillHeight : true
      Label {
        id : ambientGasLabel
        width : parent.width
        height : implicitHeight
        anchors.top : substanceDataTab.top
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
        height : cellHeight
        model : ambientGasListModel
        anchors.top : ambientGasLabel.bottom
        anchors.topMargin : 10
        anchors.left : parent.left
        anchors.right : parent.right
        currentIndex: -1
        cellHeight : 70
        cellWidth : width / 4
        ScrollIndicator.vertical: ScrollIndicator { }
        delegate : Item {
          //Wrapping scalar entry in an item helps us center the rectangle inside the gridview cell.  If we tried to
          // anchor in center without this, every delegate instance would center itself in the middle of the view (not
          // the middle of the individual cell)
          id: delegateWrapper
          width : ambientGasGridView.cellWidth
          height : ambientGasGridView.cellHeight
          UIUnitScalarEntry {
            id : substanceEntryDelegate
            anchors.centerIn : parent
            prefWidth : ambientGasGridView.cellWidth * 0.9
            prefHeight : ambientGasGridView.cellHeight * 0.85
            label : root.displayFormat(model.name)
            unit : model.unit
            type : model.type
            hintText : model.hint
            entryValidator : fractionValidator
            Component.onCompleted : {
              model.valid = Qt.binding(function() {return entry.validInput}) 
              //Connect load function of wizard (called when opening an existing environment) to individual entries
              root.onLoadConfiguration.connect(function (environment) { setEntry (environment[model.name]) } )
              //Connect wizard reset button to entry reset functions -- if we are editing an existing environment, then restore
              //the loaded value on reset.  If loaded file had no data for this field (null check), or if we are not in edit mode, then full reset
              root.onResetConfiguration.connect(function () { if ( root.editMode && resetData[model.name][0]!=null) { setEntry(root.resetData[model.name]); } else { reset(); } } )
            }
            onInputAccepted : {
              root.environmentData[model.name] = input
            }
          }
        }  
      }
      Label {
        id : aerosolLabel
        width : parent.width
        height : implicitHeight
        anchors.top : ambientGasGridView.bottom
        anchors.topMargin : 25
        anchors.left : parent.left
        anchors.right : parent.right
        text : "Aerosols"
        font.pointSize : 10
        horizontalAlignment : Text.AlignHCenter
      }
      GridView {
        id: aerosolGridView
        clip : true
        width : parent.width
        height : targetGridHeight < maxGridHeight ? targetGridHeight : maxGridHeight
        model : aerosolListModel
        anchors.top : aerosolLabel.bottom
        anchors.topMargin : 10
        anchors.left : parent.left
        anchors.right : parent.right
        currentIndex: -1
        property var targetGridHeight : (Math.floor(count / 2) + count % 2) * cellHeight
        property var maxGridHeight : parent.height - (ambientGasGridView.height + aerosolLabel.height + addAerosol.height + 70 )  //70 is the sum of the top margins of items above this view
        cellHeight : 70
        cellWidth : width / 2
        ScrollIndicator.vertical: ScrollIndicator { }
        delegate : Item {
          //Wrapping scalar entry in an item helps us center the rectangle inside the gridview cell.  If we tried to
          // anchor in center without this, every delegate instance would center itself in the middle of the view (not
          // the middle of the individual cell)
          id: delegateWrapper
          width : aerosolGridView.cellWidth
          height : aerosolGridView.cellHeight
          UISubstanceEntry {
            id : substanceEntryDelegate
            anchors.centerIn : parent
            prefWidth : aerosolGridView.cellWidth * 0.875 //Tuned to get the remove icon to fit
            prefHeight : aerosolGridView.cellHeight * 0.85
            unit : model.unit
            type : model.type
            hintText : model.hint
            entryValidator : fractionValidator
            Component.onCompleted : {
              setComponentList('Aerosol')    //Make sure the list of substances is populated
              root.onResetConfiguration.connect( function() { if (!root.editMode) { reset() } } )   //If "new" compound (!edit), then reset wipes out all data
              model.valid = Qt.binding(function() {return entry.validInput})
            }
            onInputAccepted : {
              //Returned "input" is an array [substance, concentration, unit]
              let aerosol = input[0]
              //If the name in the list model and the name in the data map are out of sync, we either changed the substance
              // name (and need to update the map key), or the substance has not been added to the map yet
              if (model.name!==aerosol){
                if (root.aerosolData.hasOwnProperty(aerosol)){
                  //Another component field has already set up this substance.  Do not allow duplicate collisions
                  root.invalidConfiguration("Duplicate aerosol definitions")
                  substanceUpdateRejected(model.name)
                } else {
                  if (root.aerosolData.hasOwnProperty(model.name)){
                    //This component field is mapped to the right place in the data map, but we changed the substance name
                    //Delete map entry and reset to correct name
                    delete root.aerosolData[model.name]
                  }
                  let newAerosol = {[aerosol] : input.slice(1,input.length)}
                  Object.assign(root.aerosolData, newAerosol)
                  aerosolListModel.set(index, {"name" : aerosol}) //Update List model name to match current substance
                }
              } else {
                //Substance name in data map in sync with list model.  Find sub in map and update values
                root.aerosolData[aerosol] = input.slice(1, input.length)
              }
              root.getGasList()
            }
          }
          Image {
            id: removeAerosolIcon
            source : "icons/remove.png"
            sourceSize.width : 10
            sourceSize.height: 10
            MouseArea {
              anchors.fill : parent
              cursorShape : Qt.PointingHandCursor
              acceptedButtons : Qt.LeftButton
              onClicked: {
                //Which substance are we removing?
                let aerosolToRemove = aerosolListModel.get(index).name
                //If name is not empty, then we have previously added substance to data map and need to remove it
                if (aerosolToRemove !== ""){
                  delete root.aerosolData[aerosolToRemove]
                }
                //Remove entry from model
                aerosolListModel.remove(index)
                root.getGasList()
              }
            }
          }
        }  
      }
      Rectangle {
        id : addAerosol
        width: parent.width
        height : 20
        anchors.top : aerosolGridView.bottom
        color : "transparent"
        Rectangle {
          id : aerosolRectangle
          width : parent.width - 60
          height : 2
          anchors.left : parent.left
          anchors.verticalCenter : parent.verticalCenter
          border.color : "black"
          color : "black"
        }
        Image {
          id: addAerosolIcon
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
              let newComponent = {name: "", unit: "concentration", type: "double", hint: "", valid: true}
              aerosolListModel.append(newComponent)
            }
          }
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
    ListElement {name : "Oxygen";  unit : ""; type : "0To1"; hint : "Fraction [0,1]"; valid : true}
    ListElement {name : "CarbonDioxide";  unit : ""; type : "0To1"; hint : "Fraction [0,1]"; valid : true}
    ListElement {name : "Nitrogen";  unit : ""; type : "0To1"; hint : "Fraction [0,1]"; valid : true}
    ListElement {name : "CarbonMonoxide";  unit : ""; type : "0To1"; hint : "Fraction [0,1]"; valid : true}
  }
  ListModel {
    id : aerosolListModel
  }
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 