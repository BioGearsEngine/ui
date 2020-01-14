import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtCharts 2.3
import QtQml.Models 2.2

import "./data" as Requests

Page {
    id: root
    property alias bloodChemistry: bloodChemistrySeries
    property alias cardiovascular: cardiovascularSeries
    property alias drugs: drugs
    property alias endocrine: endocrine
    property alias energy: energy
    property alias gastrointestinal: gastrointestinal
    property alias hepatic: hepatic
    property alias nervous: nervous
    property alias renal: renal
    property alias respiratory: respiratory
    property alias tissue: tissue

    property alias physiologyRequestModel : physiologyRequestModel

    signal filterChange(string system, string request, bool active)
    

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
			/*UITabButtonForm {
				id: textButton
				text: qsTr("Test")
			}*/
            UITabButtonForm {
                id: bloodChemistryButton
                text: qsTr("BloodChemistry")
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
											physiologyRequestModel.get(plots.currentIndex).activeRequests.append({"request": model.request})
											physiologyRequestModel.get(plots.currentIndex).requests.setProperty(index, "plotVisible", checked)
										}
										else {
											physiologyRequestModel.get(plots.currentIndex).activeRequests.remove(findRequestIndex(physiologyRequestModel.get(plots.currentIndex).activeRequests,model.request), 1)
											physiologyRequestModel.get(plots.currentIndex).requests.setProperty(index, "plotVisible", checked)
										}
										root.filterChange(physiologyRequestModel.get(plots.currentIndex).system, model.request, checked)
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

			property Item requests : 
            Requests.BloodChemistry {
                id : bloodChemistryRequests
            }

			Rectangle {
				id: background
				anchors.fill: parent
				color: "steelblue"
				opacity: 0.2
			}

			GridView {
				id: gridView
				anchors.fill: parent
				clip: true
				cellWidth: plots.width / 2
				cellHeight: plots.height / 2
				model: plotDelegateModel

				ScrollBar.vertical: ScrollBar {
                    parent: gridView.parent
                    anchors.top: gridView.top
                    anchors.right: gridView.right
                    anchors.bottom: gridView.bottom
                }
			}

			DelegateModel {
				id: plotDelegateModel
				model: physiologyRequestModel.get(0).activeRequests
				delegate: UIPlotSeries {
					id: plotSeries
					width: plotSeries.GridView.view.cellWidth
					height: plotSeries.GridView.view.cellHeight
					legend.visible: false
					title: request
					LineSeries {
						id: bcLineSeries
						axisX : ValueAxis {
							property int tickCount : 0
							titleText : "Simulation Time (min)"
							min: 0
							max : 60
						}
						axisY : ValueAxis {
							titleText: request
							labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
						}
					}
				}
			}
		}
		/*UIPlotSeries {
            id: bloodChemistrySeries
            property Item requests : 
            Requests.BloodChemistry {
                id : bloodChemistryRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }*/
        UIPlotSeries {
            id: cardiovascularSeries
            property Item requests : 
            Requests.Cardiovascular {
                id : cardiovascularRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: drugs
            property Item requests :
            Requests.Drugs {
                id : drugRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: endocrine
            property Item requests :
            Requests.Endocrine {
                id : endocrineRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: energy
            property Item requests :
            Requests.Energy {
                id : energyRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: gastrointestinal
            property Item requests :
            Requests.Gastrointestinal {
                id : gastrointestinalRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: hepatic
            property Item requests :
            Requests.Hepatic {
                id : hepaticRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: nervous
            property Item requests :
            Requests.Nervous {
                id : nervousRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: renal
            property Item requests :
            Requests.Renal {
                id : renalRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: respiratory
            property Item requests :
            Requests.Respiratory {
                id : respiratoryRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: tissue
            property Item requests :
            Requests.Tissue {
                id : tissueRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
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
        ,ListElement {request:"systolicArterialPressure  "; active: true}
      ]
  }
  ListElement {
      system : "Drugs"
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
      requests:  [
         ListElement {request:"insulinSynthesisRate"; active: true}
        ,ListElement {request:"glucagonSynthesisRate"; active: false}
      ]
  }
  ListElement {
      system : "Energy"
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
      requests: [
        ListElement {request:"ketoneproductionRate"; active : true}
        ,ListElement {request:"hepaticGluconeogenesisRate"; active : false}
      ]
  }
  ListElement {
      system : "Nervous"
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
