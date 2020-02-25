#pragma once

#include <QObject>

namespace bio {

struct Substance : QObject {
  Substance(QObject* parent = nullptr)
    : QObject(parent)
  {
  }
  QString name;
  double area_under_curve;
  double blood_concentration;
  double effect_site_concentration;
  double mass_in_body;
  double mass_in_blood;
  double mass_in_tissue;
  double plasma_concentration;
  double systemic_mass_cleared;
  double tissue_concentration;
  double alveolar_transfer;
  double end_tidal_fraction;
  double renal_mass_cleared;
  double hepatic_mass_cleared;

  bool operator==(const Substance& rhs) const { return name == rhs.name;}
  bool operator!=(const Substance& rhs) const { return !(*this == rhs); }
  bool operator<(const Substance& rhs) const { return name < rhs.name; }
  bool operator>(const Substance& rhs) const { return name > rhs.name; }

private:
  Q_OBJECT
  Q_PROPERTY(QString Name MEMBER name);
  Q_PROPERTY(double AreaUnderCurve MEMBER area_under_curve)
  Q_PROPERTY(double BloodConcentration MEMBER blood_concentration)
  Q_PROPERTY(double EffectSiteConcentration MEMBER effect_site_concentration)
  Q_PROPERTY(double MassInBody MEMBER mass_in_body)
  Q_PROPERTY(double MassInTissue MEMBER mass_in_tissue)
  Q_PROPERTY(double PlasmaConcentration MEMBER plasma_concentration)
  Q_PROPERTY(double SystemicMassCleared MEMBER systemic_mass_cleared)
  Q_PROPERTY(double TissueConcentration MEMBER tissue_concentration)
  Q_PROPERTY(double AlveolarTransfer MEMBER alveolar_transfer)
  Q_PROPERTY(double EndTidalFraction MEMBER end_tidal_fraction)
  Q_PROPERTY(double RenalMassCleared MEMBER renal_mass_cleared)
  Q_PROPERTY(double HepaticMassCleared MEMBER hepatic_mass_cleared)
};

class SubstanceData : QObject {
  Q_OBJECT
public:
  SubstanceData(QObject* parent = nullptr)
  {
  }
  Q_INVOKABLE QVariantMap getSubstanceData()
  {
    QVariantMap subData;
    foreach (QString key, _substanceMap.keys()) {
      subData[key] = QVariant::fromValue<QObject*>(_substanceMap[key]);
    }
    return subData;
  }

  void insertSubstance(QString key, Substance* sub) 
  {
    _substanceMap.insert(key, sub);
  }

  QMap<QString, Substance*> getSubstanceMap()
  {
    return _substanceMap;
  }

private:
  QMap<QString, Substance*> _substanceMap;
};

}