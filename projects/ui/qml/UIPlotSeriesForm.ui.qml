import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Controls.Material 2.12
import QtCharts 2.3

ChartView {
	id: root
	property double period
	property double amplitude
	property double x_s : 0
	property bool timerOn

	property alias lSeries : lSeries
	property alias y_axis : y_axis
	property alias x_axis : x_axis

	LineSeries {
		id: lSeries
		ValueAxis {
			id: x_axis
			min : 0
			max : 30
		}
		ValueAxis {
			id: y_axis
			min: -10
			max : 10
		}
		axisX : x_axis
		axisY : y_axis

	}

}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
