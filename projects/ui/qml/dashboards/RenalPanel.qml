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
				color : Qt.rgba(1, 0, 0, 0.5)
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
				color : Qt.rgba(0, 0, 1, 0.5)
			}
		}
	}
}