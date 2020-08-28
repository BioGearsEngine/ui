#include "Urinalysis.h"

QString Urinalysis::Color() { return _color; }
QString Urinalysis::Appearance() { return _appearance; }
QString Urinalysis::Bilirubin() { return _bilirubin; }
QString Urinalysis::SpecificGravity() { return _specificGravity; }
QString Urinalysis::pH() { return _pH; }
QString Urinalysis::Urobilinogen() { return _urobilinogem; }
QString Urinalysis::Glucose() { return _glucose; }
QString Urinalysis::Ketone() { return _ketone; }
QString Urinalysis::Protein() { return _protein; }
QString Urinalysis::Blood() { return _blood; }
QString Urinalysis::Nitrite() { return _nitrite; }
QString Urinalysis::LeukocyteEsterase() { return _leukocyteEsterase; }

void Urinalysis::Color(int value)
{
  switch (value) {
  case (CDM::enumUrineColor::PaleYellow):
    _color = "PaleYellow";
    break;
  case (CDM::enumUrineColor::Yellow):
    _color = "Yellow";
    break;
  case (CDM::enumUrineColor::DarkYellow):
    _color = "DarkYellow";
    break;
  case (CDM::enumUrineColor::Pink):
    _color = "Pink";
    break;
  default:
    _color = "";
    break;
  }
}
void Urinalysis::Appearance(int value)
{
  switch (value) {
  case CDM::enumClarityIndicator::Clear:
    _appearance = "Clear";
    break;
  case CDM::enumClarityIndicator::SlightlyCloudy:
    _appearance = "SlightlyCloudy";
    break;
  case CDM::enumClarityIndicator::Cloudy:
    _appearance = "Cloudy";
    break;
  case CDM::enumClarityIndicator::Turbid:
    _appearance = "Turbid";
    break;
  default:
    _appearance = "";
    break;
  }
}
void Urinalysis::Bilirubin(double value) { _bilirubin = QString("%1").arg(value); }
void Urinalysis::SpecificGravity(double value) { _specificGravity = QString("%1").arg(value); }
void Urinalysis::pH(double value) { _pH = QString("%1").arg(value); }
void Urinalysis::Urobilinogen(double value) { _urobilinogem = QString("%1").arg(value); }

void Urinalysis::Glucose(bool value)
{
  switch (value) {
  case CDM::enumPresenceIndicator::Positive:
    _glucose = "Positive";
    break;
  default:
    _glucose = "Negative";
    break;
  }
}
void Urinalysis::Ketone(bool value)
{
  switch (value) {
  case CDM::enumPresenceIndicator::Positive:
    _ketone = "Positive";
    break;
  default:
    _ketone = "Negative";
    break;
  }
}
void Urinalysis::Protein(bool value) 
{
  switch (value) {
  case CDM::enumPresenceIndicator::Positive:
    _protein = "Positive";
    break;
  default:
    _protein = "Negative";
    break;
  }
}
void Urinalysis::Blood(bool value) 
{
  switch (value) {
  case CDM::enumPresenceIndicator::Positive:
    _blood = "Positive";
    break;
  default:
    _blood = "Negative";
    break;
  }
}
void Urinalysis::Nitrite(bool value) 
{
  switch (value) {
  case CDM::enumPresenceIndicator::Positive:
    _nitrite = "Positive";
    break;
  default:
    _nitrite = "Negative";
    break;
  }
}
void Urinalysis::LeukocyteEsterase(bool value) 
{
  switch (value) {
  case CDM::enumPresenceIndicator::Positive:
    _leukocyteEsterase = "Positive";
    break;
  default:
    _leukocyteEsterase = "Negative";
    break;
  }
}