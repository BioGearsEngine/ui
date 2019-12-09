import QtQuick 2.12
import QtCharts 2.3
// Endocrine

Item {
  id: root

property alias insulinSynthesisRate: insulinSynthesisRate
property alias glucagonSynthesisRate: glucagonSynthesisRate

property list<LineSeries> requests : [
  LineSeries {
    id: insulinSynthesisRate
  }
 ,LineSeries {
    id: glucagonSynthesisRate
  }
  ]
}