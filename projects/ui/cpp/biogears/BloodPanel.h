#pragma once

#include <QObject>

struct PatientAssessments {
  bool urinalysis = false;

  bool operator==(const PatientAssessments& ua) const { return urinalysis == ua.urinalysis; }
  bool operator!=(const PatientAssessments& ua) const { return !(*this == ua); }

private:
  Q_GADGET
  Q_PROPERTY(bool urinalysis MEMBER urinalysis)
};
Q_DECLARE_METATYPE(PatientAssessments)
