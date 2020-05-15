import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import QtQml.Models 2.2

Page {
  id : compoundWizard
  anchors.fill : parent
  property alias doubleValidator : doubleValidator
  property alias fractionValidator : fractionValidator
  property alias neg1To1Validator : neg1To1Validator
  property alias substanceListModel : substanceListModel
  property alias substanceDelegateModel : substanceDelegateModel
  property alias substanceTabBar : substanceTabBar
  property alias substanceStackLayout : substanceStackLayout
  property alias pkStackLayout : pkStackLayout

  DoubleValidator {
    id : doubleValidator
    bottom : 0
    decimals : 2
  }

  DoubleValidator {
    id : fractionValidator
    bottom : 0
    top : 1.0
    decimals : 3
  }

  DoubleValidator {
    id : neg1To1Validator
    bottom : -1.0
    top : 1.0
    decimals : 3
  }

  TabBar {
    id : substanceTabBar
    width : parent.width
    height : 40
    TabButton {
      id : baseDataButton
      text : "Physical Data"
      onClicked : {
        substanceStackLayout.currentIndex = TabBar.index
      }
    }
    TabButton {
      id : clearanceButton
      text : "Clearance"
      onClicked : {
        substanceStackLayout.currentIndex = TabBar.index
      }
    }
    TabButton {
      id : pkButton
      text : "Pharmacokinetics"
      onClicked : {
        substanceStackLayout.currentIndex = TabBar.index
      }
    }
    TabButton {
      id : pdButton
      text : "Pharmacodynamics"
      onClicked : {
        substanceStackLayout.currentIndex = TabBar.index
      }
    }
   /* TabButton {
      id : aerosolButton
      text : "Aerosolization"
      onClicked : {
        substanceStackLayout.currentIndex = TabBar.index
      }
    }*/
  }

  StackLayout {
    id : substanceStackLayout
    width : parent.width
    height : parent.height - substanceTabBar.height
    anchors.top : substanceTabBar.bottom
    currentIndex : 0
    property real subIndex : children[currentIndex].subIndex
    Pane {
      id : physicalDataTab
      Layout.fillWidth : true
      Layout.fillHeight : true
      property real subIndex : 0
      GridView {
        id: physicalDataGridView
        clip : true
        model : substanceDelegateModel.parts.physical
        anchors.top : parent.top
        anchors.topMargin : 10
        anchors.left : parent.left
        anchors.right : parent.right
        width : parent.width
        height : parent.height
        cellHeight : 60
        cellWidth : parent.width / 2
      }
    }
    Pane {
      id : clearanceTab
      Layout.fillWidth : true
      Layout.fillHeight : true
      property real subIndex : 0
      Label {
        id : clearanceLabel
        width : parent.width
        height : implicitHeight
        anchors.top : parent.top
        anchors.topMargin : 15
        anchors.left : parent.left
        anchors.right : parent.right
        text : "Clearance"
        font.pointSize : 10
        horizontalAlignment : Text.AlignHCenter
      }
      GridView {
        id: clearanceGridView
        clip : true
        width : parent.width
        height : (Math.floor(count / 2) + count % 2) * cellHeight
        cellHeight : 60
        cellWidth : parent.width / 2
        model : substanceDelegateModel.parts.clearanceSystemic
        anchors.top : clearanceLabel.bottom
        anchors.topMargin : 10
        anchors.left : parent.left
        anchors.right : parent.right
        currentIndex: -1
      }
      ButtonGroup {
        id : renalOptionsButtonGroup
        onClicked : {
          console.log('clicked')
          if (button.choice === "regulation"){
            console.log('regulation')
            //clearanceTab.subIndex = 1
            //regulationViewLoader.sourceComponent = clearanceRegulationComponent
          }
        }
      }
      RowLayout {
        id : renalOptionsRow
        anchors.top : clearanceGridView.bottom
        anchors.horizontalCenter : parent.horizontalCenter
        width : implicitWidth
        height : implicitHeight
        RadioButton {
          id : systemicOption
          checked : true
          property string choice : "clearance"
          text : "Use systemic"
          ButtonGroup.group : renalOptionsButtonGroup
        }
        RadioButton {
          id : regulationOption
          checked : false
          property string choice : "regulation"
          text : "Use renal regulation"
          ButtonGroup.group : renalOptionsButtonGroup
        }
      }
      
      Loader {
        id : regulationViewLoader

      }
      
      GridView {
        id: regulationGridView
        clip : true
        width : parent.width
        height : (Math.floor(count / 2) + count % 2) * cellHeight
        cellHeight : 60
        cellWidth : parent.width / 2
        model : substanceDelegateModel.parts.clearanceRegulation
        anchors.topMargin : 10
        anchors.top : renalOptionsRow.bottom
        anchors.left : parent.left
        anchors.right : parent.right
        currentIndex: -1
      }
    }
    Pane {
      id : pkTab
      Layout.fillWidth : true
      Layout.fillHeight : true
      property real subIndex : pkStackLayout.currentIndex
      Label {
        id : pkLabel
        width : parent.width
        height : implicitHeight
        anchors.top : parent.top
        anchors.topMargin : 15
        anchors.left : parent.left
        anchors.right : parent.right
        text : "Pharmacokinetics"
        font.pointSize : 10
        horizontalAlignment : Text.AlignHCenter
      }
      RowLayout {
        id : switchItem
        width : parent.width
        height : implicitHeight
        anchors.top : pkLabel.bottom
        anchors.topMargin : 10
        anchors.left : parent.left
        anchors.right : parent.right
        Label {
          text : "Physicochemical Input"
          font.pointSize : 9
          Layout.alignment : Qt.AlignRight
        }
        Switch {
          text : "Partition Coefficients"
          font.pointSize : 9
          onClicked : {
            pkStackLayout.currentIndex = position 
          }
        }
      }
      StackLayout {
        id : pkStackLayout
        anchors.top : switchItem.bottom
        anchors.topMargin : 10
        width : parent.width
        height : parent.height - switchItem.height
        currentIndex : 0
        Item {
          GridView {
            id: pkGridView1
            clip : true
            width : parent.width
            height : parent.height
            cellHeight : 60
            cellWidth : parent.width / 2
            model : substanceDelegateModel.parts.pkPhysicochemical
            currentIndex: -1
          }
        }
        Item {
          GridView {
            id: pkGridView2
            clip : true
            width : parent.width
            height : parent.height
            cellHeight : 60
            cellWidth : parent.width / 2
            model : substanceDelegateModel.parts.pkTissueKinetics
            currentIndex: -1
          }
        }
      }   
    }
    Pane {
      id : pdTab
      Layout.fillWidth : true
      Layout.fillHeight : true
      property real subIndex : 0
      Label {
        id : pdLabel
        width : parent.width
        height : implicitHeight
        anchors.top : parent.top
        anchors.topMargin : 15
        anchors.left : parent.left
        anchors.right : parent.right
        text : "Pharmacodynamics"
        font.pointSize : 10
        horizontalAlignment : Text.AlignHCenter
      }
      GridView {
        id: pdGridView
        clip : true
        width : parent.width
        height : parent.height
        cellHeight : 60
        cellWidth : parent.width / 2
        model : substanceDelegateModel.parts.pharmacodynamics
        anchors.top : pdLabel.bottom
        anchors.topMargin : 10
        anchors.left : parent.left
        anchors.right : parent.right
        currentIndex: -1
      }
    }
  }
  
  //--------Note on DelegateModel-------------------------
  //Delegate models have a pre-defined group called "items" that all elements from model (substanceListModel, in this case)
    // are added to by default. Elements must manually be added to the other groups we have defined in SubstanceDelegateModel
		// The setGroups(a, b, otherGroup(s)) function reassigns b elements starting at index a of the calling group to
		// otherGroup(s) (can be a list of groups).  E.g. items.setGroups(0, 2, "clearance") will reassign 2 elements 
    // starting at index 0 (in items) to the clearance group.  Note that "setGroups" is a full reset -- the elements 
    // will only be in the new group(s). This is desirable behavior for our case because as objects are added to "items"
    // we can use the onChanged signal from items to sort new objects to the correct group (see UISubstanceWizard::UpdateDelegateItems()).
		// DelegateModel has a second pre-defined group called "persistedItems".  Adding elements to this group passes ownership 
    // of the objects created from those elements to the delegate model, which maintains their existence even when the view containing 
    // the object goes out of focus (normal behavior for views is to destroy their objects when view goes out of focus, then re-make 
    // them when focus is regained). Elements can be assigned to multiple groups, so we assign all active elements to 
    // persistedItems in addition to their view group (physical, clearance, etc).  In practice, this means that if we write data 
    // in the "Physical" tab, then click over to the PK tab, the "physical" data will still be saved and re-displayed when we move 
    // back to the "Physical" tab .  
		
    //The advantage of using a DelegateModel is that it's delegate can be a package, which is a collection of delegates
    // that can be assigned to different views via the "parts" property of DelegateModel.  substanceDelegate sets up
    // delegates for each of the groups and the GridViews defined above pull the appropriate delegate by setting their
    // model to "substanceDelegateModel.parts.packageName".  To send only a particular group of model elements to each
    // view (rather than every element in SubstanceListModel), we update the "filterOnGroup" property of DelegateModel, 
    // which makes only those elements in that groups available to the view.  In this way, we can maintain a master
    // listModel of all substance elements but refrain from convoluted nesting and sub-indexing to parcel out specific
    // elements to specific tabs.

		//We create a property called groupIndexMap that keys the group name string to its DelegateModelGroup.  This is 
    // useful because the "groups" property is a simple list, meaning we can only index numerically.  The indexing can
    // be an issue because the "items" and "persistedItems" groups occupy groups[0] and groups[1], which is not intuitive
    // looking at the list of groups that we added.  With groupIndexMap, we can get a DelegateModelGroup by calling
    // substanceDelegateModel.groupIndexMap["groupName"].  We can then get any items in that groups using the get()
    // function of DelegateModelGroup.  

		// Within each DelegateModelGroup, we create a data property and bind it to the javascript object that will track
    // the values that users enter.  We also take advantage of each groups "onChanged" signal to add or remove entries
    // from group.data as needed.  It should be mentioned that each item in a DelegateModelGroup has many attached properties,
    // like "model", which contains all the roles from DelegateModel.model (substanceListModel, in this case), that help
    // us with data manipulation.  See DelegateModelGroup documentation for all attached properties.

  DelegateModel {
    id : substanceDelegateModel
    model : substanceListModel      
    delegate : substanceDelegate
    property var groupIndexMap : ({})
    groups :  [
                DelegateModelGroup {name : "physical"; includeByDefault : false; property var data : physicalData; onChanged : substanceDelegateModel.updateGroup(this) },
                DelegateModelGroup {name : "clearance"; includeByDefault : false; property var children : ['clearance_systemic','clearance_regulation'] },
                DelegateModelGroup {name : "clearance_systemic"; includeByDefault : false; property string parent : 'clearance'; property var data : clearanceData.systemic; onChanged : substanceDelegateModel.updateGroup(this) },
                DelegateModelGroup {name : "clearance_regulation"; includeByDefault : false; property string parent : 'clearance'; property var data : clearanceData.renalDynamics; onChanged : substanceDelegateModel.updateGroup(this) },
                DelegateModelGroup {name : "pkPhysicochemical"; includeByDefault : false; property var data : pkData.physicochemical; onChanged : substanceDelegateModel.updateGroup(this)},
                DelegateModelGroup {name : "pkTissueKinetics"; includeByDefault : false; property var data : pkData.tissueKinetics; onChanged : substanceDelegateModel.updateGroup(this)},
                DelegateModelGroup {name : "pharmacodynamics"; includeByDefault : false; property var data : pdData; onChanged : substanceDelegateModel.updateGroup(this)},
                DelegateModelGroup {name : "dynamic"; includeByDefault : false}
              ]
    items.onChanged : updateDelegateItems (items)
    filterOnGroup : setDelegateFilter(substanceStackLayout.currentIndex, substanceStackLayout.subIndex)
    Component.onCompleted : {
      //Set up the groupIndexMap
      for (let i = 0; i < groups.length; ++i){
        Object.assign(groupIndexMap, {[groups[i].name] : groups[i]})
      }
    }
    function updateGroup(group){
      //If group.data has fewer elements than the group, then we need to add entries for the deficient elements to group.data
      if (Object.keys(group.data).length < group.count){
        for (let i = 0; i < group.count; ++i){
          if (!(group.get(i).model.name in group.data)){
            Object.assign(group.data, {[group.get(i).model.name] : [null, null]})
          }
        }
      }
      if (group.parent){
        let parentGroupName = group.parent
        let inParentString = "in" + parentGroupName.charAt(0).toUpperCase() + parentGroupName.slice(1)
        for (let i = 0; i < group.count; ++i){
          let item = group.get(i)
          if (!item[inParentString]){
            group.addGroups(i, 1, parentGroupName)
          }
        }
	    } 
      //If group.data has more elements than the group, then we must have removed some dynamic elements from the view.
      //Search "dynamic" group for elements whose substanceListModel "group" role match the calling group and remove
      //them from group.data.
      if (group.count < Object.keys(group.data).length){
        let dynamicItems = groupIndexMap["dynamic"]
        for (let i = 0; i < dynamicItems.count; ++i){
          let listedGroup = dynamicItems.get(i).model.group
          let elementName = dynamicItems.get(i).model.name
          if (listedGroup === group.name){
            delete group.data[elementName]
          }
        }
      }
    }
  }
  Component {
    id : substanceDelegate  
    Package {
      Item { id : idPhysical; Package.name : "physical"; width : GridView.view.cellWidth; height : GridView.view.cellHeight}
      Item { id : idClearanceSystemic; Package.name : "clearanceSystemic"; width : GridView.view.cellWidth; height : GridView.view.cellHeight}
      Item { id : idClearanceRegulation; Package.name : "clearanceRegulation"; width : GridView.view.cellWidth; height : GridView.view.cellHeight}
      Item { id : idPkPhysicochemical; Package.name : "pkPhysicochemical"; width : GridView.view.cellWidth; height : GridView.view.cellHeight}
      Item { id : idPkTissueKinetics; Package.name : "pkTissueKinetics"; width : GridView.view.cellWidth; height : GridView.view.cellHeight}
      Item { id : idPharmacodynamics; Package.name : "pharmacodynamics"; width : GridView.view.cellWidth; height : GridView.view.cellHeight}

      Item { 
        id : wrapper
        width : parent.width
        height : parent.height
        property var groupData
        state : model.group
        states : [
          State { name : "physical"; changes : [ParentChange { target : wrapper; parent : idPhysical}, PropertyChanges { target : wrapper; groupData : physicalData} ] },
          State { name : "clearance_systemic"; changes : [ParentChange { target : wrapper; parent : idClearanceSystemic}, PropertyChanges{target : wrapper; groupData : clearanceData.systemic} ] },
          State { name : "clearance_regulation"; changes : [ParentChange { target : wrapper; parent : idClearanceRegulation}, PropertyChanges{target : wrapper; groupData : clearanceData.regulation} ] },
          State { name : "pkPhysicochemical"; changes : [ParentChange { target : wrapper; parent : idPkPhysicochemical}, PropertyChanges{target : wrapper; groupData : pkData.physicochemical} ] },
          State { name : "pkTissueKinetics"; changes : [ParentChange { target : wrapper; parent : idPkTissueKinetics}, PropertyChanges{target : wrapper; groupData : pkData.tissueKinetics} ] },
          State { name : "pharmacodynamics"; changes : [ParentChange { target : wrapper; parent : idPharmacodynamics}, PropertyChanges{target : wrapper; groupData : pdData} ] }
        ]
        UIUnitScalarEntry {
          id : unitScalarEntry
          anchors.centerIn : parent
          prefWidth : parent.width * 0.9
          prefHeight : parent.height * 0.95
          label : root.displayFormat(model.name)
          unit : model.unit
          type : model.type
          hintText : model.hint
          entryValidator : root.assignValidator(model.type)
          Component.onCompleted : {
            console.log(model.name, model.group)
            model.valid = Qt.binding(function() {return entry.validInput})
            root.onResetConfiguration.connect(function () { resetEntry(entry) } )
          }
          onInputAccepted : {
            if (input[0] === ""){
              parent.groupData[model.name] = [null, null]
            } else {
              parent.groupData[model.name] = input
            }
            debugObjects(parent.groupData)
          }
        }
      }
      
    } 
  }

  //List model roles name, unit, type, and hint set properties in the delegate created from an element.  The valid role
  // is bound to the delegate valid property, which we use to determine whether data is ready to be passed to create_substance().
  // The group role helps us sort the element into the appropriate DelegateModelGroup in substanceDelegateModel.
  // The dynamic role determines whether an object corresponding to the element can be added/removed from a view during
  // runtime.  If false, the element is assumed to always be visible.  If true, the element can be added or removed
  // from a view while the substance editor is open (see Clearance Grid View).
  ListModel {
    id : substanceListModel
    ListElement {name : "Name"; unit: ""; type : "string"; hint : "*Required"; valid : true; group : "physical";dynamic : false}
      ListElement {name : "State"; unit: "substanceState"; type : "enum"; hint : "*"; valid : true; group : "physical";dynamic : false}
      ListElement {name : "Classification"; unit : "substanceClass"; type : "enum"; hint : ""; valid : true; group : "physical";dynamic : false}
      ListElement {name : "MolarMass";  unit : "molar"; type : "double"; hint : "Enter a value"; valid : true; group : "physical";dynamic : false}
      ListElement {name : "Density";  unit : "concentration"; type : "double"; hint : "Enter a value"; valid : true; group : "physical";dynamic : false}
      ListElement {name : "MaximumDiffusionFlux"; unit : "massFlux"; type : "double"; hint : "Enter a value"; valid : true; group : "physical";dynamic : false}
      ListElement {name : "MichaelisCoefficient";  unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "physical";dynamic : false}
      ListElement {name : "MembraneResistance";  unit : "electricalResistance"; type : "double"; hint : "Enter a value"; valid : true; group : "physical";dynamic : false}
      ListElement {name : "RelativeDiffusionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "physical";dynamic : false}
      ListElement {name : "SolubilityCoefficient";  unit : "inversePressure"; type : "double"; hint : "Enter a value"; valid : true; group : "physical";dynamic : false}
    ListElement {name : "IntrinsicClearance"; unit : "volumetricFlowNorm"; type : "double"; hint : "Enter a value "; valid : true; group : "clearance_systemic";dynamic : false}
      ListElement {name : "RenalClearance"; unit : "volumetricFlowNorm"; type : "double"; hint : "Enter a value "; valid : true; group : "clearance_systemic";dynamic : false}
      ListElement {name : "SystemicClearance"; unit : "volumetricFlowNorm"; type : "double"; hint : "Enter a value "; valid : true; group : "clearance_systemic";dynamic : false}
      ListElement {name : "FractionUnboundInPlasma"; unit : ""; type : "0To1"; hint : "Enter a value [0-1]"; valid : true; group : "clearance_systemic";dynamic : false}
      ListElement {name : "ChargeInBlood"; unit : "charge"; type : "enum"; hint : ""; valid : true; group : "clearance_regulation";dynamic : false}
      ListElement {name : "ReabsorptionRatio"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "clearance_regulation";dynamic : false}  
      ListElement {name : "TransportMaximum"; unit : "massRate"; type : "double"; hint : "Enter a value"; valid : true; group : "clearance_regulation";dynamic : false} 
      ListElement {name : "FractionUnboundInPlasma"; unit : ""; type : "0To1"; hint : "Enter a value [0-1]"; valid : true; group : "clearance_regulation";dynamic : false}
    ListElement {name : "AcidDissociationConstant"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkPhysicochemical";dynamic : false}     
      ListElement {name : "BindingProtein"; unit : "protein"; type : "enum"; hint : ""; valid : true; group : "pkPhysicochemical";dynamic : false}     
      ListElement {name : "BloodPlasmaRatio"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkPhysicochemical";dynamic : false}     
      ListElement {name : "FractionUnboundInPlasma"; unit : ""; type : "0To1"; hint : "Enter a value [0-1]"; valid : true; group : "pkPhysicochemical";dynamic : false} 
      ListElement {name : "IonicState"; unit : "ionicState"; type : "enum"; hint : ""; valid : true; group : "pkPhysicochemical";dynamic : false} 
      ListElement {name : "LogP"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkPhysicochemical";dynamic : false}
      ListElement {name : "HydrogenBoundCount"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkPhysicochemical";dynamic : false}
      ListElement {name : "PolarSurfaceArea"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkPhysicochemical";dynamic : false}
    ListElement {name : "BonePartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics";dynamic : false}
      ListElement {name : "BrainPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics";dynamic : false}
      ListElement {name : "FatPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics";dynamic : false}
      ListElement {name : "GutPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics";dynamic : false}
      ListElement {name : "LeftKidneyPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics";dynamic : false}
      ListElement {name : "LeftLungPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics";dynamic : false}
      ListElement {name : "LiverPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics";dynamic : false}
      ListElement {name : "MusclePartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics";dynamic : false}
      ListElement {name : "MyocardiumPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics";dynamic : false}
      ListElement {name : "RightKidneyPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics";dynamic : false}
      ListElement {name : "RightLungPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics";dynamic : false}
      ListElement {name : "SkinPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics";dynamic : false}
      ListElement {name : "SpleenPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics";dynamic : false}
    ListElement {name : "EC50"; unit : "concentration"; type : "double"; hint : "Enter a value"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "ShapeParameter"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "EffectSiteRateConstant"; unit : "frequency"; type : "double"; hint : "Enter a value"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "BronchodilationModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "DiastolicPressureModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "SystolicPressureModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "FeverModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "HeartRateModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "HemorrhageModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "NeuromuscularBlockModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "PainModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "RespirationRateModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "TidalVolumeModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "SedationModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "TubularPermeabilityModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "CentralNervousModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "AntibacterialEffect"; unit : "frequency"; type : "double"; hint : ""; valid : true; group : "pharmacodynamics";dynamic : false}
      ListElement {name : "PupillaryResponse"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics";dynamic : false}
  }


}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 