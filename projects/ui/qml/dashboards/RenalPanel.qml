import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Material 2.12
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtCharts 2.3
import QtQml.Models 2.2

import com.biogearsengine.ui.scenario 1.0

Item {
	id: root
	
	property PhysiologyModel physiologyRenalModel
	property Urinalysis urinalysisData
	
	signal urinalysisRequest()
	
	property alias renalGridView: renalGridView
	property alias renalTimer : renalTimer
		
	property string uaColor: "Yellow"
	property string uaAppearance: "Cloudy"
	property string uaGlucose: "Negative"
	property string uaKetone: "Negative"
	property double uaBilirubin: 0.0
	property double uaSpecificG: 0.0
	property string uaBlood: "Negative"
	property double uapH: 0.0
	property double uaUrobilinogen: 0.0
	property string uaProtein: "Negative"
	property string uaNitrite: "Negative"
	property string uaLE: "Negative"
	property double urineProductionRate: 0.0
	property double glomerularFiltrationRate: 0.0
	property double renalBloodFlow: 0.0
	property double leftReabsorptionRate: 0.0
	property double rightReabsorptionRate: 0.0
	property double meanReabsorptionRate: 0.0
	
	property double colTableUA : 0.0
	property double rowTableUA : 0.0
	property string headerTable: "deepskyblue"
	property string lightTable: "white"
	property string darkTable: "lightblue"
	property string borderTable: "black"

	
	
	// Based on BioGearsData for RENAL (physiologyRenalModel)
	// 0 - Mean Urine Output
	// 1 - Urine Production Rate
	// 2 - Glomerular Filtration Rate
	// 3 - Urine volume
  // 4 - Urine osmolarity
  // 5 - Urine osmolality
  // 6 - Renal blood flow
  // 7 - Left reabsorption rate
  // 9 - Right reabsorption rate
	
	Timer {
    id : renalTimer
    interval : 200 // Mimic the 5 Hz plot timer
    running : false
    repeat : true
    triggeredOnStart : true
		// start, stop, and pause are handled in GraphForm after passing out renalTimer
		onTriggered : {
			let urineProdIndex = physiologyRenalModel.index(1, 0) //first number refers to request name within energy (0 is core temp) second should be 0 to get reserved slot name
			root.urineProductionRate = physiologyRenalModel.data(urineProdIndex, PhysiologyModel.ValueRole).toFixed(2)
			let glomFiltRateIndex = physiologyRenalModel.index(2, 0) //first number refers to request name within energy (0 is core temp) second should be 0 to get reserved slot name
			root.glomerularFiltrationRate = physiologyRenalModel.data(glomFiltRateIndex, PhysiologyModel.ValueRole).toFixed(2)
			let renalBloodFlowIndex = physiologyRenalModel.index(6, 0) //first number refers to request name within energy (0 is core temp) second should be 0 to get reserved slot name
			root.renalBloodFlow = physiologyRenalModel.data(renalBloodFlowIndex, PhysiologyModel.ValueRole).toFixed(2)
			let lReabsIndex = physiologyRenalModel.index(7, 0) //first number refers to request name within energy (0 is core temp) second should be 0 to get reserved slot name
			root.leftReabsorptionRate = physiologyRenalModel.data(lReabsIndex, PhysiologyModel.ValueRole).toFixed(2)
			let rReabsIndex = physiologyRenalModel.index(8, 0) //first number refers to request name within energy (0 is core temp) second should be 0 to get reserved slot name
			root.rightReabsorptionRate = physiologyRenalModel.data(rReabsIndex, PhysiologyModel.ValueRole).toFixed(2)
			root.meanReabsorptionRate = (root.leftReabsorptionRate + root.rightReabsorptionRate) / 2;

		}
    }
	
	onUrinalysisDataChanged: {
		root.uaColor = urinalysisData.Color
		root.uaAppearance = urinalysisData.Appearance
		root.uaBilirubin = urinalysisData.Bilirubin
		root.uaSpecificG = urinalysisData.SpecificGravity
		root.uapH = urinalysisData.pH
		root.uaUrobilinogen = urinalysisData.Urobilinogen
		root.uaGlucose = urinalysisData.Glucose
		root.uaKetone = urinalysisData.Ketone
		root.uaProtein = urinalysisData.Protein
		root.uaBlood = urinalysisData.Blood
		root.uaNitrite = urinalysisData.Nitrite
		root.uaLE = urinalysisData.LeukocyteEsterase
	}
	
	Rectangle {
		id : renalBackground
		anchors.fill : parent
		color : Qt.rgba(0, 0.15, 0, 0.7)

		
		
		GridLayout {	
			id: renalPanelGrid
			// Percentage of size and centerIn parent provides margin buffer around grid
			height: root.height*0.9
			width : root.width*0.95
			anchors.centerIn : parent
			
			columns: 20
			rows: 4

			property double colMulti : renalPanelGrid.width / renalPanelGrid.columns
			property double rowMulti : renalPanelGrid.height / renalPanelGrid.rows
			function prefWidth(item){
				return colMulti * item.Layout.columnSpan
			}
			function prefHeight(item){
				return rowMulti * item.Layout.rowSpan
			}
			
			Rectangle {
				id : urinalysisConsole
				Layout.column: 0
				Layout.row: 0
				Layout.columnSpan: 5
				Layout.rowSpan: 4
				Layout.preferredHeight: renalPanelGrid.prefHeight(this)
				Layout.preferredWidth: renalPanelGrid.prefWidth(this) 
				color : Qt.rgba(0.75, 0.75, 0.75, 1)
				
				ColumnLayout {
					id: columnLayout
					spacing: urinalysisConsole.height/50
					anchors.horizontalCenter : parent.horizontalCenter
					anchors.verticalCenter : parent.verticalCenter
					Text {
						id: uaText
						text: "Urinalysis"
						font.pointSize: 13
						Layout.alignment: Qt.AlignHCenter
						color: "black"
					}
					
					RowLayout {
						id: colorItems
						spacing: urinalysisConsole.width/10
						Layout.alignment: Qt.AlignHCenter
						Rectangle {
							id: uaColorBox
							Layout.preferredHeight: urinalysisConsole.height * 0.05
							Layout.preferredWidth: urinalysisConsole.width * 0.35
							function uaColorFunct() { // Options: PaleYellow, Yellow, DarkYellow, Pink
								var uaColorVisual = "white"
								if (root.uaColor == "PaleYellow") {
									uaColorVisual = "lightyellow"
								} else if (root.uaColor == "Yellow") {
									uaColorVisual = "yellow"
								} else if (root.uaColor == "DarkYellow") {
									uaColorVisual = "goldenrod"
								} else if (root.uaColor == "Pink") {
									uaColorVisual = "pink"
								}
								return uaColorVisual
							}
							color : uaColorFunct()
							Text {
								id: uaColorText
								text: root.uaColor
								anchors.horizontalCenter: parent.horizontalCenter
								anchors.verticalCenter: parent.verticalCenter
								color: "black"
							}
						}
						Rectangle {
							id: uaClarityBox
							Layout.preferredHeight: urinalysisConsole.height * 0.05
							Layout.preferredWidth: urinalysisConsole.width * 0.35
							function uaClarityColorFunct() { // Options: Clear, SlightlyCloudy, Cloudy, Turbid
								var uaClarityColor = "white"
								if (root.uaAppearance == "Clear") {
									uaClarityColor = "white"
								} else if (root.uaAppearance == "SlightlyCloudy") {
									uaClarityColor = "ivory"
								} else if (root.uaAppearance == "Cloudy") {
									uaClarityColor = "beige"
								} else if (root.uaAppearance == "Turbid") {
									uaClarityColor = "chocolate"
								}
								return uaClarityColor
							}
							color : uaClarityColorFunct()
							Text {
								id: uaClarityText
								text: root.uaAppearance
								anchors.horizontalCenter: parent.horizontalCenter
								anchors.verticalCenter: parent.verticalCenter
								color: "black"
							}
						}
					}
					RowLayout {
						id: valueItems1
						spacing: urinalysisConsole.width/20
						Layout.alignment: Qt.AlignHCenter
						Rectangle {
							id: uaBilirubinBox
							Layout.preferredHeight: urinalysisConsole.height * 0.05
							Layout.preferredWidth: urinalysisConsole.width * 0.425
							color : "white"
							border.color: "blue"
							border.width: 2
							Text {
								id: uaBilirubinText
								text: qsTr("Bilirubin: ")+ root.uaBilirubin
								anchors.horizontalCenter: parent.horizontalCenter
								anchors.verticalCenter: parent.verticalCenter
								color: "black"
							}
						}
						Rectangle {
							id: uaSpecificGBox
							Layout.preferredHeight: urinalysisConsole.height * 0.05
							Layout.preferredWidth: urinalysisConsole.width * 0.425
							color : "white"
							border.color: "blue"
							border.width: 2
							Text {
								id: uaSpecificGravText
								text: qsTr("S.G.: ")+ root.uaSpecificG
								anchors.horizontalCenter: parent.horizontalCenter
								anchors.verticalCenter: parent.verticalCenter
								color: "black"
							}
						}
					}
					RowLayout {
						id: valueItems2
						spacing: urinalysisConsole.width/20
						Layout.alignment: Qt.AlignHCenter
						//anchors.verticalCenter: parent.verticalCenter
						Rectangle {
							id: uapHBox
							Layout.preferredHeight: urinalysisConsole.height * 0.05
							Layout.preferredWidth: urinalysisConsole.width * 0.425
							color : "white"
							border.color: "blue"
							border.width: 2
							Text {
								id: uapHText
								text: qsTr("pH: ")+ root.uapH
								anchors.horizontalCenter: parent.horizontalCenter
								anchors.verticalCenter: parent.verticalCenter
								color: "black"
							}
						}
						Rectangle {
							id: uaUrobilBox
							Layout.preferredHeight: urinalysisConsole.height * 0.05
							Layout.preferredWidth: urinalysisConsole.width * 0.425
							color : "white"
							border.color: "blue"
							border.width: 2
							Text {
								id: uaUrobilText
								text: qsTr("Urobilirubin: ")+ root.uaUrobilinogen
								anchors.horizontalCenter: parent.horizontalCenter
								anchors.verticalCenter: parent.verticalCenter
								color: "black"
							}
						}
					}
					
					Rectangle {
						id: uaTableSpace
						Layout.preferredHeight: urinalysisConsole.height*0.45
						Layout.preferredWidth : urinalysisConsole.width*0.8
						Layout.alignment: Qt.AlignHCenter
						//anchors.fill : parent
						color : root.borderTable
						
						GridLayout {
							id: uaTablePresence
							// Percentage of size and centerIn parent provides margin buffer around grid
							anchors.fill: parent
							columnSpacing: 0
							rowSpacing: 0
							
							columns: 2
							rows: 7
							
							Rectangle {
								id: subTableHeader
								Layout.column: 0
								Layout.row: 0
								Layout.columnSpan: 1
								Layout.rowSpan: 1
								Layout.preferredHeight: uaTableSpace.height / uaTablePresence.rows
								Layout.preferredWidth: uaTableSpace.width / uaTablePresence.columns
								color : root.headerTable
								border.color: root.borderTable
								border.width: 2
								Text {
									id: subHeaderText
									text: "Substance"
									font.bold: true
									anchors.horizontalCenter: subTableHeader.horizontalCenter
									anchors.verticalCenter: subTableHeader.verticalCenter
									color: "black"
								}
							}
							Rectangle {
								id: presTableHeader
								Layout.column: 1
								Layout.row: 0
								Layout.columnSpan: 1
								Layout.rowSpan: 1
								Layout.preferredHeight: uaTableSpace.height / uaTablePresence.rows
								Layout.preferredWidth: uaTableSpace.width / uaTablePresence.columns
								color : root.headerTable
								border.color: root.borderTable
								border.width: 2
								Text {
									id: presHeaderText
									text: "Present?"
									font.bold: true
									anchors.horizontalCenter: presTableHeader.horizontalCenter
									anchors.verticalCenter: presTableHeader.verticalCenter
									color: "black"
								}
							}
							
							Rectangle {
								id: glucoseTableSub
								Layout.column: 0
								Layout.row: 1
								Layout.columnSpan: 1
								Layout.rowSpan: 1
								Layout.preferredHeight: uaTableSpace.height / uaTablePresence.rows
								Layout.preferredWidth: uaTableSpace.width / uaTablePresence.columns
								color : root.lightTable
								border.color: root.borderTable
								border.width: 2
								Text {
									id: subGlucoseText
									text: "Glucose"
									anchors.horizontalCenter: glucoseTableSub.horizontalCenter
									anchors.verticalCenter: glucoseTableSub.verticalCenter
									color: "black"
								}
							}
							Rectangle {
								id: glucTablePres
								Layout.column: 1
								Layout.row: 1
								Layout.columnSpan: 1
								Layout.rowSpan: 1
								Layout.preferredHeight: uaTableSpace.height / uaTablePresence.rows
								Layout.preferredWidth: uaTableSpace.width / uaTablePresence.columns
								color : root.lightTable
								border.color: root.borderTable
								border.width: 2
								Text {
									id: presGlucoseText
									text: root.uaGlucose
									anchors.horizontalCenter: glucTablePres.horizontalCenter
									anchors.verticalCenter: glucTablePres.verticalCenter
									color: "black"
								}
							}
							Rectangle {
								id: ketoneTableSub
								Layout.column: 0
								Layout.row: 2
								Layout.columnSpan: 1
								Layout.rowSpan: 1
								Layout.preferredHeight: uaTableSpace.height / uaTablePresence.rows
								Layout.preferredWidth: uaTableSpace.width / uaTablePresence.columns
								color : root.darkTable
								border.color: root.borderTable
								border.width: 2
								Text {
									id: subKetoneText
									text: "Ketone"
									anchors.horizontalCenter: ketoneTableSub.horizontalCenter
									anchors.verticalCenter: ketoneTableSub.verticalCenter
									color: "black"
								}
							}
							Rectangle {
								id: ketTablePres
								Layout.column: 1
								Layout.row: 2
								Layout.columnSpan: 1
								Layout.rowSpan: 1
								Layout.preferredHeight: uaTableSpace.height / uaTablePresence.rows
								Layout.preferredWidth: uaTableSpace.width / uaTablePresence.columns
								color : root.darkTable
								border.color: root.borderTable
								border.width: 2
								Text {
									id: presKetoneText
									text: root.uaKetone
									anchors.horizontalCenter: ketTablePres.horizontalCenter
									anchors.verticalCenter: ketTablePres.verticalCenter
									color: "black"
								}
							}
							Rectangle {
								id: bloodTableSub
								Layout.column: 0
								Layout.row: 3
								Layout.columnSpan: 1
								Layout.rowSpan: 1
								Layout.preferredHeight: uaTableSpace.height / uaTablePresence.rows
								Layout.preferredWidth: uaTableSpace.width / uaTablePresence.columns
								color : root.lightTable
								border.color: root.borderTable
								border.width: 2
								Text {
									id: subBloodText
									text: "Blood"
									anchors.horizontalCenter: bloodTableSub.horizontalCenter
									anchors.verticalCenter: bloodTableSub.verticalCenter
									color: "black"
								}
							}
							Rectangle {
								id: bloodTablePres
								Layout.column: 1
								Layout.row: 3
								Layout.columnSpan: 1
								Layout.rowSpan: 1
								Layout.preferredHeight: uaTableSpace.height / uaTablePresence.rows
								Layout.preferredWidth: uaTableSpace.width / uaTablePresence.columns
								color : root.lightTable
								border.color: root.borderTable
								border.width: 2
								Text {
									id: presBloodText
									text: root.uaBlood
									anchors.horizontalCenter: bloodTablePres.horizontalCenter
									anchors.verticalCenter: bloodTablePres.verticalCenter
									color: "black"
								}
							}
							Rectangle {
								id: proteinTableSub
								Layout.column: 0
								Layout.row: 4
								Layout.columnSpan: 1
								Layout.rowSpan: 1
								Layout.preferredHeight: uaTableSpace.height / uaTablePresence.rows
								Layout.preferredWidth: uaTableSpace.width / uaTablePresence.columns
								color : root.darkTable
								border.color: root.borderTable
								border.width: 2
								Text {
									id: subProteinText
									text: "Protein"
									anchors.horizontalCenter: proteinTableSub.horizontalCenter
									anchors.verticalCenter: proteinTableSub.verticalCenter
									color: "black"
								}
							}
							Rectangle {
								id: proteinTablePres
								Layout.column: 1
								Layout.row: 4
								Layout.columnSpan: 1
								Layout.rowSpan: 1
								Layout.preferredHeight: uaTableSpace.height / uaTablePresence.rows
								Layout.preferredWidth: uaTableSpace.width / uaTablePresence.columns
								color : root.darkTable
								border.color: root.borderTable
								border.width: 2
								Text {
									id: presProteinText
									text: root.uaProtein
									anchors.horizontalCenter: proteinTablePres.horizontalCenter
									anchors.verticalCenter: proteinTablePres.verticalCenter
									color: "black"
								}
							}
							Rectangle {
								id: nitriteTableSub
								Layout.column: 0
								Layout.row: 5
								Layout.columnSpan: 1
								Layout.rowSpan: 1
								Layout.preferredHeight: uaTableSpace.height / uaTablePresence.rows
								Layout.preferredWidth: uaTableSpace.width / uaTablePresence.columns
								color : root.lightTable
								border.color: root.borderTable
								border.width: 2
								Text {
									id: subNitriteText
									text: "Nitrite"
									anchors.horizontalCenter: nitriteTableSub.horizontalCenter
									anchors.verticalCenter: nitriteTableSub.verticalCenter
									color: "black"
								}
							}
							Rectangle {
								id: nitriteTablePres
								Layout.column: 1
								Layout.row: 5
								Layout.columnSpan: 1
								Layout.rowSpan: 1
								Layout.preferredHeight: uaTableSpace.height / uaTablePresence.rows
								Layout.preferredWidth: uaTableSpace.width / uaTablePresence.columns
								color : root.lightTable
								border.color: root.borderTable
								border.width: 2
								Text {
									id: presNitriteText
									text: root.uaNitrite
									anchors.horizontalCenter: nitriteTablePres.horizontalCenter
									anchors.verticalCenter: nitriteTablePres.verticalCenter
									color: "black"
								}
							}
							Rectangle {
								id: leTableSub
								Layout.column: 0
								Layout.row: 6
								Layout.columnSpan: 1
								Layout.rowSpan: 1
								Layout.preferredHeight: uaTableSpace.height / uaTablePresence.rows
								Layout.preferredWidth: uaTableSpace.width / uaTablePresence.columns
								color : root.darkTable
								border.color: root.borderTable
								border.width: 2
								Text {
									id: subLEText
									text: "LE"
									anchors.horizontalCenter: leTableSub.horizontalCenter
									anchors.verticalCenter: leTableSub.verticalCenter
									color: "black"
								}
							}
							Rectangle {
								id: leTablePres
								Layout.column: 1
								Layout.row: 6
								Layout.columnSpan: 1
								Layout.rowSpan: 1
								Layout.preferredHeight: uaTableSpace.height / uaTablePresence.rows
								Layout.preferredWidth: uaTableSpace.width / uaTablePresence.columns
								color : root.darkTable
								border.color: root.borderTable
								border.width: 2
								Text {
									id: presLEText
									text: root.uaLE
									anchors.horizontalCenter: leTablePres.horizontalCenter
									anchors.verticalCenter: leTablePres.verticalCenter
									color: "black"
								}
							}
						}
					}
					Button {
						Layout.alignment: Qt.AlignHCenter
						text: "Update"
						onClicked : {
							urinalysisRequest();
						}
					}
					
				}
			}
			Rectangle {
				id : graphConsole
				Layout.column: 5
				Layout.row: 0
				Layout.columnSpan: 10
				Layout.rowSpan: 4
				Layout.preferredHeight: renalPanelGrid.prefHeight(this)
				Layout.preferredWidth: renalPanelGrid.prefWidth(this)
				color : Qt.rgba(1, 1, 1, 0.0)
				GridView {
					id : renalGridView
					anchors.fill : parent
					clip : true
					cellWidth : graphConsole.width
					cellHeight : plots.height / 2.25
					model : renalModel
					ScrollBar.vertical : ScrollBar {
						parent : renalGridView.parent
						anchors.top : renalGridView.top
						anchors.right : renalGridView.right
						anchors.bottom : renalGridView.bottom
					}
				}
			}
			
			Rectangle {
				id : nephronConsole
				Layout.column: 15
				Layout.row: 0
				Layout.columnSpan: 5
				Layout.rowSpan: 4
				Layout.preferredHeight: renalPanelGrid.prefHeight(this)
				Layout.preferredWidth: renalPanelGrid.prefWidth(this) 
				color : Qt.rgba(1, 1, 1, 0)
				
					Image {
						id: nephron_image
						source : "qrc:/icons/renalPanelNephron.png"
						width : nephronConsole.width
						height: nephronConsole.height
						fillMode: Image.Stretch
					}
					Rectangle {
						id: renalFlowBox
						width: nephronConsole.width*0.5
						height: nephronConsole.height*0.05
						anchors.left: nephronConsole.left 
						anchors.topMargin: nephronConsole.height*0.25
						anchors.top: nephronConsole.top
						color :  "white"
						border.color: "blue"
						border.width: 2
						Text {
							id: textRenalFlow
              width : parent.width
							font.bold: true
							text: qsTr("RBF (L/min): ") + root.renalBloodFlow
							anchors.verticalCenter: renalFlowBox.verticalCenter
							anchors.horizontalCenter: renalFlowBox.horizontalCenter
							color: "black"
						}
					}
					Rectangle {
						id: renalUrineProdBox
						width: nephronConsole.width*0.5
						height: nephronConsole.height*0.05
						anchors.right: nephronConsole.right
						anchors.bottomMargin: nephronConsole.height*0.15
						anchors.bottom: nephronConsole.bottom
						color : "white"
						border.color: "blue"
						border.width: 2
						Text {
							id: textUrineProd
              width : parent.width
							font.bold: true
							text: qsTr("UPR (mL/min): ") + root.urineProductionRate
							anchors.verticalCenter: renalUrineProdBox.verticalCenter
							anchors.horizontalCenter: renalUrineProdBox.horizontalCenter
							color: "black"
						}
					}
					Rectangle {
						id: renalGlomFiltBox
						width: nephronConsole.width*0.5
						height: nephronConsole.height*0.05
						anchors.right: nephronConsole.right
						anchors.topMargin: nephronConsole.height*0.15
						anchors.top: nephronConsole.top
						color :  "white"
						border.color: "blue"
						border.width: 2
						Text {
							id: textGlomFilt
              width : parent.width
							font.bold: true
							text: qsTr("GFR (mL/min): ") + root.glomerularFiltrationRate
							anchors.verticalCenter: renalGlomFiltBox.verticalCenter
							anchors.horizontalCenter: renalGlomFiltBox.horizontalCenter
							color: "black"
						}
					}
					Rectangle {
						id: renalReabsBox
						width: nephronConsole.width*0.5
						height: nephronConsole.height*0.05
						anchors.right: nephronConsole.right
						anchors.verticalCenter: nephronConsole.verticalCenter
						color :  "white"
						border.color: "blue"
						border.width: 2
						Text {
							id: textReabs
							font.bold: true
              width : parent.width
							text: qsTr("Reabs. (mL/min): ") + root.meanReabsorptionRate
							anchors.verticalCenter: renalReabsBox.verticalCenter
							anchors.horizontalCenter: renalReabsBox.horizontalCenter
							color: "black"
						}

					}
					
			}
		}
	}
}