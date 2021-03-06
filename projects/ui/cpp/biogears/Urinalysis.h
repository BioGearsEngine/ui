#pragma once

#include <QObject>
#include <biogears/cdm/patient/assessments/SEUrinalysis.h>

struct Urinalysis : public QObject {

  Urinalysis(QObject* parent = nullptr)
    : QObject(parent){};

  QString Color(); 
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


  void Color(int value);
  void Appearance(int value);
  void Bilirubin(double value);
  void SpecificGravity(double value);
  void pH(double value);
  void Urobilinogen(double value);
  void Glucose(bool value);
  void Ketone(bool value);
  void Protein(bool value);
  void Blood(bool value);
  void Nitrite(bool value);
  void LeukocyteEsterase(bool value);

private:
  Q_OBJECT
  QString _color;
  QString _appearance;
  QString _bilirubin;
  QString _specificGravity;
  QString _pH;
  QString _urobilinogem;
  QString _glucose;
  QString _ketone;
  QString _protein;
  QString _blood;
  QString _nitrite;
  QString _leukocyteEsterase;


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