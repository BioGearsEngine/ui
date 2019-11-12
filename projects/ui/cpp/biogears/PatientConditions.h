#pragma once

#include <QObject>

struct PatientConditions {
  bool diabieties = false;

  bool operator==(const PatientConditions& rhs) const { return diabieties == rhs.diabieties; }
  bool operator!=(const PatientConditions& rhs) const { return !(*this == rhs); }

private:
  Q_GADGET
  Q_PROPERTY(bool diabieties MEMBER diabieties)
};
Q_DECLARE_METATYPE(PatientConditions)
