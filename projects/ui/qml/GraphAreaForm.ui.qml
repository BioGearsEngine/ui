import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtCharts 2.3
import QtQml.Models 2.2

Page {
  //id: root
  z : 0 //Explicitly setting this to lowest level so that messages displayed in Controls view will not get hidden behind plots

  property alias physiologyRequestModel : physiologyRequestModel

	property alias vitalsGridView : vitalsGridView
	property alias cardiopulmonaryGridView : cardiopulmonaryGridView
	property alias bloodChemistryGridView : bloodChemistryGridView
	property alias energyMetabolismGridView : energyMetabolismGridView
	property alias renalFluidBalanceGridView : renalFluidBalanceGridView
  property alias substanceGridView : substanceGridView
	property alias customGridView : customGridView

  property alias tenHzPlotTimer : tenHzPlotTimer
  property alias oneHzPlotTimer : oneHzPlotTimer
	//property alias hepaticGridView : hepaticGridView
	//property alias nervousGridView : nervousGridView
	//property alias renalGridView : renalGridView
	//property alias respiratoryGridView : respiratoryGridView
	//property alias tissueGridView : tissueGridView
  
  
	//property alias plotObjectModel : plotObjectModel

  state : "realTime"

  //The states defined for GraphArea relate to the timers that trigger plot updates. During "RealTime", the slower timer triggers plot updates every 1 s (1 Hz), 
    // while faster timer triggers every 0.1 s (10 Hz).  At maximum run rate, these refresh rates are multipled by factor of 5 (5 Hz for slow timer, 50 Hz for
    // fast timer) to keep up with BioGears metrics update rate.  By default, all plots are assigned to slower timer (see GraphArea.qml).  Only plots that
    // absolutely require a faster sampling rate for resolution (like pressure-volume curve) should connect plot to faster timer.
  states : [ 
      State {
        name : "realTime"
        PropertyChanges {target : tenHzPlotTimer; interval : 100}
        PropertyChanges {target : oneHzPlotTimer; interval : 1000}
      }
      ,State {
        name : "max"
        PropertyChanges {target : tenHzPlotTimer; interval : 20}
        PropertyChanges {target : oneHzPlotTimer; interval : 200}
      }
    ]

  header:  RowLayout {
    id: headerBar
    Layout.fillWidth : true
    Layout.fillHeight : true
    Button {
      id: previous
      text: "Prev"
      display: AbstractButton.IconOnly
      icon.source: "qrc:/icons/prev.png"
      icon.name: "terminate"
      icon.color: "transparent"
      background: Rectangle {
        color:"transparent"
      }
      onClicked: {
        if ( plots.currentIndex == 0 ) {
          plots.currentIndex = plots.count -1 ;
        } else {
          plots.currentIndex = plots.currentIndex - 1
        }
        if (systemSwipeView.currentItem.text != "Substances"){
          if (substanceMenu.visible){
            substanceMenu.close();
            filterMenu.open();
          } else {
            if (filterMenu.visible){
              //This overrides the "CloseOnReleaseOutside" policy so that menu stays open when switching to new view panel
              filterMenu.open()
            }
          }
        }
        if (systemSwipeView.currentItem.text === "Substances" && filterMenu.visible){
          substanceMenu.open();
          filterMenu.close();
        }
      }
    }
    SwipeView {
      id : systemSwipeView
      contentHeight: 40
      Layout.fillWidth : true
      Layout.preferredWidth : 200
      Layout.preferredHeight : 40
      font.pointSize: 12
      clip:true
      UITabButtonForm {
        id: bloodChemistryButton
        text: qsTr("Vitals")
      }
      UITabButtonForm {
        id: cardiovascularButton
        text: qsTr("Cardiopulmonary")
      }
      UITabButtonForm {
        id: drugsButton
        text: qsTr("Blood Chemistry")
      }
      UITabButtonForm {
        id: endocrineButton
        text: qsTr("Energy and Metabolism")
      }
      UITabButtonForm {
        id: energyButton
        text: qsTr("Renal and Fluid Balance")
      }
      UITabButtonForm {
        id : substanceButton
        text : qsTr("Substances")
      }
      UITabButtonForm {
        id : customPlotsButton
        text : qsTr("Custom Plots")
      }
      currentIndex: plots.currentIndex

      onCurrentIndexChanged : {
          if( plots.currentIndex != currentIndex){
              plots.currentIndex = currentIndex;
          }
      }
    }
    Button {
      id: filterMenuButton
      text: "Filter Menu"
      display: AbstractButton.IconOnly
      icon.source: "qrc:/icons/menu.png"
      icon.name: "terminate"
      icon.color: "transparent"
      onClicked: {
        if (systemSwipeView.currentItem.text === "Substances"){
          if (substanceMenu.visible){
            substanceMenu.close()
          } else {
            substanceMenu.open()
          }
        } else {
          if (filterMenu.visible){
            filterMenu.close()
          } else {
            filterMenu.open()
          }
        }
      }
      background: Rectangle {
        color:"transparent"
      }
      Menu {
        id: filterMenu
        x : -200
        y : 50
        closePolicy : Popup.CloseOnEscape | Popup.CloseOnReleaseOutside
        Repeater {
          id : filterMenuInstance
          model : physiologyRequestModel.get(plots.currentIndex).requests
          delegate : MenuItem {
            CheckBox { 
              checkable : true
              checked : active
              text : root.formatRequest(request)
              onClicked : {
                active = checked
                if (checked){
							    createPlotView(plots.currentIndex, model)
								} else {
									removePlotView(plots.currentIndex, model.request)
								}
              }
            }
          }
        }
      }
      Menu {
        id : substanceMenu
        x : -200
        y : 50
        closePolicy : Popup.CloseOnEscape | Popup.CloseOnReleaseOutside
        Instantiator {
          id : menuItemInstance
          model : substanceMenuListModel
          delegate : Menu {
            id : substanceSubMenu
            title : subName
            property int delegateIndex : index
            property string sub : subName
            Repeater {
              id : subMenuInstance
              model : substanceMenuListModel.get(substanceSubMenu.delegateIndex).props
              delegate : MenuItem {
                CheckBox { 
                  checkable : true
                  checked : false
                  text : root.formatRequest(propName)
                  onClicked : {
                    console.log(sub + " : " + text)
                    if (checked){
											createPlotView(plots.currentIndex, {"request" : sub + "-" + text})    //createPlotView expects an object with "request" role
										} else {
											removePlotView(plots.currentIndex, sub + "-" + text)
										}
                  }
                }
              }
            }
          }
          onObjectAdded : {
            substanceMenu.addMenu(object)  
          }
          onObjectRemoved : {
            substanceMenu.removeMenu(object)
          }
        }    
      }

    }

    Button {
      id: next
      text: "Next"
      display: AbstractButton.IconOnly
      icon.source: "qrc:/icons/next.png"
      icon.name: "terminate"
      icon.color: "transparent"
      onClicked: {
        if ( plots.currentIndex == plots.count -1 ) {
          plots.currentIndex = 0;
        } else {
          plots.currentIndex = plots.currentIndex + 1
        }
        if (systemSwipeView.currentItem.text != "Substances"){
          if (substanceMenu.visible){
            substanceMenu.close();
            filterMenu.open();
          } else {
            if (filterMenu.visible){
              //This overrides the "CloseOnReleaseOutside" policy so that menu stays open when switching to new view panel
              filterMenu.open()
            }
          }
        }
        if (systemSwipeView.currentItem.text === "Substances" && filterMenu.visible){
          substanceMenu.open();
          filterMenu.close();
        }
      }
      background: Rectangle {
        color:"transparent"
      }
    }
  }
    
  SwipeView {
    id: plots
    anchors.fill: parent
    currentIndex:0
    clip:true
    Item {
	    id: vitalsSeries
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Rectangle {
		    id: vitalsBackground
		    anchors.fill: parent
		    color: "#7CB342"
	    }
	    GridView {
		    id: vitalsGridView
		    anchors.fill: parent
		    clip: true
		    cellWidth: parent.width / 2
		    cellHeight: parent.height / 2
		    model: vitalsModel
		    ScrollBar.vertical: ScrollBar {
          parent: vitalsGridView.parent
          anchors.top: vitalsGridView.top
          anchors.right: vitalsGridView.right
          anchors.bottom: vitalsGridView.bottom
        }
	    }
    }
    Item {
	    id: cardiopulmonarySeries
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Rectangle {
		    id: cardiovascularBackground
		    anchors.fill: parent
		    color: "#7CB342"
	    }
	    GridView {
		    id: cardiopulmonaryGridView
		    anchors.fill: parent
		    clip: true
		    cellWidth: plots.width / 2
		    cellHeight: plots.height / 2
		    model: cardiopulmonaryModel
		    ScrollBar.vertical: ScrollBar {
          parent: cardiopulmonaryGridView.parent
          anchors.top: cardiopulmonaryGridView.top
          anchors.right: cardiopulmonaryGridView.right
          anchors.bottom: cardiopulmonaryGridView.bottom
        }
	    }
    }
    Item {
	    id: bloodChemistrySeries
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Rectangle {
		    id: bloodChemistryBackground
		    anchors.fill: parent
		    color: "#7CB342"
	    }
	    GridView {
		    id: bloodChemistryGridView
		    anchors.fill: parent
		    clip: true
		    cellWidth: plots.width / 2
		    cellHeight: plots.height / 2
		    model: bloodChemistryModel
		    ScrollBar.vertical: ScrollBar {
          parent: bloodChemistryGridView.parent
          anchors.top: bloodChemistryGridView.top
          anchors.right: bloodChemistryGridView.right
          anchors.bottom: bloodChemistryGridView.bottom
        }
	    }
    }
    Item {
	    id: energyMetabolismSeries
	    Layout.fillWidth: true
	    Layout.fillHeight: true

	    Rectangle {
		    id: energyMetabolismBackground
		    anchors.fill: parent
		    color: "#7CB342"
	    }
	    GridView {
		    id: energyMetabolismGridView
		    anchors.fill: parent
		    clip: true
		    width : parent.width
		    cellWidth: plots.width / 2
		    cellHeight: plots.height / 2
		    model: energyMetabolismModel
		    ScrollBar.vertical: ScrollBar {
          parent: energyMetabolismGridView.parent
          anchors.top: energyMetabolismGridView.top
          anchors.right: energyMetabolismGridView.right
          anchors.bottom: energyMetabolismGridView.bottom
        }
	    }
    }
    Item {
	    id: renalFluidBalanceSeries
	    Layout.fillWidth: true
	    Layout.fillHeight: true

	    Rectangle {
		    id: renalFluidBalanceBackground
		    anchors.fill: parent
		    color: "#7CB342"
	    }
	    GridView {
		    id: renalFluidBalanceGridView
		    anchors.fill: parent
		    clip: true
		    cellWidth: plots.width / 2
		    cellHeight: plots.height / 2
		    model: renalFluidBalanceModel
		    ScrollBar.vertical: ScrollBar {
          parent: renalFluidBalanceGridView.parent
          anchors.top: renalFluidBalanceGridView.top
          anchors.right: renalFluidBalanceGridView.right
          anchors.bottom: renalFluidBalanceGridView.bottom
        }
	    }
    }
    Item {
	    id: substanceSeries
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Rectangle {
		    id: substanceBackground
		    anchors.fill: parent
		    color: "#7CB342"
	    }
      GridView {
		    id: substanceGridView
		    anchors.fill: parent
		    clip: true
		    cellWidth: plots.width / 2
		    cellHeight: plots.height / 2
		    model: substanceModel
		    ScrollBar.vertical: ScrollBar {
          parent: substanceGridView.parent
          anchors.top: substanceGridView.top
          anchors.right: substanceGridView.right
          anchors.bottom: substanceGridView.bottom
        }
	    }
    }
    Item {
	    id: customSeries
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Rectangle {
		    id: customBackground
		    anchors.fill: parent
		    color: "#7CB342"
	    }
	    GridView {
		    id: customGridView
		    anchors.fill: parent
		    clip: true
		    cellWidth: plots.width / 2
		    cellHeight: plots.height / 2
		    model: customModel
        ScrollBar.vertical: ScrollBar {
          parent: customGridView.parent
          anchors.top: customGridView.top
          anchors.right: customGridView.right
          anchors.bottom: customGridView.bottom
        }
	    }
    }
  /*  Item {
	    id: hepaticSeries
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Rectangle {
		    id: hepaticBackground
		    anchors.fill: parent
		    color: "#7CB342"
	    }
	    GridView {
		    id: hepaticGridView
		    anchors.fill: parent
		    clip: true
		    cellWidth: plots.width / 2
		    cellHeight: plots.height / 2
		    model: hepaticModel
		    ScrollBar.vertical: ScrollBar {
          parent: hepaticGridView.parent
          anchors.top: hepaticGridView.top
          anchors.right: hepaticGridView.right
          anchors.bottom: hepaticGridView.bottom
        }
	    }
    }
    Item {
	    id: nervousSeries
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Rectangle {
		    id: nervousBackground
		    anchors.fill: parent
		    color: "#7CB342"
	    }
	    GridView {
		    id: nervousGridView
		    anchors.fill: parent
		    clip: true
		    cellWidth: plots.width / 2
		    cellHeight: plots.height / 2
		    model: nervousModel
		    ScrollBar.vertical: ScrollBar {
          parent: nervousGridView.parent
          anchors.top: nervousGridView.top
          anchors.right: nervousGridView.right
          anchors.bottom: nervousGridView.bottom
        }
	    }
    }
    Item {
	    id: renalSeries
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Rectangle {
		    id: renalBackground
		    anchors.fill: parent
		    color: "#7CB342"
	    }
	    GridView {
		    id: renalGridView
		    anchors.fill: parent
		    clip: true
		    cellWidth: plots.width / 2
		    cellHeight: plots.height / 2
		    model: renalModel
		    ScrollBar.vertical: ScrollBar {
          parent: renalGridView.parent
          anchors.top: renalGridView.top
          anchors.right: renalGridView.right
          anchors.bottom: renalGridView.bottom
        }
	    }
    }
    Item {
	    id: respiratorySeries
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Rectangle {
		    id: respiratoryBackground
		    anchors.fill: parent
		    color: "#7CB342"
	    }
	    GridView {
		    id: respiratoryGridView
		    anchors.fill: parent
		    clip: true
		    cellWidth: plots.width / 2
		    cellHeight: plots.height / 2
		    model: respiratoryModel
		    ScrollBar.vertical: ScrollBar {
          parent: respiratoryGridView.parent
          anchors.top: respiratoryGridView.top
          anchors.right: respiratoryGridView.right
          anchors.bottom: respiratoryGridView.bottom
        }
	    }
    }
    Item {
	    id: tissueSeries
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Rectangle {
		    id: tissueBackground
		    anchors.fill: parent
		    color: "#7CB342"
	    }
	    GridView {
		    id: tissueGridView
		    anchors.fill: parent
		    clip: true
		    cellWidth: plots.width / 2
		    cellHeight: plots.height / 2
		    model: tissueModel
		    ScrollBar.vertical: ScrollBar {
          parent: tissueGridView.parent
          anchors.top: tissueGridView.top
          anchors.right: tissueGridView.right
          anchors.bottom: tissueGridView.bottom
        }
	    }
    }
 */   
  }
  PageIndicator {
    id: indicator

    count: plots.count
    currentIndex: plots.currentIndex

    anchors.bottom: plots.bottom
    anchors.horizontalCenter: plots.horizontalCenter
  }


ListModel {
  id: physiologyRequestModel
  ListElement {
    system : "Vitals"
	  activeRequests: [ ]
    requests:  [
      ListElement {request:"bloodPressure"; active: false;
                    subRequests: [ListElement {subRequest: "diastolicArterialPressure"}, ListElement{subRequest:"systolicArterialPressure"}]}
      ,ListElement {request:"respirationRate"; active: false}
      ,ListElement {request:"heartRate"; active: false}
      ,ListElement {request:"oxygenSaturation"; active: false}
      ,ListElement {request:"cardiacOutput"; active: false}
      ,ListElement {request:"bloodVolume"; active: false}
      ,ListElement {request:"heartStrokeVolume"; active: false}
      ,ListElement {request:"tidalVolume"; active: true}
      ,ListElement {request:"centralVenousPressure"; active: false}
    ]
  }
  ListElement {
    system : "Cardiopulmonary"
	  activeRequests: []
    requests:  [
      ListElement {request:"cerebralPerfusionPressure"; active: false}
      ,ListElement {request:"intracranialPressure"; active: false}
      ,ListElement {request:"systemicVascularResistance"; active: false}
      ,ListElement {request:"pulsePressure"; active: false}
      ,ListElement {request:"inspiratoryExpiratoryRatio"; active: false}
      ,ListElement {request:"cerebralBloodFlow"; active: false}
      ,ListElement {request:"totalPulmonaryVentilation"; active: false}
      ,ListElement {request:"totalLungVolume"; active: false}
      ,ListElement {request:"totalAlveolarVentilation"; active: false}
      ,ListElement {request:"deadSpaceVentilation"; active: false}
      ,ListElement {request:"transpulmonaryPressure"; active: false}
      ,ListElement {request:"meanArterialPressure"; active: false}
    ]
  }
  ListElement {
    system : "BloodChemistry"
	  activeRequests: []
    requests:  [
      ListElement {request:"bloodGasLevels"; active: false;
        subRequests: [ListElement {subRequest: "arterialOxygenPressure"}, ListElement{subRequest:"arterialCarbonDioxidePressure"}]}
      ,ListElement {request:"arterialBloodPH"; active: false}
      ,ListElement {request:"hematocrit"; active: false}
    ]
  }
  ListElement {
    system : "EnergyMetabolism"
	  activeRequests: []
    requests:  [
      ListElement {request:"coreTemperature"; active: false}
      ,ListElement {request:"skinTemperature"; active: false}
      ,ListElement {request:"totalMetabolicRate"; active: false}
      ,ListElement {request:"sweatRate"; active: false}
      ,ListElement {request:"carbonDioxideProductionRate"; active: false}
      ,ListElement {request:"oxygenConsumptionRate"; active: false}
      ,ListElement {request:"stomachContents"; active: false;
        subRequests: [ListElement {subRequest: "stomachContents_carbohydrates"}, ListElement{subRequest: "stomachContents_fat"}, ListElement{subRequest:"stomachContents_protein"}, ListElement{subRequest:"stomachContents_water"}]}
    ]
  }


  ListElement {
    system : "RenalFluidBalance"
    activeRequests: []
    requests:  [
      ListElement {request:"renalBloodFlow"; active: false}
      ,ListElement {request:"glomerularFiltrationRate"; active: false}
      ,ListElement {request:"urineOutput"; active: false; 
        subRequests : [ListElement {subRequest : "urineProductionRate"}, ListElement {subRequest : "meanUrineOutput"}]}
      ,ListElement{request:"urineVolume"; active: false}
      ,ListElement{request:"extracellularFluidVolume"; active: false}
      ,ListElement{request:"extravascularFluidVolume"; active: false}
      ,ListElement{request:"intracellularFluidVolume"; active: false}
      ,ListElement{request:"totalBodyFluidVolume"; active: false}
      
    ]
  }

  ListElement {
    system : "Substances"
    activeRequests : []
    requests : []    //Requests are managed by substanceMenuListModel--going to try to merge all these lists soon
  }

  ListElement {
    system : "CustomViews"
    activeRequests : []
    requests : [
      ListElement {request: "respiratoryPVCycle"; active :false} 
    ]
  }
}

Timer {
  id : tenHzPlotTimer
  interval : 100
  running : false
  repeat : true
  triggeredOnStart : true
  onTriggered : {
    root.tenHzPlotRefresh(plotMetrics)
  }
}

Timer {
  id : oneHzPlotTimer
  interval : 1000
  running : false
  repeat : true
  triggeredOnStart : true
  onTriggered : {
    root.oneHzPlotRefresh(plotMetrics)
  }
}
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
