import QtQuick 2.12
import QtCharts 2.3
//Cardiovascular

Item {
  id: root
  property ValueAxis axisX : ValueAxis {
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  arterialPressure : LineSeries {
    name : "arterialPressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "arterialPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
    }
  }
  property LineSeries  bloodVolume : LineSeries {
    name : "bloodVolume"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "bloodVolume"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  cardiacIndex : LineSeries {
    name : "cardiacIndex"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "cardiacIndex"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  cardiacOutput : LineSeries {
    name : "cardiacOutput"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "cardiacOutput"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  centralVenousPressure : LineSeries {
    name : "centralVenousPressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "centralVenousPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  cerebralBloodFlow : LineSeries {
    name : "cerebralBloodFlow"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "cerebralBloodFlow"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  cerebralPerfusionPressure : LineSeries {
    name : "cerebralPerfusionPressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "cerebralPerfusionPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  diastolicArterialPressure : LineSeries {
    name : "diastolicArterialPressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "diastolicArterialPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  heartEjectionFraction : LineSeries {
    name : "heartEjectionFraction"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "heartEjectionFraction"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  heartRate : LineSeries {
    name : "heartRate"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "heartRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  heartStrokeVolume : LineSeries {
    name : "heartStrokeVolume"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "heartStrokeVolume"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  intracranialPressure : LineSeries {
    name : "intracranialPressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "intracranialPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  meanArterialPressure : LineSeries {
    name : "meanArterialPressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "meanArterialPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  meanArterialCarbonDioxidePartialPressure : LineSeries {
    name : "meanArterialCarbonDioxidePartialPressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "meanArterialCarbonDioxidePartialPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  meanArterialCarbonDioxidePartialPressureDelta : LineSeries {
    name : "meanArterialCarbonDioxidePartialPressureDelta"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "meanArterialCarbonDioxidePartialPressureDelta"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  meanCentralVenousPressure : LineSeries {
    name : "meanCentralVenousPressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "meanCentralVenousPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  meanSkinFlow : LineSeries {
    name : "meanSkinFlow"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "meanSkinFlow"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  pulmonaryArterialPressure : LineSeries {
    name : "pulmonaryArterialPressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "pulmonaryArterialPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  pulmonaryCapillariesWedgePressure : LineSeries {
    name : "pulmonaryCapillariesWedgePressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "pulmonaryCapillariesWedgePressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  pulmonaryDiastolicArterialPressure : LineSeries {
    name : "pulmonaryDiastolicArterialPressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "pulmonaryDiastolicArterialPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  pulmonaryMeanArterialPressure : LineSeries {
    name : "pulmonaryMeanArterialPressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "pulmonaryMeanArterialPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  pulmonaryMeanCapillaryFlow : LineSeries {
    name : "pulmonaryMeanCapillaryFlow"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "pulmonaryMeanCapillaryFlow"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  pulmonaryMeanShuntFlow : LineSeries {
    name : "pulmonaryMeanShuntFlow"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "pulmonaryMeanShuntFlow"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  pulmonarySystolicArterialPressure : LineSeries {
    name : "pulmonarySystolicArterialPressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "pulmonarySystolicArterialPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  pulmonaryVascularResistance : LineSeries {
    name : "pulmonaryVascularResistance"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "pulmonaryVascularResistance"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  pulmonaryVascularResistanceIndex : LineSeries {
    name : "pulmonaryVascularResistanceIndex"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "pulmonaryVascularResistanceIndex"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  pulsePressure : LineSeries {
    name : "pulsePressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "pulsePressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  systemicVascularResistance : LineSeries {
    name : "systemicVascularResistance"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "systemicVascularResistance"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
  property LineSeries  systolicArterialPressure : LineSeries {
    name : "systolicArterialPressure"
    axisY: ValueAxis {
            min : 0.
            max: 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "systolicArterialPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

    }
  }
}
