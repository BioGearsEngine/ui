import QtQuick 2.12
import QtCharts 2.3
//Cardiovascular

Item {
  id: root

  property alias arterialPressure : arterialPressure
  property alias bloodVolume : bloodVolume
  property alias cardiacIndex : cardiacIndex
  property alias cardiacOutput : cardiacOutput
  property alias centralVenousPressure : centralVenousPressure
  property alias cerebralBloodFlow : cerebralBloodFlow
  property alias cerebralPerfusionPressure : cerebralPerfusionPressure
  property alias diastolicArterialPressure : diastolicArterialPressure
  property alias heartEjectionFraction : heartEjectionFraction
  property alias heartRate : heartRate
  property alias heartStrokeVolume : heartStrokeVolume
  property alias intracranialPressure : intracranialPressure
  property alias meanArterialPressure : meanArterialPressure
  property alias meanArterialCarbonDioxidePartialPressure : meanArterialCarbonDioxidePartialPressure
  property alias meanArterialCarbonDioxidePartialPressureDelta : meanArterialCarbonDioxidePartialPressureDelta
  property alias meanCentralVenousPressure : meanCentralVenousPressure
  property alias meanSkinFlow : meanSkinFlow
  property alias pulmonaryArterialPressure : pulmonaryArterialPressure
  property alias pulmonaryCapillariesWedgePressure : pulmonaryCapillariesWedgePressure
  property alias pulmonaryDiastolicArterialPressure : pulmonaryDiastolicArterialPressure
  property alias pulmonaryMeanArterialPressure : pulmonaryMeanArterialPressure
  property alias pulmonaryMeanCapillaryFlow : pulmonaryMeanCapillaryFlow
  property alias pulmonaryMeanShuntFlow : pulmonaryMeanShuntFlow
  property alias pulmonarySystolicArterialPressure : pulmonarySystolicArterialPressure
  property alias pulmonaryVascularResistance : pulmonaryVascularResistance
  property alias pulmonaryVascularResistanceIndex : pulmonaryVascularResistanceIndex
  property alias pulsePressure : pulsePressure
  property alias systemicVascularResistance : systemicVascularResistance
  property alias systolicArterialPressure : systolicArterialPressure

  property list<LineSeries> requests : [
  LineSeries {
    id: arterialPressure
  }
 ,LineSeries {
    id: bloodVolume
  }
 ,LineSeries {
    id: cardiacIndex
  }
 ,LineSeries {
    id: cardiacOutput
  }
 ,LineSeries {
    id: centralVenousPressure
  }
 ,LineSeries {
    id: cerebralBloodFlow
  }
 ,LineSeries {
    id: cerebralPerfusionPressure
  }
 ,LineSeries {
    id: diastolicArterialPressure
  }
 ,LineSeries {
    id: heartEjectionFraction
  }
 ,LineSeries {
    id: heartRate
  }
 ,LineSeries {
    id: heartStrokeVolume
  }
 ,LineSeries {
    id: intracranialPressure
  }
 ,LineSeries {
    id: meanArterialPressure
  }
 ,LineSeries {
    id: meanArterialCarbonDioxidePartialPressure
  }
 ,LineSeries {
    id: meanArterialCarbonDioxidePartialPressureDelta
  }
 ,LineSeries {
    id: meanCentralVenousPressure
  }
 ,LineSeries {
    id: meanSkinFlow
  }
 ,LineSeries {
    id: pulmonaryArterialPressure
  }
 ,LineSeries {
    id: pulmonaryCapillariesWedgePressure
  }
 ,LineSeries {
    id: pulmonaryDiastolicArterialPressure
  }
 ,LineSeries {
    id: pulmonaryMeanArterialPressure
  }
 ,LineSeries {
    id: pulmonaryMeanCapillaryFlow
  }
 ,LineSeries {
    id: pulmonaryMeanShuntFlow
  }
 ,LineSeries {
    id: pulmonarySystolicArterialPressure
  }
 ,LineSeries {
    id: pulmonaryVascularResistance
  }
 ,LineSeries {
    id: pulmonaryVascularResistanceIndex
  }
 ,LineSeries {
    id: pulsePressure
  }
 ,LineSeries {
    id: systemicVascularResistance
  }
 ,LineSeries {
    id: systolicArterialPressure
  }
  ]
}
