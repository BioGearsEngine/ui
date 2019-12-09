import QtQuick 2.12
import QtCharts 2.3
// Hepatic

Item {
  id: root

property alias ketoneproductionRate: ketoneproductionRate
property alias hepaticGluconeogenesisRate: hepaticGluconeogenesisRate

property list<LineSeries> requests : [
  LineSeries {
    id: ketoneproductionRate
  }
 ,LineSeries {
    id: hepaticGluconeogenesisRate
  }
  ]
}