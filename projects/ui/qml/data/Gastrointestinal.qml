import QtQuick 2.12
import QtCharts 2.3
// Gastrointestinal

Item {
  id: root

property alias chymeAbsorptionRate: chymeAbsorptionRate
property alias stomachContents: stomachContents

property list<LineSeries> requests : [
  LineSeries {
    id: chymeAbsorptionRate
  }
 ,LineSeries {
    id: stomachContents
  }
  ]
}