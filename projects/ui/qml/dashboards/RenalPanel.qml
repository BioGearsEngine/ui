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
	
	
	// Based on BioGearsData
	// 0 - Mean Urine Output
	// 1 - Urine Production Rate

	
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

		GridView {
			id : renalOverviewGridView
			anchors.fill : parent
			clip : true
			cellWidth : plots.width / 2
			cellHeight : plots.height / 2
			model : renalOverviewModel
			ScrollBar.vertical : ScrollBar {
				parent : renalOverviewGridView.parent
				anchors.top : renalOverviewGridView.top
				anchors.right : renalOverviewGridView.right
				anchors.bottom : renalOverviewGridView.bottom
			}
		}
		
		//GridLayout {	
		//}
	}
}