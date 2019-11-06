import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Controls.Material 2.12
import QtCharts 2.3

ChartView {
	id: bgChart
	property double period
	property double amplitude
	property double x_s : 0
	property bool timerOn
	
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


	Timer {
		id: plotTimer
		interval: 100; running: timerOn; repeat: true
		onTriggered: genPoint()
	}


	function genPoint() {
		x_s = x_s + plotTimer.interval / 1000;
		var b = 2 * Math.PI / period;
		var y = amplitude * Math.sin(b * x_s);
		lSeries.append(x_s, y);
		return y;
	}

}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
