import QtQuick 2.12
import QtCharts 2.3
//Cardiovascular

Item {
  id: root
  property ValueAxis axisX : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  arterialPressure : LineSeries {
    id: arterialPressure
    name : "arterialPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  bloodVolume : LineSeries {
    id: bloodVolume
    name : "bloodVolume"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  cardiacIndex : LineSeries {
    id: cardiacIndex
    name : "cardiacIndex"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  cardiacOutput : LineSeries {
    id: cardiacOutput
    name : "cardiacOutput"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  centralVenousPressure : LineSeries {
    id: centralVenousPressure
    name : "centralVenousPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  cerebralBloodFlow : LineSeries {
    id: cerebralBloodFlow
    name : "cerebralBloodFlow"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  cerebralPerfusionPressure : LineSeries {
    id: cerebralPerfusionPressure
    name : "cerebralPerfusionPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  diastolicArterialPressure : LineSeries {
    id: diastolicArterialPressure
    name : "diastolicArterialPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  heartEjectionFraction : LineSeries {
    id: heartEjectionFraction
    name : "heartEjectionFraction"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  heartRate : LineSeries {
    id: heartRate
    name : "heartRate"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  heartStrokeVolume : LineSeries {
    id: heartStrokeVolume
    name : "heartStrokeVolume"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  intracranialPressure : LineSeries {
    id: intracranialPressure
    name : "intracranialPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  meanArterialPressure : LineSeries {
    id: meanArterialPressure
    name : "meanArterialPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  meanArterialCarbonDioxidePartialPressure : LineSeries {
    id: meanArterialCarbonDioxidePartialPressure
    name : "meanArterialCarbonDioxidePartialPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  meanArterialCarbonDioxidePartialPressureDelta : LineSeries {
    id: meanArterialCarbonDioxidePartialPressureDelta
    name : "meanArterialCarbonDioxidePartialPressureDelta"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  meanCentralVenousPressure : LineSeries {
    id: meanCentralVenousPressure
    name : "meanCentralVenousPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  meanSkinFlow : LineSeries {
    id: meanSkinFlow
    name : "meanSkinFlow"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  pulmonaryArterialPressure : LineSeries {
    id: pulmonaryArterialPressure
    name : "pulmonaryArterialPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  pulmonaryCapillariesWedgePressure : LineSeries {
    id: pulmonaryCapillariesWedgePressure
    name : "pulmonaryCapillariesWedgePressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  pulmonaryDiastolicArterialPressure : LineSeries {
    id: pulmonaryDiastolicArterialPressure
    name : "pulmonaryDiastolicArterialPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  pulmonaryMeanArterialPressure : LineSeries {
    id: pulmonaryMeanArterialPressure
    name : "pulmonaryMeanArterialPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  pulmonaryMeanCapillaryFlow : LineSeries {
    id: pulmonaryMeanCapillaryFlow
    name : "pulmonaryMeanCapillaryFlow"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  pulmonaryMeanShuntFlow : LineSeries {
    id: pulmonaryMeanShuntFlow
    name : "pulmonaryMeanShuntFlow"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  pulmonarySystolicArterialPressure : LineSeries {
    id: pulmonarySystolicArterialPressure
    name : "pulmonarySystolicArterialPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  pulmonaryVascularResistance : LineSeries {
    id: pulmonaryVascularResistance
    name : "pulmonaryVascularResistance"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  pulmonaryVascularResistanceIndex : LineSeries {
    id: pulmonaryVascularResistanceIndex
    name : "pulmonaryVascularResistanceIndex"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  pulsePressure : LineSeries {
    id: pulsePressure
    name : "pulsePressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  systemicVascularResistance : LineSeries {
    id: systemicVascularResistance
    name : "systemicVascularResistance"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  systolicArterialPressure : LineSeries {
    id: systolicArterialPressure
    name : "systolicArterialPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
}
