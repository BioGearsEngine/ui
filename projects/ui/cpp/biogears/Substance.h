#pragma once

#include <QObject>


struct Substance : QObject {
  Substance(QObject* parent = nullptr)
    : QObject(parent)
  {
  }
  
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

    bool
    operator==(const Substance& rhs) const
  {
    return area_under_curve == rhs.area_under_curve
      && blood_concentration == rhs.blood_concentration
      && effect_site_concentration == rhs.effect_site_concentration
      && mass_in_body == rhs.mass_in_body
      && mass_in_tissue == rhs.mass_in_tissue
      && plasma_concentration == rhs.plasma_concentration
      && systemic_mass_cleared == rhs.systemic_mass_cleared
      && tissue_concentration == rhs.tissue_concentration
      && alveolar_transfer == rhs.alveolar_transfer
      && end_tidal_fraction == rhs.end_tidal_fraction
      && renal_mass_cleared == rhs.renal_mass_cleared
      && hepatic_mass_cleared == rhs.hepatic_mass_cleared
      ;
  }
  bool operator!=(const Substance& rhs) const { return !(*this == rhs); }

private:
  Q_GADGET
  Q_PROPERTY(QString AreaUnderCurve MEMBER area_under_curve)
  Q_PROPERTY(QString BloodConcentration MEMBER blood_concentration)
  Q_PROPERTY(QString EffectSiteConcentration MEMBER effect_site_concentration)
  Q_PROPERTY(QString MassInBody MEMBER mass_in_body)
  Q_PROPERTY(QString MassInTissue MEMBER mass_in_tissue)
  Q_PROPERTY(QString PlasmaConcentration MEMBER plasma_concentration)
  Q_PROPERTY(QString SystemicMassCleared MEMBER systemic_mass_cleared)
  Q_PROPERTY(QString TissueConcentration MEMBER tissue_concentration)
  Q_PROPERTY(QString AlveolarTransfer MEMBER alveolar_transfer)
  Q_PROPERTY(QString EndTidalFraction MEMBER end_tidal_fraction)
  Q_PROPERTY(QString RenalMassCleared MEMBER renal_mass_cleared)
  Q_PROPERTY(QString HepaticMassCleared MEMBER hepatic_mass_cleared)
};
Q_DECLARE_METATYPE(Substance)
