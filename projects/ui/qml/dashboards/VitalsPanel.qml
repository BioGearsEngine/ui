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
	
	property alias vitalsGridView: vitalsGridView
	//property alias vitalsTimer : vitalsTimer
	
	Image {
		id: biogears_background
		source : "qrc:/icons/biogears_noBackground.png"
		width : plots.width
		height: plots.height 
		anchors.centerIn : parent
		fillMode: Image.PreserveAspectFit
		Rectangle {
			id : colorBackground
			anchors.fill : biogears_background
			color : "#ecf0f1"
			opacity : 0.95
		}
	}
	  GridView {
		id : vitalsGridView
		anchors.fill : parent
		 anchors.bottomMargin : 20
		clip : true
		cellWidth : parent.width / 2
		cellHeight : parent.height / 2
		model : vitalsModel
		ScrollBar.vertical : ScrollBar {
		  parent : vitalsGridView.parent
		  anchors.top : vitalsGridView.top
		  anchors.right : vitalsGridView.right
		  anchors.bottom : vitalsGridView.bottom
		 
		}
	  }
}