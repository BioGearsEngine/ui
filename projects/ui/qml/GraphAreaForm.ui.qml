import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtCharts 2.3
import QtQml.Models 2.2

Page {
    id: root
    
    property alias physiologyRequestModel : physiologyRequestModel
	property alias bloodChemistryModel : bloodChemistryObjectModel
	property alias cardiovascularModel : cardiovascularObjectModel
	property alias drugModel : drugObjectModel
	property alias endocrineModel : endocrineObjectModel
	property alias energyModel : energyObjectModel
	property alias gastrointestinalModel : gastrointestinalObjectModel
	property alias hepaticModel : hepaticObjectModel
	property alias nervousModel : nervousObjectModel
	property alias renalModel : renalObjectModel
	property alias respiratoryModel : respiratoryObjectModel
	property alias tissueModel : tissueObjectModel

	//property alias plotObjectModel : plotObjectModel

    

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
            }
        }
        SwipeView {
            contentHeight: 40
            Layout.fillWidth : true
            Layout.preferredWidth : 200
            Layout.preferredHeight : 40
            font.pointSize: 12
            clip:true
            UITabButtonForm {
                id: bloodChemistryButton
                text: qsTr("Blood Chemistry")
            }
            UITabButtonForm {
                id: cardiovascularButton
                text: qsTr("Cardiovascular")
            }
            UITabButtonForm {
                id: drugsButton
                text: qsTr("Drugs")
            }
            UITabButtonForm {
                id: endocrineButton
                text: qsTr("Endocrine")
            }
            UITabButtonForm {
                id: energyButton
                text: qsTr("Energy")
            }
            UITabButtonForm {
                id: gastronintestinalButton
                text: qsTr("Gastrointestinal")
            }
            UITabButtonForm {
                id: hepaticButton
                text: qsTr("Hepatic")
            }
            UITabButtonForm {
                id: nervousButton
                text: qsTr("Nervous")
            }
            UITabButtonForm {
                id: renalButton
                text: qsTr("Renal")
            }
            UITabButtonForm {
                id: respritoryButton
                text: qsTr("Respiratory")
            }
            UITabButtonForm {
                id: tissueButton
                text: qsTr("Tissue")
            }
            currentIndex: plots.currentIndex
        }
        Button {
            id: filterMenuButton
            text: "Filter Menu"
            display: AbstractButton.IconOnly
            icon.source: "qrc:/icons/menu.png"
            icon.name: "terminate"
            icon.color: "transparent"
            onClicked: {
                console.log("Clicked Burger Menu")
                filterMenu.visible = ! filterMenu.visible
            }
            background: Rectangle {
                color:"transparent"
            }
            Rectangle {
                id: filterMenu
                anchors.top : filterMenuButton.bottom; anchors.right : filterMenuButton.right
                height: root.height
                width: root.width / 4
                color : Material.color(Material.Grey)
                visible : false
                Flickable{
                    id: filterMenuFlickable
                    anchors.fill : parent
                    height : parent.height
                    width  : parent.width
                    contentHeight : filterMenuLayout.height
                    clip : true
                    ColumnLayout {
                        id : filterMenuLayout
                        Repeater {
                            id: filterMenuRepeater
                            Layout.margins:0
                            model: physiologyRequestModel.get(plots.currentIndex).requests
                            delegate: Row {
                                CheckBox {
                                    text: model.request
                                    checked: model.active
                                    Layout.fillWidth : true
                                    Layout.preferredWidth : 10
                                    onClicked : {
                                        physiologyRequestModel.get(plots.currentIndex).requests.setProperty(index, "active", checked)
										if (checked){
											createPlotView(plots.currentIndex, model.request)
										} else {
											removePlotView(plots.currentIndex, model.request)
										}
                                    }
                                }
                            }
                        }
                    }
                    ScrollBar.vertical: ScrollBar {
                        parent: filterMenuFlickable.parent
                        anchors.top: filterMenuFlickable.top
                        anchors.left: filterMenuFlickable.right
                        anchors.bottom: filterMenuFlickable.bottom
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
			id: bloodChemistrySeries
			Layout.fillWidth: true
			Layout.fillHeight: true

			Rectangle {
				id: bloodChemistryBackground
				anchors.fill: parent
				color: "#7CB342"
			}

			ObjectModel {
				id: bloodChemistryObjectModel
				function createPlotView (request) {
					var chartComponent = Qt.createComponent("UIPlotSeries.qml");
					if ( chartComponent.status != Component.Ready){
						if (chartComponent.status == Component.Error){
							console.log("Error : " + chartComponent.errorString() );
							return;
						}
						console.log("Error : Chart component not ready");
					} else {
						var chartObject = chartComponent.createObject(bloodChemistryGridView,{"width" : bloodChemistryGridView.cellWidth, "height" :  bloodChemistryGridView.cellHeight });
						chartObject.initializeChart(request, root.tickCount);
						root.metricUpdates.connect(chartObject.updateSeries)
						bloodChemistryObjectModel.append(chartObject)
					}
				}
				function resizePlots(newWidth, newHeight){
					for (var i = 0; i < bloodChemistryObjectModel.count; ++i){
						bloodChemistryObjectModel.get(i).resizePlot(newWidth, newHeight);
					}
				}
			}

			GridView {
				id: bloodChemistryGridView
				anchors.fill: parent
				clip: true
				cellWidth: plots.width / 2
				cellHeight: plots.height / 2
				model: bloodChemistryObjectModel

				onCellWidthChanged : {
					bloodChemistryObjectModel.resizePlots(bloodChemistryGridView.cellWidth, bloodChemistryGridView.cellHeight)
				}
				onCellHeightChanged : {
					bloodChemistryObjectModel.resizePlots(bloodChemistryGridView.cellWidth, bloodChemistryGridView.cellHeight)
				}

				ScrollBar.vertical: ScrollBar {
                    parent: bloodChemistryGridView.parent
                    anchors.top: bloodChemistryGridView.top
                    anchors.right: bloodChemistryGridView.right
                    anchors.bottom: bloodChemistryGridView.bottom
                }
			}
		}

        Item {
			id: cardiovascularSeries
			Layout.fillWidth: true
			Layout.fillHeight: true

			Rectangle {
				id: cardiovascularBackground
				anchors.fill: parent
				color: "#7CB342"
			}

			ObjectModel {
				id: cardiovascularObjectModel
				function createPlotView (request) {
					var chartComponent = Qt.createComponent("UIPlotSeries.qml");
					if ( chartComponent.status != Component.Ready){
						if (chartComponent.status == Component.Error){
							console.log("Error : " + chartComponent.errorString() );
							return;
						}
						console.log("Error : Chart component not ready");
					} else {
						var chartObject = chartComponent.createObject(cardiovascularGridView,{"width" : cardiovascularGridView.cellWidth, "height" : cardiovascularGridView.cellHeight });
						chartObject.initializeChart(request, root.tickCount);
						root.metricUpdates.connect(chartObject.updateSeries)
						cardiovascularObjectModel.append(chartObject)
					}
				}
				function resizePlots(newWidth, newHeight){
					for (var i = 0; i < cardiovascularObjectModel.count; ++i){
						cardiovascularObjectModel.get(i).resizePlot(newWidth, newHeight);
					}
				}
			}

			GridView {
				id: cardiovascularGridView
				anchors.fill: parent
				clip: true
				cellWidth: plots.width / 2
				cellHeight: plots.height / 2
				model: cardiovascularObjectModel

				onCellWidthChanged : {
					cardiovascularObjectModel.resizePlots(cardiovascularGridView.cellWidth, cardiovascularGridView.cellHeight)
				}
				onCellHeightChanged : {
					cardiovascularObjectModel.resizePlots(cardiovascularGridView.cellWidth, cardiovascularGridView.cellHeight)
				}

				ScrollBar.vertical: ScrollBar {
                    parent: cardiovascularGridView.parent
                    anchors.top: cardiovascularGridView.top
                    anchors.right: cardiovascularGridView.right
                    anchors.bottom: cardiovascularGridView.bottom
                }
			}
		}

		Item {
			id: drugSeries
			Layout.fillWidth: true
			Layout.fillHeight: true

			Rectangle {
				id: drugBackground
				anchors.fill: parent
				color: "#7CB342"
			}

			ObjectModel {
				id: drugObjectModel
				function createPlotView (request) {
					var chartComponent = Qt.createComponent("UIPlotSeries.qml");
					if ( chartComponent.status != Component.Ready){
						if (chartComponent.status == Component.Error){
							console.log("Error : " + chartComponent.errorString() );
							return;
						}
						console.log("Error : Chart component not ready");
					} else {
						var chartObject = chartComponent.createObject(drugGridView,{"width" : drugGridView.cellWidth, "height" : drugGridView.cellHeight });
						chartObject.initializeChart(request, root.tickCount);
						root.metricUpdates.connect(chartObject.updateSeries)
						drugObjectModel.append(chartObject)
					}
				}
				function resizePlots(newWidth, newHeight){
					for (var i = 0; i < drugObjectModel.count; ++i){
						drugObjectModel.get(i).resizePlot(newWidth, newHeight);
					}
				}
			}

			GridView {
				id: drugGridView
				anchors.fill: parent
				clip: true
				cellWidth: plots.width / 2
				cellHeight: plots.height / 2
				model: drugObjectModel

				onCellWidthChanged : {
					drugObjectModel.resizePlots(drugGridView.cellWidth, drugGridView.cellHeight)
				}
				onCellHeightChanged : {
					drugObjectModel.resizePlots(drugGridView.cellWidth, drugGridView.cellHeight)
				}

				ScrollBar.vertical: ScrollBar {
                    parent: drugGridView.parent
                    anchors.top: drugGridView.top
                    anchors.right: drugGridView.right
                    anchors.bottom: drugGridView.bottom
                }
			}
		}

		Item {
			id: endocrineSeries
			Layout.fillWidth: true
			Layout.fillHeight: true

			Rectangle {
				id: endocrineBackground
				anchors.fill: parent
				color: "#7CB342"
			}

			ObjectModel {
				id: endocrineObjectModel
				function createPlotView (request) {
					var chartComponent = Qt.createComponent("UIPlotSeries.qml");
					if ( chartComponent.status != Component.Ready){
						if (chartComponent.status == Component.Error){
							console.log("Error : " + chartComponent.errorString() );
							return;
						}
						console.log("Error : Chart component not ready");
					} else {
						var chartObject = chartComponent.createObject(endocrineGridView,{"width" : endocrineGridView.cellWidth, "height" : endocrineGridView.cellHeight });
						chartObject.initializeChart(request, root.tickCount);
						root.metricUpdates.connect(chartObject.updateSeries)
						endocrineObjectModel.append(chartObject)
					}
				}
				function resizePlots(newWidth, newHeight){
					for (var i = 0; i < endocrineObjectModel.count; ++i){
						endocrineObjectModel.get(i).resizePlot(newWidth, newHeight);
					}
				}
			}

			GridView {
				id: endocrineGridView
				anchors.fill: parent
				clip: true
				cellWidth: plots.width / 2
				cellHeight: plots.height / 2
				model: endocrineObjectModel

				onCellWidthChanged : {
					endocrineObjectModel.resizePlots(endocrineGridView.cellWidth, endocrineGridView.cellHeight)
				}
				onCellHeightChanged : {
					endocrineObjectModel.resizePlots(endocrineGridView.cellWidth, endocrineGridView.cellHeight)
				}

				ScrollBar.vertical: ScrollBar {
                    parent: endocrineGridView.parent
                    anchors.top: endocrineGridView.top
                    anchors.right: endocrineGridView.right
                    anchors.bottom: endocrineGridView.bottom
                }
			}
		}
        
		Item {
			id: energySeries
			Layout.fillWidth: true
			Layout.fillHeight: true

			Rectangle {
				id: energyBackground
				anchors.fill: parent
				color: "#7CB342"
			}

			ObjectModel {
				id: energyObjectModel
				function createPlotView (request) {
					var chartComponent = Qt.createComponent("UIPlotSeries.qml");
					if ( chartComponent.status != Component.Ready){
						if (chartComponent.status == Component.Error){
							console.log("Error : " + chartComponent.errorString() );
							return;
						}
						console.log("Error : Chart component not ready");
					} else {
						var chartObject = chartComponent.createObject(energyGridView,{"width" : energyGridView.cellWidth, "height" : energyGridView.cellHeight });
						chartObject.initializeChart(request, root.tickCount);
						root.metricUpdates.connect(chartObject.updateSeries)
						energyObjectModel.append(chartObject)
					}
				}
				function resizePlots(newWidth, newHeight){
					for (var i = 0; i < energyObjectModel.count; ++i){
						energyObjectModel.get(i).resizePlot(newWidth, newHeight);
					}
				}
			}

			GridView {
				id: energyGridView
				anchors.fill: parent
				clip: true
				cellWidth: plots.width / 2
				cellHeight: plots.height / 2
				model: energyObjectModel

				onCellWidthChanged : {
					energyObjectModel.resizePlots(energyGridView.cellWidth, energyGridView.cellHeight)
				}
				onCellHeightChanged : {
					energyObjectModel.resizePlots(energyGridView.cellWidth, energyGridView.cellHeight)
				}

				ScrollBar.vertical: ScrollBar {
                    parent: energyGridView.parent
                    anchors.top: energyGridView.top
                    anchors.right: energyGridView.right
                    anchors.bottom: energyGridView.bottom
                }
			}
		}

		Item {
			id: gastrointestinalSeries
			Layout.fillWidth: true
			Layout.fillHeight: true

			Rectangle {
				id: gastrointestinalBackground
				anchors.fill: parent
				color: "#7CB342"
			}

			ObjectModel {
				id: gastrointestinalObjectModel
				function createPlotView (request) {
					var chartComponent = Qt.createComponent("UIPlotSeries.qml");
					if ( chartComponent.status != Component.Ready){
						if (chartComponent.status == Component.Error){
							console.log("Error : " + chartComponent.errorString() );
							return;
						}
						console.log("Error : Chart component not ready");
					} else {
						var chartObject = chartComponent.createObject(gastrointestinalGridView,{"width" : gastrointestinalGridView.cellWidth, "height" : gastrointestinalGridView.cellHeight });
						chartObject.initializeChart(request, root.tickCount);
						root.metricUpdates.connect(chartObject.updateSeries)
						gastrointestinalObjectModel.append(chartObject)
					}
				}
				function resizePlots(newWidth, newHeight){
					for (var i = 0; i < gastrointestinalObjectModel.count; ++i){
						gastrointestinalObjectModel.get(i).resizePlot(newWidth, newHeight);
					}
				}
			}

			GridView {
				id: gastrointestinalGridView
				anchors.fill: parent
				clip: true
				cellWidth: plots.width / 2
				cellHeight: plots.height / 2
				model: gastrointestinalObjectModel

				onCellWidthChanged : {
					gastrointestinalObjectModel.resizePlots(gastrointestinalGridView.cellWidth, gastrointestinalGridView.cellHeight)
				}
				onCellHeightChanged : {
					gastrointestinalObjectModel.resizePlots(gastrointestinalGridView.cellWidth, gastrointestinalGridView.cellHeight)
				}

				ScrollBar.vertical: ScrollBar {
                    parent: gastrointestinalGridView.parent
                    anchors.top: gastrointestinalGridView.top
                    anchors.right: gastrointestinalGridView.right
                    anchors.bottom: gastrointestinalGridView.bottom
                }
			}
		}

		Item {
			id: hepaticSeries
			Layout.fillWidth: true
			Layout.fillHeight: true

			Rectangle {
				id: hepaticBackground
				anchors.fill: parent
				color: "#7CB342"
			}

			ObjectModel {
				id: hepaticObjectModel
				function createPlotView (request) {
					var chartComponent = Qt.createComponent("UIPlotSeries.qml");
					if ( chartComponent.status != Component.Ready){
						if (chartComponent.status == Component.Error){
							console.log("Error : " + chartComponent.errorString() );
							return;
						}
						console.log("Error : Chart component not ready");
					} else {
						var chartObject = chartComponent.createObject(hepaticGridView,{"width" : hepaticGridView.cellWidth, "height" : hepaticGridView.cellHeight });
						chartObject.initializeChart(request, root.tickCount);
						root.metricUpdates.connect(chartObject.updateSeries)
						hepaticObjectModel.append(chartObject)
					}
				}
				function resizePlots(newWidth, newHeight){
					for (var i = 0; i < hepaticObjectModel.count; ++i){
						hepaticObjectModel.get(i).resizePlot(newWidth, newHeight);
					}
				}
			}

			GridView {
				id: hepaticGridView
				anchors.fill: parent
				clip: true
				cellWidth: plots.width / 2
				cellHeight: plots.height / 2
				model: hepaticObjectModel

				onCellWidthChanged : {
					hepaticObjectModel.resizePlots(hepaticGridView.cellWidth, hepaticGridView.cellHeight)
				}
				onCellHeightChanged : {
					hepaticObjectModel.resizePlots(hepaticGridView.cellWidth, hepaticGridView.cellHeight)
				}

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

			ObjectModel {
				id: nervousObjectModel
				function createPlotView (request) {
					var chartComponent = Qt.createComponent("UIPlotSeries.qml");
					if ( chartComponent.status != Component.Ready){
						if (chartComponent.status == Component.Error){
							console.log("Error : " + chartComponent.errorString() );
							return;
						}
						console.log("Error : Chart component not ready");
					} else {
						var chartObject = chartComponent.createObject(nervousGridView,{"width" : nervousGridView.cellWidth, "height" : nervousGridView.cellHeight });
						chartObject.initializeChart(request, root.tickCount);
						root.metricUpdates.connect(chartObject.updateSeries)
						nervousObjectModel.append(chartObject)
					}
				}
				function resizePlots(newWidth, newHeight){
					for (var i = 0; i < nervousObjectModel.count; ++i){
						nervousObjectModel.get(i).resizePlot(newWidth, newHeight);
					}
				}
			}

			GridView {
				id: nervousGridView
				anchors.fill: parent
				clip: true
				cellWidth: plots.width / 2
				cellHeight: plots.height / 2
				model: nervousObjectModel

				onCellWidthChanged : {
					nervousObjectModel.resizePlots(nervousGridView.cellWidth, nervousGridView.cellHeight)
				}
				onCellHeightChanged : {
					nervousObjectModel.resizePlots(nervousGridView.cellWidth, nervousGridView.cellHeight)
				}

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

			ObjectModel {
				id: renalObjectModel
				function createPlotView (request) {
					var chartComponent = Qt.createComponent("UIPlotSeries.qml");
					if ( chartComponent.status != Component.Ready){
						if (chartComponent.status == Component.Error){
							console.log("Error : " + chartComponent.errorString() );
							return;
						}
						console.log("Error : Chart component not ready");
					} else {
						var chartObject = chartComponent.createObject(renalGridView,{"width" : renalGridView.cellWidth, "height" : renalGridView.cellHeight });
						chartObject.initializeChart(request, root.tickCount);
						root.metricUpdates.connect(chartObject.updateSeries)
						renalObjectModel.append(chartObject)
					}
				}
				function resizePlots(newWidth, newHeight){
					for (var i = 0; i < renalObjectModel.count; ++i){
						renalObjectModel.get(i).resizePlot(newWidth, newHeight);
					}
				}
			}

			GridView {
				id: renalGridView
				anchors.fill: parent
				clip: true
				cellWidth: plots.width / 2
				cellHeight: plots.height / 2
				model: renalObjectModel

				onCellWidthChanged : {
					renalObjectModel.resizePlots(renalGridView.cellWidth, renalGridView.cellHeight)
				}
				onCellHeightChanged : {
					renalObjectModel.resizePlots(renalGridView.cellWidth, renalGridView.cellHeight)
				}

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

			ObjectModel {
				id: respiratoryObjectModel
				function createPlotView (request) {
					var chartComponent = Qt.createComponent("UIPlotSeries.qml");
					if ( chartComponent.status != Component.Ready){
						if (chartComponent.status == Component.Error){
							console.log("Error : " + chartComponent.errorString() );
							return;
						}
						console.log("Error : Chart component not ready");
					} else {
						var chartObject = chartComponent.createObject(respiratoryGridView,{"width" : respiratoryGridView.cellWidth, "height" : respiratoryGridView.cellHeight });
						chartObject.initializeChart(request, root.tickCount);
						root.metricUpdates.connect(chartObject.updateSeries)
						respiratoryObjectModel.append(chartObject)
					}
				}
				function resizePlots(newWidth, newHeight){
					for (var i = 0; i < respiratoryObjectModel.count; ++i){
						respiratoryObjectModel.get(i).resizePlot(newWidth, newHeight);
					}
				}
			}

			GridView {
				id: respiratoryGridView
				anchors.fill: parent
				clip: true
				cellWidth: plots.width / 2
				cellHeight: plots.height / 2
				model: respiratoryObjectModel

				onCellWidthChanged : {
					respiratoryObjectModel.resizePlots(respiratoryGridView.cellWidth, respiratoryGridView.cellHeight)
				}
				onCellHeightChanged : {
					respiratoryObjectModel.resizePlots(respiratoryGridView.cellWidth, respiratoryGridView.cellHeight)
				}

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

			ObjectModel {
				id: tissueObjectModel
				function createPlotView (request) {
					var chartComponent = Qt.createComponent("UIPlotSeries.qml");
					if ( chartComponent.status != Component.Ready){
						if (chartComponent.status == Component.Error){
							console.log("Error : " + chartComponent.errorString() );
							return;
						}
						console.log("Error : Chart component not ready");
					} else {
						var chartObject = chartComponent.createObject(tissueGridView,{"width" : tissueGridView.cellWidth, "height" : tissueGridView.cellHeight });
						chartObject.initializeChart(request, root.tickCount);
						root.metricUpdates.connect(chartObject.updateSeries)
						tissueObjectModel.append(chartObject)
					}
				}
				function resizePlots(newWidth, newHeight){
					for (var i = 0; i < tissueObjectModel.count; ++i){
						tissueObjectModel.get(i).resizePlot(newWidth, newHeight);
					}
				}
			}

			GridView {
				id: tissueGridView
				anchors.fill: parent
				clip: true
				cellWidth: plots.width / 2
				cellHeight: plots.height / 2
				model: tissueObjectModel

				onCellWidthChanged : {
					tissueObjectModel.resizePlots(tissueGridView.cellWidth, tissueGridView.cellHeight)
				}
				onCellHeightChanged : {
					tissueObjectModel.resizePlots(tissueGridView.cellWidth, tissueGridView.cellHeight)
				}

				ScrollBar.vertical: ScrollBar {
                    parent: tissueGridView.parent
                    anchors.top: tissueGridView.top
                    anchors.right: tissueGridView.right
                    anchors.bottom: tissueGridView.bottom
                }
			}
		}
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
      system : "BloodChemistry"
	  activeRequests: [ ]
      requests:  [
          ListElement {request:"arterialBloodPH"; active: true;}
         ,ListElement {request:"arterialBloodPHBaseline"; active: false}
         ,ListElement {request:"bloodDensity"; active: false}
         ,ListElement {request:"bloodSpecificHeat"; active: false}
         ,ListElement {request:"bloodUreaNitrogenConcentration"; active: false}
         ,ListElement {request:"carbonDioxideSaturation"; active: false}
         ,ListElement {request:"carbonMonoxideSaturation"; active: false}
         ,ListElement {request:"hematocrit"; active: false}
         ,ListElement {request:"hemoglobinContent"; active: false}
         ,ListElement {request:"oxygenSaturation"; active: true}
         ,ListElement {request:"phosphate"; active: false}
         ,ListElement {request:"plasmaVolume"; active: false}
         ,ListElement {request:"pulseOximetry"; active: false}
         ,ListElement {request:"redBloodCellAcetylcholinesterase"; active: false}
         ,ListElement {request:"redBloodCellCount"; active: true}
         ,ListElement {request:"shuntFraction"; active: false}
         ,ListElement {request:"strongIonDifference"; active: false}
         ,ListElement {request:"totalBilirubin"; active: false}
         ,ListElement {request:"totalProteinConcentration"; active: false}
         ,ListElement {request:"venousBloodPH"; active: false}
         ,ListElement {request:"volumeFractionNeutralPhospholipidInPlasma"; active: false}
         ,ListElement {request:"volumeFractionNeutralLipidInPlasma"; active: false}
         ,ListElement {request:"arterialCarbonDioxidePressure"; active: false}
         ,ListElement {request:"arterialOxygenPressure"; active: false}
         ,ListElement {request:"pulmonaryArterialCarbonDioxidePressure"; active: false}
         ,ListElement {request:"pulmonaryArterialOxygenPressure"; active: false}
         ,ListElement {request:"pulmonaryVenousCarbonDioxidePressure"; active: false}
         ,ListElement {request:"pulmonaryVenousOxygenPressure"; active: false}
         ,ListElement {request:"venousCarbonDioxidePressure"; active: false}
         ,ListElement {request:"venousOxygenPressure"; active: false}
         ,ListElement {request:"inflammatoryResponse"; active: false}
         ,ListElement {request:"inflammatoryResponseLocalPathogen"; active: false}
         ,ListElement {request:"inflammatoryResponseLocalMacrophage"; active: false}
         ,ListElement {request:"inflammatoryResponseLocalNeutrophil"; active: false}
         ,ListElement {request:"inflammatoryResponseLocalBarrier"; active: false}
         ,ListElement {request:"inflammatoryResponseBloodPathogen"; active: false}
         ,ListElement {request:"inflammatoryResponseTrauma"; active: false}
         ,ListElement {request:"inflammatoryResponseMacrophageResting"; active: false}
         ,ListElement {request:"inflammatoryResponseMacrophageActive"; active: false}
         ,ListElement {request:"inflammatoryResponseNeutrophilResting"; active: false}
         ,ListElement {request:"inflammatoryResponseNeutrophilActive"; active: false}
         ,ListElement {request:"inflammatoryResponseInducibleNOSPre"; active: false}
         ,ListElement {request:"inflammatoryResponseInducibleNOS"; active: false}
         ,ListElement {request:"inflammatoryResponseConstitutiveNOS"; active: false}
         ,ListElement {request:"inflammatoryResponseNitrate"; active: false}
         ,ListElement {request:"inflammatoryResponseNitricOxide"; active: false}
         ,ListElement {request:"inflammatoryResponseTumorNecrosisFactor"; active: false}
         ,ListElement {request:"inflammatoryResponseInterleukin6"; active: false}
         ,ListElement {request:"inflammatoryResponseInterleukin10"; active: false}
         ,ListElement {request:"inflammatoryResponseInterleukin12"; active: false}
         ,ListElement {request:"inflammatoryResponseCatecholamines"; active: false}
         ,ListElement {request:"inflammatoryResponseTissueIntegrity"; active: false}
      ]
  }
  ListElement {
      system : "Cardiovascular"
	  activeRequests: []
      requests:  [
        ListElement {request:"arterialPressure"; active: false}
        ,ListElement {request:"bloodVolume"; active: false}
        ,ListElement {request:"cardiacIndex"; active: false}
        ,ListElement {request:"cardiacOutput"; active: false}
        ,ListElement {request:"centralVenousPressure"; active: false}
        ,ListElement {request:"cerebralBloodFlow"; active: false}
        ,ListElement {request:"cerebralPerfusionPressure"; active: false}
        ,ListElement {request:"diastolicArterialPressure"; active: true}
        ,ListElement {request:"heartEjectionFraction"; active: false}
        ,ListElement {request:"heartRate"; active: false}
        ,ListElement {request:"heartStrokeVolume"; active: false}
        ,ListElement {request:"intracranialPressure"; active: false}
        ,ListElement {request:"meanArterialPressure"; active: false}
        ,ListElement {request:"meanArterialCarbonDioxidePartialPressure"; active: false}
        ,ListElement {request:"meanArterialCarbonDioxidePartialPressureDelta"; active: false}
        ,ListElement {request:"meanCentralVenousPressure"; active: false}
        ,ListElement {request:"meanSkinFlow"; active: false}
        ,ListElement {request:"pulmonaryArterialPressure"; active: false}
        ,ListElement {request:"pulmonaryCapillariesWedgePressure"; active: false}
        ,ListElement {request:"pulmonaryDiastolicArterialPressure"; active: true}
        ,ListElement {request:"pulmonaryMeanArterialPressure"; active: false}
        ,ListElement {request:"pulmonaryMeanCapillaryFlow"; active: false}
        ,ListElement {request:"pulmonaryMeanShuntFlow"; active: false}
        ,ListElement {request:"pulmonarySystolicArterialPressure"; active: true}
        ,ListElement {request:"pulmonaryVascularResistance"; active: false}
        ,ListElement {request:"pulmonaryVascularResistanceIndex"; active: false}
        ,ListElement {request:"pulsePressure"; active: false}
        ,ListElement {request:"systemicVascularResistance"; active: false}
        ,ListElement {request:"systolicArterialPressure"; active: true}
      ]
  }
  ListElement {
      system : "Drugs"
	  activeRequests: []
      requests:  [
        ListElement {request:"bronchodilationLevel"; active: true}
        ,ListElement {request:"heartRateChange"; active: true}
        ,ListElement {request:"hemorrhageChange"; active: false}
        ,ListElement {request:"meanBloodPressureChange"; active: false}
        ,ListElement {request:"neuromuscularBlockLevel"; active: false}
        ,ListElement {request:"pulsePressureChange"; active: false}
        ,ListElement {request:"respirationRateChange"; active: false}
        ,ListElement {request:"sedationLevel"; active: false}
        ,ListElement {request:"tidalVolumeChange"; active: false}
        ,ListElement {request:"tubularPermeabilityChange"; active: false}
        ,ListElement {request:"centralNervousResponse"; active: false}
      ]
  }
  ListElement {
      system : "Endocrine"
	  activeRequests: []
      requests:  [
         ListElement {request:"insulinSynthesisRate"; active: true}
        ,ListElement {request:"glucagonSynthesisRate"; active: false}
      ]
  }
  ListElement {
      system : "Energy"
	  activeRequests: []
      requests:  [
        ListElement {request:"achievedExerciseLevel"; active: false}
        ,ListElement {request:"chlorideLostToSweat"; active: false}
        ,ListElement {request:"coreTemperature"; active: true}
        ,ListElement {request:"creatinineProductionRate"; active: false}
        ,ListElement {request:"exerciseMeanArterialPressureDelta"; active: false}
        ,ListElement {request:"fatigueLevel"; active: false}
        ,ListElement {request:"lactateProductionRate"; active: false}
        ,ListElement {request:"potassiumLostToSweat"; active: false}
        ,ListElement {request:"skinTemperature"; active: true}
        ,ListElement {request:"sodiumLostToSweat"; active: false}
        ,ListElement {request:"sweatRate"; active: true}
        ,ListElement {request:"totalMetabolicRate"; active: false}
        ,ListElement {request:"totalWorkRateLevel"; active: false}
      ]
  }
  ListElement {
      system: "Gastrointestinal"
	  activeRequests: []
      requests: [
        ListElement {request:"chymeAbsorptionRate"; active: false}
        ,ListElement {request:"stomachContents_calcium"; active: true}
        ,ListElement {request:"stomachContents_carbohydrates"; active: false}
        ,ListElement {request:"stomachContents_carbohydrateDigationRate"; active: false}
        ,ListElement {request:"stomachContents_fat"; active: false}
        ,ListElement {request:"stomachContents_fatDigtationRate"; active: false}
        ,ListElement {request:"stomachContents_protien"; active: false}
        ,ListElement {request:"stomachContents_protienDigtationRate"; active: false}
        ,ListElement {request:"stomachContents_sodium"; active: true}
        ,ListElement {request:"stomachContents_water"; active: true}
      ]
  }
  ListElement {
      system: "Hepatic"
	  activeRequests: []
      requests: [
        ListElement {request:"ketoneproductionRate"; active : true}
        ,ListElement {request:"hepaticGluconeogenesisRate"; active : false}
      ]
  }
  ListElement {
      system : "Nervous"
	  activeRequests: []
      requests: [
        ListElement {request: "baroreceptorHeartRateScale"; active: false}
        ,ListElement {request: "baroreceptorHeartElastanceScale"; active: false}
        ,ListElement {request: "baroreceptorResistanceScale"; active: false}
        ,ListElement {request: "baroreceptorComplianceScale"; active: false}
        ,ListElement {request: "chemoreceptorHeartRateScale"; active: false}
        ,ListElement {request: "chemoreceptorHeartElastanceScale"; active: false}
        ,ListElement {request: "painVisualAnalogueScale"; active: true}
        ,ListElement {request: "leftEyePupillaryResponse"; active: false}
        ,ListElement {request: "rightEyePupillaryResponse"; active: false}
      ]
  }
  ListElement {
      system : "Renal"
	  activeRequests: []
      requests: [
        ListElement{request:"glomerularFiltrationRate"; active: false}
        ,ListElement{request:"filtrationFraction"; active: false}
        ,ListElement{request:"leftAfferentArterioleResistance"; active: false}
        ,ListElement{request:"leftBowmansCapsulesHydrostaticPressure"; active: false}
        ,ListElement{request:"leftBowmansCapsulesOsmoticPressure"; active: false}
        ,ListElement{request:"leftEfferentArterioleResistance"; active: false}
        ,ListElement{request:"leftGlomerularCapillariesHydrostaticPressure"; active: false}
        ,ListElement{request:"leftGlomerularCapillariesOsmoticPressure"; active: false}
        ,ListElement{request:"leftGlomerularFiltrationCoefficient"; active: false}
        ,ListElement{request:"leftGlomerularFiltrationRate"; active: false}
        ,ListElement{request:"leftGlomerularFiltrationSurfaceArea"; active: false}
        ,ListElement{request:"leftGlomerularFluidPermeability"; active: false}
        ,ListElement{request:"leftFiltrationFraction"; active: false}
        ,ListElement{request:"leftNetFiltrationPressure"; active: false}
        ,ListElement{request:"leftNetReabsorptionPressure"; active: false}
        ,ListElement{request:"leftPeritubularCapillariesHydrostaticPressure"; active: false}
        ,ListElement{request:"leftPeritubularCapillariesOsmoticPressure"; active: false}
        ,ListElement{request:"leftReabsorptionFiltrationCoefficient"; active: false}
        ,ListElement{request:"leftReabsorptionRate"; active: false}
        ,ListElement{request:"leftTubularReabsorptionFiltrationSurfaceArea"; active: false}
        ,ListElement{request:"leftTubularReabsorptionFluidPermeability"; active: false}
        ,ListElement{request:"leftTubularHydrostaticPressure"; active: false}
        ,ListElement{request:"leftTubularOsmoticPressure"; active: false}
        ,ListElement{request:"renalBloodFlow"; active: true}
        ,ListElement{request:"renalPlasmaFlow"; active: false}
        ,ListElement{request:"renalVascularResistance"; active: false}
        ,ListElement{request:"rightAfferentArterioleResistance"; active: false}
        ,ListElement{request:"rightBowmansCapsulesHydrostaticPressure"; active: false}
        ,ListElement{request:"rightBowmansCapsulesOsmoticPressure"; active: false}
        ,ListElement{request:"rightEfferentArterioleResistance"; active: false}
        ,ListElement{request:"rightGlomerularCapillariesHydrostaticPressure"; active: false}
        ,ListElement{request:"rightGlomerularCapillariesOsmoticPressure"; active: false}
        ,ListElement{request:"rightGlomerularFiltrationCoefficient"; active: false}
        ,ListElement{request:"rightGlomerularFiltrationRate"; active: false}
        ,ListElement{request:"rightGlomerularFiltrationSurfaceArea"; active: false}
        ,ListElement{request:"rightGlomerularFluidPermeability"; active: false}
        ,ListElement{request:"rightFiltrationFraction"; active: false}
        ,ListElement{request:"rightNetFiltrationPressure"; active: false}
        ,ListElement{request:"rightNetReabsorptionPressure"; active: false}
        ,ListElement{request:"rightPeritubularCapillariesHydrostaticPressure"; active: false}
        ,ListElement{request:"rightPeritubularCapillariesOsmoticPressure"; active: false}
        ,ListElement{request:"rightReabsorptionFiltrationCoefficient"; active: false}
        ,ListElement{request:"rightReabsorptionRate"; active: false}
        ,ListElement{request:"rightTubularReabsorptionFiltrationSurfaceArea"; active: false}
        ,ListElement{request:"rightTubularReabsorptionFluidPermeability"; active: false}
        ,ListElement{request:"rightTubularHydrostaticPressure"; active: false}
        ,ListElement{request:"rightTubularOsmoticPressure"; active: false}
        ,ListElement{request:"urinationRate"; active: true}
        ,ListElement{request:"urineOsmolality"; active: false}
        ,ListElement{request:"urineOsmolarity"; active: false}
        ,ListElement{request:"urineProductionRate"; active: false}
        ,ListElement{request:"meanUrineOutput"; active: false}
        ,ListElement{request:"urineSpecificGravity"; active: false}
        ,ListElement{request:"urineVolume"; active: false}
        ,ListElement{request:"urineUreaNitrogenConcentration"; active: false}
      ]
  }
  ListElement{
      system : "Respiratory"
	  activeRequests: []
      requests:[
        ListElement{request:"alveolarArterialGradient"; active: false}
        ,ListElement{request:"carricoIndex"; active: false}
        ,ListElement{request:"endTidalCarbonDioxideFraction"; active: false}
        ,ListElement{request:"endTidalCarbonDioxidePressure"; active: false}
        ,ListElement{request:"expiratoryFlow"; active: true}
        ,ListElement{request:"inspiratoryExpiratoryRatio"; active: false}
        ,ListElement{request:"inspiratoryFlow"; active: true}
        ,ListElement{request:"pulmonaryCompliance"; active: false}
        ,ListElement{request:"pulmonaryResistance"; active: false}
        ,ListElement{request:"respirationDriverPressure"; active: false}
        ,ListElement{request:"respirationMusclePressure"; active: false}
        ,ListElement{request:"respirationRate"; active: false}
        ,ListElement{request:"specificVentilation"; active: false}
        ,ListElement{request:"targetPulmonaryVentilation"; active: false}
        ,ListElement{request:"tidalVolume"; active: true}
        ,ListElement{request:"totalAlveolarVentilation"; active: false}
        ,ListElement{request:"totalDeadSpaceVentilation"; active: false}
        ,ListElement{request:"totalLungVolume"; active: false}
        ,ListElement{request:"totalPulmonaryVentilation"; active: false}
        ,ListElement{request:"transpulmonaryPressure"; active: false}
      ]
  }
  ListElement{
      system:"Tissue"
	  activeRequests: []
      requests:[
         ListElement{request:"carbonDioxideProductionRate"; active: true}
        ,ListElement{request:"dehydrationFraction"; active: true}
        ,ListElement{request:"extracellularFluidVolume"; active: false}
        ,ListElement{request:"extravascularFluidVolume"; active: false}
        ,ListElement{request:"intracellularFluidPH"; active: false}
        ,ListElement{request:"intracellularFluidVolume"; active: false}
        ,ListElement{request:"totalBodyFluidVolume"; active: false}
        ,ListElement{request:"oxygenConsumptionRate"; active: false}
        ,ListElement{request:"respiratoryExchangeRatio"; active: true}
        ,ListElement{request:"liverInsulinSetPoint"; active: false}
        ,ListElement{request:"liverGlucagonSetPoint"; active: false}
        ,ListElement{request:"muscleInsulinSetPoint"; active: false}
        ,ListElement{request:"muscleGlucagonSetPoint"; active: false}
        ,ListElement{request:"fatInsulinSetPoint"; active: false}
        ,ListElement{request:"fatGlucagonSetPoint"; active: false}
        ,ListElement{request:"liverGlycogen"; active: false}
        ,ListElement{request:"muscleGlycogen"; active: false}
        ,ListElement{request:"storedProtein"; active: false}
        ,ListElement{request:"storedFat"; active: false}
      ]
  }
}
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
