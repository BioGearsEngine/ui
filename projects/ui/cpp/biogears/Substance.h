#pragma once

#include <QObject>
#include <memory>

struct Substance : QObject {
  //Default constructor -- Sentinal value of -1 set at initialization.  If the property is active for a substance, it will get reset to a new value.
  //  We can therefore search for prop != -1 to assign relevant properties to a substance so that we do not graph info that is not relevant
  Substance(QObject* parent = nullptr)
    : QObject(parent)
    , name("")
    , area_under_curve(-1.0)
    , blood_concentration(-1.0)
    , effect_site_concentration(-1.0)
    , mass_in_body(-1.0)
    , mass_in_blood(-1.0)
    , mass_in_tissue(-1.0)
    , plasma_concentration(-1.0)
    , systemic_mass_cleared(-1.0)
    , alveolar_transfer(-1.0)
    , end_tidal_fraction(-1.0)
    , renal_mass_cleared(-1.0)
    , hepatic_mass_cleared(-1.0)
  {
  }
  //Copy constructor -- required if we're going to be searching a map for a substance and assigning it to another Substance variable
  Substance(const Substance& rhs)
  {
    name = rhs.name;
    area_under_curve = rhs.area_under_curve;
    blood_concentration = rhs.blood_concentration;
    effect_site_concentration = rhs.effect_site_concentration;
    mass_in_body = rhs.mass_in_body;
    mass_in_blood = rhs.mass_in_blood;
    mass_in_tissue = rhs.mass_in_tissue;
    plasma_concentration = rhs.plasma_concentration;
    systemic_mass_cleared = rhs.systemic_mass_cleared;
    alveolar_transfer = rhs.alveolar_transfer;
    end_tidal_fraction = rhs.end_tidal_fraction;
    renal_mass_cleared = rhs.renal_mass_cleared;
    hepatic_mass_cleared = rhs.hepatic_mass_cleared;
  }

  //Members
  QString name;
  double area_under_curve;
  double blood_concentration;
  double effect_site_concentration;
  double mass_in_body;
  double mass_in_blood;
  double mass_in_tissue;
  double plasma_concentration;
  double systemic_mass_cleared;
  double alveolar_transfer;
  double end_tidal_fraction;
  double renal_mass_cleared;
  double hepatic_mass_cleared;

  //Equality operators for sorting / searching for subtances in map.
  bool operator==(const Substance& rhs) const { return name == rhs.name; }
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
  Q_PROPERTY(double AlveolarTransfer MEMBER alveolar_transfer)
  Q_PROPERTY(double EndTidalFraction MEMBER end_tidal_fraction)
  Q_PROPERTY(double RenalMassCleared MEMBER renal_mass_cleared)
  Q_PROPERTY(double HepaticMassCleared MEMBER hepatic_mass_cleared)
};
Q_DECLARE_METATYPE(Substance)
