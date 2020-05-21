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
  property alias renalOptions : renalOptionsButtonGroup

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
  }

  StackLayout {
    id : substanceStackLayout
    width : parent.width
    height : parent.height - substanceTabBar.height
    anchors.top : substanceTabBar.bottom
    currentIndex : 0
    property real subIndex : children[currentIndex].subIndex
    //---Physical Data Tab Layout----------------------------------------------
    Pane {
      id : physicalDataTab
      Layout.fillWidth : true
      Layout.fillHeight : true
      property real subIndex : 0
      property var dataView
      state : "default"
      states : [
         State { name : "default"; PropertyChanges { target : physicalDataTab; dataView : physicalGridView}}
      ]
      GridView {
        id: physicalGridView
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
    //---Clearance Data Tab Layout----------------------------------------------
    // This pane has two views that can be active at the same time.  The Delegate Model filter can't have two different
    // values simultaneously in the same active area (at least, I could not find a way), so we set the delegate model to
    // filter on "clearance", which includes both the "clearance_systemic" and "clearance_regulation" groups.  Each view,
    // though, is assigned a distinct part (systemic or regulation).  This means that there will be items allowed through
    // the filter that each view will not supply information to, resulting in a blank cell.  We address this by
    // making the views non-interactive (no scrolling to blank cells) and setting their heights so that only the visible
    // cells are shown.  This is easy for clearanceGridView because it's first visible item is index 0 in the clearance group.
    // For regulationGridView, the first 6 items are invisible (corresponding to the 6 clearance_systemic items), so we need to
    // make sure that it's current index is always reset to 6 (when the view is active) and that the view is positioned so
    // that the item at index 6 is in the top left of the grid.
    Pane {
      id : clearanceTab
      Layout.fillWidth : true
      Layout.fillHeight : true
      property real subIndex : 0
      property var dataView
      property bool isCurrentTab : substanceStackLayout.currentIndex === 1
      state : "clearanceOnly"
      states : [
         State { name : "clearanceOnly";  changes : [PropertyChanges { target : regulationGridView; currentIndex : 0}, PropertyChanges { target : clearanceTab; dataView : clearanceGridView} ]},
         State { name : "clearanceAndRegulation";  changes : [PropertyChanges{target : regulationGridView; currentIndex : 6}, PropertyChanges {target : clearanceTab; dataView: regulationGridView} ]}
      ]
      onIsCurrentTabChanged : {
        if (isCurrentTab && state === "clearanceAndRegulation"){
          //When we switch tabs, the current index of the grid views gets reset to 0. Since the first visible
          // item of the regulation grid view is at index = 6, we reset it here when focus is regained (and when state calls for it).
          regulationGridView.currentIndex = 6
        }
      }
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
      Rectangle {
        id : clearanceDivider
        height : 1
        width : parent.width
        color : "black"
        anchors.top : clearanceLabel.bottom
        anchors.topMargin : 5
      }
      Label {
        id : systemicLabel
        width : parent.width
        height : implicitHeight
        anchors.top : clearanceDivider.bottom
        anchors.topMargin : 20
        anchors.left : parent.left
        anchors.right : parent.right
        text : "Systemic Clearance"
        font.pointSize : 9
        horizontalAlignment : Text.AlignHCenter
      }
      GridView {
        id: clearanceGridView
        clip : true
        width : parent.width
        height : cellHeight * 3
        interactive : false
        cellHeight : 60
        cellWidth : parent.width / 2
        model : substanceDelegateModel.parts.clearanceSystemic
        anchors.top : systemicLabel.bottom
        anchors.topMargin : 10
        anchors.left : parent.left
        anchors.right : parent.right
        currentIndex: -1
      }
      Label {
        id : dynamicsLabel
        width : parent.width
        height : implicitHeight
        anchors.top : clearanceGridView.bottom
        anchors.topMargin : 25
        anchors.left : parent.left
        anchors.right : parent.right
        text : "Renal Dynamics"
        font.pointSize : 9
        horizontalAlignment : Text.AlignHCenter
      }
      ButtonGroup {
        id : renalOptionsButtonGroup
        exclusive : true
        property var manualButtonSet : function(choice) { for (let i = 0; i < buttons.length; ++i){buttons[i].checked = (buttons[i].choice===choice) } } 
        onClicked : {
          if (button.choice === "regulation"){
            clearanceTab.state = "clearanceAndRegulation"
          } else {
            clearanceTab.state = "clearanceOnly"
          }
        }
      }
      RowLayout {
        id : renalOptionsRow
        anchors.top : dynamicsLabel.bottom
        anchors.horizontalCenter : parent.horizontalCenter
        width : implicitWidth
        height : implicitHeight
        RadioButton {
          id : systemicOption
          //Note:  This button has index "1" in renalOptionsButtonGroup.buttons (I assume because buttons are pushed on to front of buttons array when added)
          checked : true
          property string choice : "clearance"
          text : "Use Systemic: Renal Clearance (Default)"
          font.pointSize : 8
          ButtonGroup.group : renalOptionsButtonGroup
        }
        RadioButton {
          id : regulationOption
          //Note:  This button has index "0" in renalOptionsButtonGroup.buttons (I assume because buttons are pushed on to front of buttons array when added)
          checked : false
          property string choice : "regulation"
          text : "Open Renal Regulation Options"
          font.pointSize : 8
          ButtonGroup.group : renalOptionsButtonGroup
        }
      }
      GridView {
        id: regulationGridView
        clip : true
        anchors.topMargin : 10
        anchors.top : renalOptionsRow.bottom
        anchors.left : parent.left
        anchors.right : parent.right
        width : parent.width
        height : cellHeight * 2
        interactive : false
        cellHeight : 60
        cellWidth : parent.width / 2
        model : substanceDelegateModel.parts.clearanceRegulation
        onCurrentIndexChanged : {
          positionViewAtIndex(currentIndex, GridView.beginning)
        }
      }
    }
    //---Pharmacokinetics Data Tab Layout----------------------------------------------
    // This tab also has two views, but the implementation is easier because only one can be visible at a time
    // (whereas clearance could potentially have two visible simultaneously). The two views are assigned to a pane
    // in another stack layout, and when the index of the stack layout is changed, the delegate model filter is updated
    // to be either physicochemical or tissue kinetics.
    Pane {
      id : pkTab
      Layout.fillWidth : true
      Layout.fillHeight : true
      property real subIndex : pkStackLayout.currentIndex
      property var dataView
      state : "physchem"
      states : [
         State { name : "physchem"; changes : [ PropertyChanges { target : pkStackLayout; currentIndex : 0}, PropertyChanges {target : pkTab; dataView : pkGridView1} ]},
         State { name : "partition"; changes :  [ PropertyChanges { target : pkStackLayout; currentIndex : 1}, PropertyChanges{target : pkTab; dataView : pkGridView2} ] }
      ]
      onSubIndexChanged : {
        //When we manually adjust the state, the position of the switch might go out of phase with the current layout index
        // Toggle switch if this happens (should only occur when we load a substance that uses tissue kinetics instead of physicochemicals)
        if (pkSwitch.visualPosition !== subIndex){
          pkSwitch.toggle()
        }
      }
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
          id : pkSwitch
          text : "Partition Coefficients"
          font.pointSize : 9
          onToggled : {
            pkTab.state = pkTab.states[position].name
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
    //---Pharmacodynamics Data Tab Layout----------------------------------------------
    Pane {
      id : pdTab
      Layout.fillWidth : true
      Layout.fillHeight : true
      property real subIndex : 0
      property var dataView
      state : "default"
      states : [
         State { name : "default"; PropertyChanges { target : pdTab; dataView : pdGridView}}
      ]
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
        height : parent.height - pdLabel.height - 15        //15 accounts for margin between label and view
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

		// Within each DelegateModelGroup, we create a data property and bind it to the javascript object that will track
    // the values that users enter.  We also take advantage of each groups "onChanged" signal to add or remove entries
    // from group.data as needed.  It should be mentioned that each item in a DelegateModelGroup has many attached properties,
    // like "model", which contains all the roles from DelegateModel.model (substanceListModel, in this case), that help
    // us with data manipulation.  See DelegateModelGroup documentation for all attached properties.

  DelegateModel {
    id : substanceDelegateModel
    model : substanceListModel      
    delegate : substanceDelegate
    groups :  [
                DelegateModelGroup {name : "physical"; includeByDefault : false; property var data : physicalData; onChanged : substanceDelegateModel.updateGroup(this) },
                DelegateModelGroup {name : "clearance"; includeByDefault : false; property var childrenGroups : ['clearance_systemic','clearance_regulation'] },
                DelegateModelGroup {name : "clearance_systemic"; includeByDefault : false; property string parentGroup : 'clearance'; property var data : clearanceData.systemic; onChanged : substanceDelegateModel.updateGroup(this) },
                DelegateModelGroup {name : "clearance_regulation"; includeByDefault : false; property string parentGroup : 'clearance'; property var data : clearanceData.regulation; onChanged : substanceDelegateModel.updateGroup(this) },
                DelegateModelGroup {name : "pkPhysicochemical"; includeByDefault : false; property var data : pkData.physicochemical; onChanged : substanceDelegateModel.updateGroup(this)},
                DelegateModelGroup {name : "pkTissueKinetics"; includeByDefault : false; property var data : pkData.tissueKinetics; onChanged : substanceDelegateModel.updateGroup(this)},
                DelegateModelGroup {name : "pharmacodynamics"; includeByDefault : false; property var data : pdData; onChanged : substanceDelegateModel.updateGroup(this)}
              ]
    items.onChanged : updateDelegateItems (items)
    filterOnGroup : setDelegateFilter(substanceStackLayout.currentIndex, substanceStackLayout.subIndex)

    function updateGroup(group){
      //If group.data has fewer elements than the group, then we need to add entries for the deficient elements to group.data
      if (Object.keys(group.data).length < group.count){
        for (let i = 0; i < group.count; ++i){
          if (!(group.get(i).model.name in group.data)){
            Object.assign(group.data, {[group.get(i).model.name] : [null, null]})
          }
        }
      }
      if (group.parentGroup){
        let parentGroupName = group.parentGroup
        let inParentString = "in" + parentGroupName.charAt(0).toUpperCase() + parentGroupName.slice(1)
        for (let i = 0; i < group.count; ++i){
          let item = group.get(i)
          if (!item[inParentString]){
            group.addGroups(i, 1, parentGroupName)
          }
        }
	    } 
    }
  }

  Component {
    id : substanceDelegate  
    Package {
      Item { id : idPhysical; Package.name : "physical"}
      Item { id : idClearanceSystemic; Package.name : "clearanceSystemic"}
      Item { id : idClearanceRegulation; Package.name : "clearanceRegulation"}
      Item { id : idPkPhysicochemical; Package.name : "pkPhysicochemical"}
      Item { id : idPkTissueKinetics; Package.name : "pkTissueKinetics"}
      Item { id : idPharmacodynamics; Package.name : "pharmacodynamics"}

      Item { 
        id : wrapper
        width : parent ? parent.GridView.view.cellWidth : 0
        height :  parent ?  parent.GridView.view.cellHeight : 0
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
          unit : wrapper.parent ? model.unit : ""
          type : wrapper.parent ? model.type : ""
          hintText : wrapper.parent ? model.hint : ""
          entryValidator : root.assignValidator(model.type)
          Component.onCompleted : {
            if (wrapper.parent){
              model.valid = Qt.binding(function() {return entry.validInput})
              root.onResetConfiguration.connect(function () { resetEntry(unitScalarEntry, model.group + "-" + model.name) } )
              root.onLoadConfiguration.connect(function () { setEntry(parent.groupData[model.name]) })
            }
          }
          onInputAccepted : {
            if (wrapper.parent){
              if (input[0] === ""){
                parent.groupData[model.name] = [null, null]
              } else {
                parent.groupData[model.name] = input
              }
            }
          }
        }
      }   
    } 
  }

  //List model roles name, unit, type, and hint set properties in the delegate created from an element.  The valid role
  // is bound to the delegate valid property, which we use to determine whether data is ready to be passed to create_substance().
  // The group role helps us sort the element into the appropriate DelegateModelGroup in substanceDelegateModel.
  ListModel {
    id : substanceListModel
    ListElement {name : "Name"; unit: ""; type : "string"; hint : "*Required"; valid : true; group : "physical"}
      ListElement {name : "State"; unit: "substanceState"; type : "enum"; hint : "*"; valid : true; group : "physical"}
      ListElement {name : "Classification"; unit : "substanceClass"; type : "enum"; hint : ""; valid : true; group : "physical"}
      ListElement {name : "MolarMass";  unit : "molar"; type : "double"; hint : "Enter a value"; valid : true; group : "physical"}
      ListElement {name : "Density";  unit : "concentration"; type : "double"; hint : "Enter a value"; valid : true; group : "physical"}
      ListElement {name : "MaximumDiffusionFlux"; unit : "massFlux"; type : "double"; hint : "Enter a value"; valid : true; group : "physical"}
      ListElement {name : "MichaelisCoefficient";  unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "physical"}
      ListElement {name : "MembraneResistance";  unit : "electricalResistance"; type : "double"; hint : "Enter a value"; valid : true; group : "physical"}
      ListElement {name : "RelativeDiffusionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "physical"}
      ListElement {name : "SolubilityCoefficient";  unit : "inversePressure"; type : "double"; hint : "Enter a value"; valid : true; group : "physical"}
    ListElement {name : "IntrinsicClearance"; unit : "volumetricFlowNorm"; type : "double"; hint : "Enter a value "; valid : true; group : "clearance_systemic"}
      ListElement {name : "RenalClearance"; unit : "volumetricFlowNorm"; type : "double"; hint : "Enter a value "; valid : true; group : "clearance_systemic"}
      ListElement {name : "SystemicClearance"; unit : "volumetricFlowNorm"; type : "double"; hint : "Enter a value "; valid : true; group : "clearance_systemic"}
      ListElement {name : "FractionUnboundInPlasma"; unit : ""; type : "0To1"; hint : "Enter a value [0-1]"; valid : true; group : "clearance_systemic"}
      ListElement {name : "FractionExcretedInFeces"; unit : ""; type : "0To1"; hint : "Enter a value [0-1]"; valid : true; group : "clearance_systemic"}
      ListElement {name : "Placeholder"; group : "clearance"; valid : true} //This is needed to get an even number of items in "clearance" so that the two clearance views aren't staggered
      ListElement {name : "ChargeInBlood"; unit : "charge"; type : "enum"; hint : ""; valid : true; group : "clearance_regulation"}
      ListElement {name : "ReabsorptionRatio"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "clearance_regulation"}  
      ListElement {name : "TransportMaximum"; unit : "massRate"; type : "double"; hint : "Enter a value"; valid : true; group : "clearance_regulation"} 
      ListElement {name : "FractionUnboundInPlasma"; unit : ""; type : "0To1"; hint : "Enter a value [0-1]"; valid : true; group : "clearance_regulation"}
    ListElement {name : "AcidDissociationConstant"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkPhysicochemical"}     
      ListElement {name : "BindingProtein"; unit : "protein"; type : "enum"; hint : ""; valid : true; group : "pkPhysicochemical"}     
      ListElement {name : "BloodPlasmaRatio"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkPhysicochemical"}     
      ListElement {name : "FractionUnboundInPlasma"; unit : ""; type : "0To1"; hint : "Enter a value [0-1]"; valid : true; group : "pkPhysicochemical"} 
      ListElement {name : "IonicState"; unit : "ionicState"; type : "enum"; hint : ""; valid : true; group : "pkPhysicochemical"} 
      ListElement {name : "LogP"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkPhysicochemical"}
      ListElement {name : "HydrogenBondCount"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkPhysicochemical"}
      ListElement {name : "PolarSurfaceArea"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkPhysicochemical"}
    ListElement {name : "BonePartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics"}
      ListElement {name : "BrainPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics"}
      ListElement {name : "FatPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics"}
      ListElement {name : "GutPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics"}
      ListElement {name : "LeftKidneyPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics"}
      ListElement {name : "LeftLungPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics"}
      ListElement {name : "LiverPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics"}
      ListElement {name : "MusclePartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics"}
      ListElement {name : "MyocardiumPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics"}
      ListElement {name : "RightKidneyPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics"}
      ListElement {name : "RightLungPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics"}
      ListElement {name : "SkinPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics"}
      ListElement {name : "SpleenPartitionCoefficient"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pkTissueKinetics"}
    ListElement {name : "EC50"; unit : "concentration"; type : "double"; hint : "Enter a value"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "ShapeParameter"; unit : ""; type : "double"; hint : "Enter a value"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "EffectSiteRateConstant"; unit : "frequency"; type : "double"; hint : "Enter a value"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "BronchodilationModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "DiastolicPressureModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "SystolicPressureModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "FeverModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "HeartRateModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "HemorrhageModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "NeuromuscularBlockModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "PainModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "RespirationRateModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "TidalVolumeModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "SedationModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "TubularPermeabilityModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "CentralNervousModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "AntibacterialEffect"; unit : "frequency"; type : "double"; hint : ""; valid : true; group : "pharmacodynamics"}
      ListElement {name : "Pupil-SizeModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
      ListElement {name : "Pupil-ReactivityModifier"; unit : ""; type : "-1To1"; hint : "Enter a value [-1-1]"; valid : true; group : "pharmacodynamics"}
  }


}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 