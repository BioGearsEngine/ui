#pragma once

#include <QObject>
#include <biogears/cdm/patient/assessments/SEUrinalysis.h>

struct Urinalysis {
  QString Color(); // These are needed in UA.cpp...use if statements for enums
  QString Appearance();
  QString Bilirubin();
  QString SpecificGravity();
  QString pH();
  QString Urobilinogen();
  QString Glucose();
  QString Ketone();
  QString Protein();
  QString Blood();
  QString Nitrite();
  QString LeukocyteEsterase();

  bool operator==(const Urinalysis& ua) const { return true; }
  bool operator!=(const Urinalysis& ua) const { return !(*this == ua); }
signals:
  //void colorChanged(QString);
  //void appearanceChanged(QString);
  //void bilirubinChanged(QString);
  //void specificGravityChanged(QString);
  //void pHChanged(QString);
  //void urobilinogenChanged(QString);
  //void glucoseChanged(QString);
  //void ketoneChanged(QString);
  //void proteinChanged(QString);
  //void bloodChanged(QString);
  //void nitriteChanged(QString);
  //void leukocyteEsteraseChanged(QString);

private:
  Q_GADGET
  Q_PROPERTY(QString Color READ Color) //NOTIFY colorChanged)
  Q_PROPERTY(QString Appearance READ Appearance) // NOTIFY appearanceChanged)
  Q_PROPERTY(QString Bilirubin READ Bilirubin)
  Q_PROPERTY(QString SpecificGravity READ SpecificGravity)
  Q_PROPERTY(QString pH READ pH)
  Q_PROPERTY(QString Urobilinogen READ Urobilinogen)
  Q_PROPERTY(QString Glucose READ Glucose)
  Q_PROPERTY(QString Ketone READ Ketone)
  Q_PROPERTY(QString Protein READ Protein)
  Q_PROPERTY(QString Blood READ Blood)
  Q_PROPERTY(QString Nitrite READ Nitrite)
  Q_PROPERTY(QString LeukocyteEsterase READ LeukocyteEsterase)

};
Q_DECLARE_METATYPE(Urinalysis)
