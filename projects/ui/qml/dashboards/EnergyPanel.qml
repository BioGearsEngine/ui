import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtCharts 2.3
import QtQml.Models 2.2

import com.biogearsengine.ui.scenario 1.0

Item {
	id: root
	
	property PhysiologyModel physiologyEnergyModel
	property PhysiologyModel physiologyVitalsModel
	
	property alias energyMetabolismGridView:energyMetabolismGridView
	property alias energyTimer : energyTimer
		
	property double fatigue: 0.0
	property double coreTemp: 0.0
	property double skinTemp: 0.0
	property double metabolicLoad: 0.0
	property double envTemp: 0.0
	property double envHumidity: 0.0
	property double currentVO2: 0.0
	property double heartRate: 0.0
	property double dehydrationFraction: 0.0
	
	property string goodBorderColor: "#27ae60"
	property string warningBorderColor: "#f1c40f"
	property string criticalBorderColor: "#c0392b"
	
	
	// Based on BioGearsData
	// 0 - Core Temperature
	// 1 - Sweat Rate
	// 2 - Skin Temperature
	// 3 - Total Metabolic Rate
	// 4 - Stomach Contents
	// 5 - Oxygen Consumption Rate
	// 6 - CO2 Production Rate
	// 7 - Dehydration Fraction
	// 8 - Ambient Temperature
	// 9 - Humidity
	
	Timer {
        id : energyTimer
        interval : 200 // Mimic the 5 Hz plot timer
        running : false
        repeat : true
        triggeredOnStart : true
		// start, stop, and pause are handled in GraphForm after passing out energyTimer
		onTriggered : {
			let coreTempIndex = physiologyEnergyModel.index(0, 0) //first number refers to request name within energy (0 is core temp) second should be 0 to get reserved slot name
			root.coreTemp = physiologyEnergyModel.data(coreTempIndex, PhysiologyModel.ValueRole).toFixed(2)
			let skinTempIndex = physiologyEnergyModel.index(2, 0) 
			root.skinTemp = physiologyEnergyModel.data(skinTempIndex, PhysiologyModel.ValueRole).toFixed(2)
			let metabolicIndex = physiologyEnergyModel.index(3, 0) 
			root.metabolicLoad = physiologyEnergyModel.data(metabolicIndex, PhysiologyModel.ValueRole).toFixed(2)
			let o2ConsumptionIndex = physiologyEnergyModel.index(5, 0) 
			root.currentVO2 = physiologyEnergyModel.data(o2ConsumptionIndex, PhysiologyModel.ValueRole).toFixed(2)
			let dehydrationIndex = physiologyEnergyModel.index(7, 0) 
			root.dehydrationFraction = physiologyEnergyModel.data(dehydrationIndex, PhysiologyModel.ValueRole).toFixed(2)
			let ambTempIndex = physiologyEnergyModel.index(8, 0) 
			root.envTemp = physiologyEnergyModel.data(ambTempIndex, PhysiologyModel.ValueRole).toFixed(2)
			let relHumidityIndex = physiologyEnergyModel.index(9, 0) 
			root.envHumidity = physiologyEnergyModel.data(relHumidityIndex, PhysiologyModel.ValueRole).toFixed(2)
			
			let heartRateIndex = physiologyVitalsModel.index(5,0)
			root.heartRate = physiologyVitalsModel.data(heartRateIndex, PhysiologyModel.ValueRole).toFixed(2)
		}
    }
	Rectangle {
		id : energyMetabolismBackground
		anchors.fill : parent
		color : "transparent"
		
		Image {
			id: biogears_background
			source : "qrc:/icons/biogears_noBackground.png"
			width : energyMetabolismBackground.width
			height: energyMetabolismBackground.height 
			anchors.centerIn : parent
			fillMode: Image.PreserveAspectFit
			Rectangle {
				id : colorBackground
				anchors.fill : biogears_background
				color : "#ecf0f1"
				opacity : 0.95
			}
		}
		
		GridLayout {
			id: energyPanelGrid
			// Percentage of size and centerIn parent provides margin buffer around grid
			height: root.height*0.9
			width : root.width*0.95
			anchors.centerIn : parent
			columns: 10
			rows: 5
			
			Layout.leftMargin: energyPanelGrid.width/50
			Layout.rightMargin: energyPanelGrid.width/50
			Layout.topMargin: energyPanelGrid.height/25
			Layout.bottomMargin: energyPanelGrid.height/25
			
			property double colMulti : energyPanelGrid.width / energyPanelGrid.columns
			property double rowMulti : energyPanelGrid.height / energyPanelGrid.rows
			function prefWidth(item){
				return colMulti * item.Layout.columnSpan
			}
			function prefHeight(item){
				return rowMulti * item.Layout.rowSpan
			}
			//columnSpacing: energyMetabolismBackground.width/20
			//rowSpacing: energyMetabolismBackground.height/20
			
			Gauge {
				id: fatigueGauge
				Layout.column: 0
				Layout.columnSpan: 1
				Layout.row: 0
				Layout.rowSpan: 5
				Layout.preferredHeight: energyPanelGrid.prefHeight(this)
				Layout.preferredWidth: energyPanelGrid.prefWidth(this)
				
				minimumValue: 0
				tickmarkStepSize : 0.1
				minorTickmarkCount : 4
				value: fatigue
				maximumValue: 1
				//formatValue: function(value)
				tickmarkAlignment  : Qt.AlignLeft
				Text {
					id: indexText
					text: "Fatigue"
					font.bold: true
					anchors.horizontalCenter: fatigueGauge.horizontalCenter
					anchors.top: fatigueGauge.bottom
					color: "#34495e"
				}
				style: GaugeStyle {
					valueBar: Rectangle {
						implicitWidth: energyPanelGrid.width / 20
						color: Qt.rgba(fatigueGauge.value / fatigueGauge.maximumValue, 1 - fatigueGauge.value / fatigueGauge.maximumValue, 0, 1)
					}
					
					//foreground: null
					
					tickmarkLabel: Text {
						text: styleData.value
						color: "#34495e"
						antialiasing: true
					}

					tickmark: Item {
						implicitWidth: 8
						implicitHeight: 4

						Rectangle {
							x: control.tickmarkAlignment === Qt.AlignLeft
								|| control.tickmarkAlignment === Qt.AlignTop ? parent.implicitWidth : -28
							width: 28
							height: parent.height
							color: "#34495e"
						}
					}

					minorTickmark: Item {
						implicitWidth: 8
						implicitHeight: 2

						Rectangle {
							x: control.tickmarkAlignment === Qt.AlignLeft
								|| control.tickmarkAlignment === Qt.AlignTop ? parent.implicitWidth : -28
							width: 14
							height: parent.height
							color: "#34495e"
						}
					}
				}
			}
			Rectangle {
				id : coreTempBox
				Layout.column: 1
				Layout.row: 0
				Layout.columnSpan: 6
				Layout.rowSpan: 1
				Layout.preferredHeight: energyPanelGrid.prefHeight(this)
				Layout.preferredWidth: energyPanelGrid.prefWidth(this)
				
				color : "transparent"
			
				Gauge {
					id: coreTempGauge
					minimumValue: -30
					tickmarkStepSize : 5
					minorTickmarkCount : 4
					orientation: Qt.Horizontal
					value: root.coreTemp
					maximumValue: 50
					tickmarkAlignment  : Qt.AlignBottom
					
					width: parent.width
					height: parent.height
					anchors.topMargin : coreTempBox.height / 10
					anchors.top : coreTempText.bottom
					anchors.horizontalCenter : coreTempBox.horizontalCenter

					
					style: GaugeStyle {
						valueBar: Rectangle {
						implicitWidth: energyPanelGrid.height / 10
						color: (root.coreTemp >= 38) ? root.criticalBorderColor : goodBorderColor
						}
						
						tickmarkLabel: Text {
							text: styleData.value
							color: "#34495e"
							antialiasing: true
						}
						
						tickmark: Item {
							implicitWidth: 8
							implicitHeight: 4

							Rectangle {
								x: control.tickmarkAlignment === Qt.AlignLeft
									|| control.tickmarkAlignment === Qt.AlignTop ? parent.implicitWidth : -28
								width: 28
								height: parent.height
								color: "#34495e"
							}
						}

						minorTickmark: Item {
							implicitWidth: 8
							implicitHeight: 2

							Rectangle {
								x: control.tickmarkAlignment === Qt.AlignLeft
									|| control.tickmarkAlignment === Qt.AlignTop ? parent.implicitWidth : -14
								width: 14
								height: parent.height
								color: "#34495e"
							}
						}
					}
				}
				Text {
					id: coreTempText
					text: "Core Temperature (Celsius):  "
					font.bold: true
					anchors.top: coreTempBox.top
					anchors.left: coreTempBox.left
					color: "#34495e"
				}
				Text {
					id: coreTempDispValue
					text: root.coreTemp
					anchors.bottom: coreTempText.bottom
					anchors.left: coreTempText.right
					color: "#34495e"
				}
			}
			Rectangle {
				id : skinTempBox
				Layout.column: 1
				Layout.row: 1
				Layout.columnSpan: 6
				Layout.rowSpan: 1
				Layout.preferredHeight: energyPanelGrid.prefHeight(this)
				Layout.preferredWidth: energyPanelGrid.prefWidth(this)
				
				color : "transparent"
				
				Gauge {
					id: skinTempGauge
					minimumValue: -30
					tickmarkStepSize : 5
					minorTickmarkCount : 4
					orientation: Qt.Horizontal
					value: root.skinTemp
					maximumValue: 50
					tickmarkAlignment  : Qt.AlignTop
					
					width: parent.width
					height: parent.height
					anchors.verticalCenter : skinTempBox.verticalCenter
					anchors.horizontalCenter : skinTempBox.horizontalCenter

					style: GaugeStyle {
						valueBar: Rectangle {
						implicitWidth: energyPanelGrid.height / 10
						color: (root.skinTemp >= 35) ? root.criticalBorderColor : goodBorderColor
						}
						
						tickmarkLabel: Text {
							text: styleData.value
							color: "#34495e"
							antialiasing: true
						}

						tickmark: Item {
							implicitWidth: 8
							implicitHeight: 4

							Rectangle {
								x: control.tickmarkAlignment === Qt.AlignLeft
									|| control.tickmarkAlignment === Qt.AlignTop ? parent.implicitWidth : -28
								width: 28
								height: parent.height
								color: "#34495e"
							}
						}

						minorTickmark: Item {
							implicitWidth: 8
							implicitHeight: 2

							Rectangle {
								x: control.tickmarkAlignment === Qt.AlignLeft
									|| control.tickmarkAlignment === Qt.AlignTop ? parent.implicitWidth : -14
								width: 14
								height: parent.height
								color: "#34495e"
							}
						}
					}
				}
				Text {
					id: skinTempText
					text: "Skin Temperature (Celsius):  "
					font.bold : true
					anchors.bottomMargin: skinTempBox.height * 0.1
					anchors.bottom: skinTempBox.bottom
					anchors.left: skinTempBox.left
					color: "#34495e"
				}
				Text {
					id: skinTempDispValue
					text: root.skinTemp
					anchors.bottom: skinTempText.bottom
					anchors.left: skinTempText.right
					color: "#34495e"
				}
			}
			Rectangle {
				id : rightConsole
				Layout.column: 7
				Layout.row: 0
				Layout.columnSpan: 3
				Layout.rowSpan: 3
				Layout.preferredHeight: energyPanelGrid.prefHeight(this)
				Layout.preferredWidth: energyPanelGrid.prefWidth(this) 
				color : Qt.rgba(1, 1, 1, 0.0)
				ColumnLayout {
					spacing: rightConsole.height/20
					anchors.centerIn : parent
					Text {
						id: exerciseProfile
						font.pointSize: 12
						text: "Exercise Profile"
						font.bold: true
						Layout.alignment: Qt.AlignHCenter
						color: "#34495e"
					}
					Rectangle {
						id: patientMetabolism
						Layout.alignment: Qt.AlignHCenter
						Layout.preferredWidth: rightConsole.width*0.9
						Layout.preferredHeight: rightConsole.height*0.15
						color : "white"
						border.color: root.goodBorderColor
						border.width: 5
						Text {
							id: textMetabolism
							text: "Metabolic Load: " 
							anchors.verticalCenter: patientMetabolism.verticalCenter
							anchors.horizontalCenter: patientMetabolism.horizontalCenter
							color: "#34495e"
						}
						Text {
							id: valueMetabolism
							text: metabolicLoad
							anchors.left: textMetabolism.right
							anchors.verticalCenter: patientMetabolism.verticalCenter
							color: "#34495e"
						}
					}
				
					Rectangle {
						id: patientHydration
						property string hydBord: "green"
						//height: rightConsole.height / 5
						Layout.alignment: Qt.AlignHCenter
						Layout.preferredWidth: rightConsole.width*0.9
						Layout.preferredHeight: rightConsole.height*0.15
						color : "white"
						function hydrationBorderColor() {
							var hydrationBorder = root.goodBorderColor
							if (root.dehydrationFraction >= 0.2) {
								hydrationBorder = root.criticalBorderColor
							} else if (root.dehydrationFraction >= 0.1) {
								hydrationBorder = root.warningBorderColor
							}
							return hydrationBorder
						}
						border.color: hydrationBorderColor()
						border.width: 5
						Text {
							id: textHydration
							function zoneHydrationText() {
								var hydrationZone = "Hydration: Sufficient"
								if (root.dehydrationFraction >= 0.2) {
									hydrationZone = "Hydration: Dehydrated"
								} else if (root.dehydrationFraction >= 0.1) {
									hydrationZone = "Hydration: Slightly Dehydrated"
								}
								return hydrationZone
							}
							text: zoneHydrationText()
							anchors.verticalCenter: patientHydration.verticalCenter
							anchors.horizontalCenter: patientHydration.horizontalCenter
							color: "#34495e"
						}
					}
					
					Rectangle {
						id: patientHR
						//height: rightConsole.height / 5
						Layout.alignment: Qt.AlignHCenter
						Layout.preferredWidth: rightConsole.width*0.9
						Layout.preferredHeight: rightConsole.height*0.15
						color : "white"
						function zoneHRBorderColor() {
							var heartRateBorder = root.goodBorderColor
							if (root.heartRate >= 144) {
								heartRateBorder = rood.criticalBorderColor
							} else if (root.heartRate >= 90) {
								heartRateBorder = root.warningBorderColor
							}
							return heartRateBorder
						}
						border.color: zoneHRBorderColor()
						border.width: 5
						Text {
							id: textHR
							function zoneHRText() {
								var heartRateZone = "Heart Rate Zone: Rest"
								if (root.heartRate >= 144) {
									heartRateZone = "Heart Rate Zone: Anaerobic"
								} else if (root.heartRate >= 126) {
									heartRateZone = "Heart Rate Zone: Aerobic"
								} else if (root.heartRate >= 108) {
									heartRateZone = "Heart Rate Zone: Weight Control"
								} else if (root.heartRate >= 90) {
									heartRateZone = "Heart Rate Zone: Fat Burning"
								}
								return heartRateZone
							}
							text: zoneHRText()
							anchors.verticalCenter: patientHR.verticalCenter
							anchors.horizontalCenter: patientHR.horizontalCenter
							color: "#34495e"
						}
					}
					
					Rectangle {
						id: patientVO2
						//height: rightConsole.height / 5
						Layout.alignment: Qt.AlignHCenter
						Layout.preferredWidth: rightConsole.width*0.9
						Layout.preferredHeight: rightConsole.height*0.15
						color : "white"
						border.color: root.goodBorderColor
						border.width: 5
						Text {
							id: textVO2
							text: "VO2: "
							anchors.verticalCenter: patientVO2.verticalCenter
							anchors.horizontalCenter: patientVO2.horizontalCenter
							color: "#34495e"
						}
						Text {
							id: valueVO2
							text: currentVO2
							anchors.left: textVO2.right
							anchors.verticalCenter: patientVO2.verticalCenter
							color: "#34495e"
						}
					}
				}
			}
			
			Rectangle {
				id : envConsole
				Layout.column: 7
				Layout.row: 3
				Layout.columnSpan: 3
				Layout.rowSpan: 2
				Layout.preferredHeight: energyPanelGrid.prefHeight(this)
				Layout.preferredWidth: energyPanelGrid.prefWidth(this)
				color : "transparent"
				border.color : root.goodBorderColor
				border.width : 3
				//opacity: 0.75
				
				ColumnLayout {
				
				spacing: envConsole.height/10
				anchors.horizontalCenter : parent.horizontalCenter
				Text {
					id: envText
					text: "Environment"
					opacity : 1.0
					font.pointSize: 12
					font.bold: true
					Layout.alignment: Qt.AlignHCenter
					Layout.topMargin : envConsole.height / 50
					color: "#34495e"
				}
				
				RowLayout {
					spacing: envConsole.width/50
					//Layout.alignment: Qt.AlignHCenter
					CircularGauge {
						id: tempGauge
						Layout.preferredHeight: envConsole.height * 0.65
						Layout.preferredWidth: envConsole.width * 0.65
						minimumValue: -20
						value: envTemp
						maximumValue: 50
						style: CircularGaugeStyle {
							needle: Rectangle {
								y: outerRadius * 0.15
								implicitWidth: outerRadius * 0.03
								implicitHeight: outerRadius * 0.9
								antialiasing: true
								color: "#34495e"
							}
							tickmark: Rectangle {
								//visible: styleData.value < 80 || styleData.value % 10 == 0
								implicitWidth: outerRadius * 0.02
								antialiasing: true
								implicitHeight: outerRadius * 0.06
								color: "#34495e"
							}
							minorTickmark: Rectangle {
								//visible: styleData.value < 80
								implicitWidth: outerRadius * 0.01
								antialiasing: true
								implicitHeight: outerRadius * 0.03
								color: "#34495e"
							}
							tickmarkLabel: Text {
								text: styleData.value
								color: "#34495e"
								antialiasing: true
							}
						}
						Text {
							id: envTempText
							text: "Temperature (degC)"
							anchors.horizontalCenter: parent.horizontalCenter
							anchors.top: tempGauge.bottom
							color: "#34495e"
						}
					}
					Text {
						id: envHumidityText
						text: "Humidity:"
						font.pointSize: 10
						color: "#34495e"
						Text {
							id: envHumidityValue
							text: envHumidity
							font.pixelSize: 20
							anchors.horizontalCenter: envHumidityText.horizontalCenter
							anchors.top: envHumidityText.bottom
							color: "#34495e"
						}
					}
					
				
				}
				
				}
			}
			Rectangle {
				id : graphConsole
				Layout.column: 1
				Layout.row: 2
				Layout.columnSpan: 6
				Layout.rowSpan: 3
				Layout.preferredHeight: energyPanelGrid.prefHeight(this)
				Layout.preferredWidth: energyPanelGrid.prefWidth(this)
				color : Qt.rgba(1, 1, 1, 0.0)
				GridView {
					id : energyMetabolismGridView
					anchors.fill : parent
					clip : true
					width : graphConsole.width
					cellWidth : graphConsole.width
					cellHeight : plots.height / 2
					model : energyMetabolismModel
					ScrollBar.vertical : ScrollBar {
						parent : energyMetabolismGridView.parent
						anchors.top : energyMetabolismGridView.top
						anchors.right : energyMetabolismGridView.right
						anchors.bottom : energyMetabolismGridView.bottom
					}
				}
			}
		}
	}
}