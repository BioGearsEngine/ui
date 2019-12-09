#pragma once

#include <QObject>

struct PatientMetrics {
  QString respiratory_rate_bpm ;
  QString heart_rate_bpm ;
  QString core_temperature_c ;
  QString oxygen_saturation_pct ;
  QString systolic_blood_pressure_mmHg ;
  QString diastolic_blood_pressure_mmHg ;

  


  bool operator==(const PatientMetrics& rhs) const
  { return
    respiratory_rate_bpm == rhs.respiratory_rate_bpm
    && heart_rate_bpm == rhs.heart_rate_bpm
    && core_temperature_c == rhs.core_temperature_c
    && oxygen_saturation_pct == rhs.oxygen_saturation_pct
    && systolic_blood_pressure_mmHg == rhs.systolic_blood_pressure_mmHg
    && diastolic_blood_pressure_mmHg == rhs.diastolic_blood_pressure_mmHg
    ;
  }
  bool operator!=(const PatientMetrics& rhs) const { return !(*this == rhs); }

private:
  Q_GADGET
  Q_PROPERTY(QString RespritoryRate MEMBER respiratory_rate_bpm)
  Q_PROPERTY(QString HeartRate MEMBER heart_rate_bpm)
  Q_PROPERTY(QString CoreTemp MEMBER core_temperature_c)
  Q_PROPERTY(QString OxygenSaturation MEMBER oxygen_saturation_pct)
  Q_PROPERTY(QString SystolicBloodPressure MEMBER systolic_blood_pressure_mmHg)
  Q_PROPERTY(QString DiastolicBloodPressure MEMBER diastolic_blood_pressure_mmHg)
  
};

Q_DECLARE_METATYPE(PatientMetrics)
