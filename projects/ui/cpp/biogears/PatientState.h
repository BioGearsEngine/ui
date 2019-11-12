#pragma once

#include <QObject>

struct PatientState {
  QString alive = false;
  QString tacycardia = false;

  QString age;
  QString height_cm;
  QString gender;
  QString weight_kg;
  QString body_surface_area_m_sq;
  QString body_mass_index_kg_per_m_sq;
  QString body_fat_pct;
  QString exercise_state;

    bool
    operator==(const PatientState& rhs) const
  {
    return alive == rhs.alive
      && tacycardia == rhs.tacycardia
      && age == rhs.age
      && height_cm == rhs.height_cm
      && gender == rhs.gender
      && weight_kg == rhs.weight_kg
      && body_surface_area_m_sq == rhs.body_surface_area_m_sq
      && body_mass_index_kg_per_m_sq == rhs.body_mass_index_kg_per_m_sq
      && body_fat_pct == rhs.body_fat_pct
      && exercise_state == rhs.exercise_state
      ;
  }
  bool operator!=(const PatientState& rhs) const { return !(*this == rhs); }

private:
  Q_GADGET
  Q_PROPERTY(QString Alive MEMBER alive)


  Q_PROPERTY(QString Age MEMBER age)
  Q_PROPERTY(QString Height MEMBER height_cm)
  Q_PROPERTY(QString Gender MEMBER gender)
  Q_PROPERTY(QString Weight MEMBER weight_kg)
  Q_PROPERTY(QString BodySurfaceArea MEMBER body_surface_area_m_sq)
  Q_PROPERTY(QString BodyMassIndex MEMBER body_mass_index_kg_per_m_sq)
  Q_PROPERTY(QString BodyFat MEMBER body_fat_pct)
  Q_PROPERTY(QString ExerciseState MEMBER exercise_state)
};
Q_DECLARE_METATYPE(PatientState)
