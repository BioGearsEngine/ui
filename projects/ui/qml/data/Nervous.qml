import QtQuick 2.12
import QtCharts 2.3
// Nervous

Item {
  id: root

property alias baroreceptorHeartRateScale: baroreceptorHeartRateScale
property alias baroreceptorHeartElastanceScale: baroreceptorHeartElastanceScale
property alias baroreceptorResistanceScale: baroreceptorResistanceScale
property alias baroreceptorComplianceScale: baroreceptorComplianceScale
property alias chemoreceptorHeartRateScale: chemoreceptorHeartRateScale
property alias chemoreceptorHeartElastanceScale: chemoreceptorHeartElastanceScale
property alias painVisualAnalogueScale: painVisualAnalogueScale
property alias leftEyePupillaryResponse: leftEyePupillaryResponse
property alias rightEyePupillaryResponse: rightEyePupillaryResponse

property list<LineSeries> requests : [
  LineSeries {
    id: baroreceptorHeartRateScale
  }
 ,LineSeries {
    id: baroreceptorHeartElastanceScale
  }
 ,LineSeries {
    id: baroreceptorResistanceScale
  }
 ,LineSeries {
    id: baroreceptorComplianceScale
  }
 ,LineSeries {
    id: chemoreceptorHeartRateScale
  }
 ,LineSeries {
    id: chemoreceptorHeartElastanceScale
  }
 ,LineSeries {
    id: painVisualAnalogueScale
  }
 ,LineSeries {
    id: leftEyePupillaryResponse
  }
 ,LineSeries {
    id: rightEyePupillaryResponse
  }
  ]
}