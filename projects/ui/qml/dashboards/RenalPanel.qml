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
	property PhysiologyModel physiologyRenalFluidModel
	
	property alias renalOverviewGridView:renalOverviewGridView
	property alias renalTimer : renalTimer
		
	property string uaColor: ""
	property string uaAppearance: ""
	property bool uaGlucose: false
	property bool uaKetone: false
	property double uaBilirubin: 0.0
	property double uaSpecificG: 0.0
	property bool uaBlood: false
	property double uapH: 0.0
	property double uaUrobilinogen: 0.0
	property bool uaProtein: false
	property bool uaNitrite: false
	property bool uaLE: false
	property double urineProductionRate: 0.0
	property double glomerularFiltrationRate: 0.0
	property double renalBloodFlow: 0.0
	property double reabsorptionRate: 0.0
	
	property string goodBorderColor: "green"
	property string warningBorderColor: "yellow"
	property string criticalBorderColor: "red"
	
	
	// Based on BioGearsData for RENAL_OVERVIEW (physiologyRenalModel)
	// 0 - Mean Urine Output
	// 1 - Urine Production Rate
	
	// Based on BioGearsData for RENAL_FLUID_BALANCE (physiologyRenalFluidModel)
    // 0 - Mean Urine Output
    // 1 - Urine Production Rate
    // 2 - Urine Volume
    // 3 - Urine Osmolality
    // 4 - Urine Osmolarity
    // 5 - Glomerular Filtration Rate
    // 6 - Renal Blood Flow
    // 7 - Total Body Fluid Volume
    // 8 - Extracell Fluid Volume
    // 9 - Intracell Fluid Volume
    // 10 - Extravascular Fluid Volume
    // Check ua and reabsorption rate


	
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

		}
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
						//anchors.verticalCenter: parent.verticalCenter
						Rectangle {
							id: uaColorBox
							Layout.preferredHeight: urinalysisConsole.height * 0.1
							Layout.preferredWidth: urinalysisConsole.width * 0.35
							color : "yellow"
							Text {
								id: uaColorText
								text: "Color"
								anchors.horizontalCenter: parent.horizontalCenter
								anchors.verticalCenter: parent.verticalCenter
								color: "black"
							}
						}
						Rectangle {
							id: uaClarityBox
							Layout.preferredHeight: urinalysisConsole.height * 0.1
							Layout.preferredWidth: urinalysisConsole.width * 0.35
							color : "beige"
							Text {
								id: uaClarityText
								text: "Clarity"
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
						//anchors.verticalCenter: parent.verticalCenter
						Rectangle {
							id: uaBilirubinBox
							Layout.preferredHeight: urinalysisConsole.height * 0.1
							Layout.preferredWidth: urinalysisConsole.width * 0.425
							color : "white"
							border.color: "blue"
							border.width: 2
							Text {
								id: uaBilirubinText
								text: "Bilirubin: "
								anchors.horizontalCenter: parent.horizontalCenter
								anchors.verticalCenter: parent.verticalCenter
								color: "black"
							}
						}
						Rectangle {
							id: uaSpecificGBox
							Layout.preferredHeight: urinalysisConsole.height * 0.1
							Layout.preferredWidth: urinalysisConsole.width * 0.425
							color : "white"
							border.color: "blue"
							border.width: 2
							Text {
								id: uaSpecificGravText
								text: "Specific Gravity: "
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
							Layout.preferredHeight: urinalysisConsole.height * 0.1
							Layout.preferredWidth: urinalysisConsole.width * 0.425
							color : "white"
							border.color: "blue"
							border.width: 2
							Text {
								id: uapHText
								text: "pH: "
								anchors.horizontalCenter: parent.horizontalCenter
								anchors.verticalCenter: parent.verticalCenter
								color: "black"
							}
						}
						Rectangle {
							id: uaUrobilBox
							Layout.preferredHeight: urinalysisConsole.height * 0.1
							Layout.preferredWidth: urinalysisConsole.width * 0.425
							color : "white"
							border.color: "blue"
							border.width: 2
							Text {
								id: uaUrobilText
								text: "Urobilirubin: "
								anchors.horizontalCenter: parent.horizontalCenter
								anchors.verticalCenter: parent.verticalCenter
								color: "black"
							}
						}
					}
					
					ListModel {
						id: uaPresentModel
						ListElement {
							sub: "Glucose"
							present: "false"
						}
						ListElement {
							sub: "Ketone"
							present: "false"
						}
						ListElement {
							sub: "Blood"
							present: "false"
						}
						ListElement {
							sub: "Protein"
							present: "false"
						}
						ListElement {
							sub: "Nitrite"
							present: "false"
						}
						ListElement {
							sub: "LE"
							present: "false"
						}
					}
					TableView {
						alternatingRowColors : true
						Layout.alignment: Qt.AlignHCenter
						TableViewColumn {
							role: "sub"
							title: "Substance"
							width: urinalysisConsole.width*0.45
						}
						TableViewColumn {
							role: "present"
							title: "Present?"
							width: urinalysisConsole.width*0.45
						}
						model: uaPresentModel
					}
					
					Button {
						Layout.alignment: Qt.AlignHCenter
						text: "Update"
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
					id : renalOverviewGridView
					anchors.fill : parent
					clip : true
					cellWidth : graphConsole.width
					cellHeight : plots.height / 2.25
					model : renalOverviewModel
					ScrollBar.vertical : ScrollBar {
						parent : renalOverviewGridView.parent
						anchors.top : renalOverviewGridView.top
						anchors.right : renalOverviewGridView.right
						anchors.bottom : renalOverviewGridView.bottom
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
							font.bold: true
							text: qsTr("RBF (mL/s): ") + root.renalBloodFlow
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
							font.bold: true
							text: qsTr("UPR (mL/s): ") + root.urineProductionRate
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
							font.bold: true
							text: qsTr("GFR (mL/s): ") + root.glomerularFiltrationRate
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
							text: qsTr("Reabs. (mL/s): ") + root.reabsorptionRate
							anchors.verticalCenter: renalReabsBox.verticalCenter
							anchors.horizontalCenter: renalReabsBox.horizontalCenter
							color: "black"
						}

					}
					
			}
		}
	}
}