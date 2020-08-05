#pragma once

#include <QObject>
#include <QString>

#include <map>
#include <vector>

#include <biogears/cdm/patient/actions/SEPatientAction.h>
#include <biogears/cdm/scenario/SEAction.h>

#include <biogears/schema/cdm/AnesthesiaActions.hxx>
#include <biogears/schema/cdm/EnvironmentActions.hxx>
#include <biogears/schema/cdm/InhalerActions.hxx>
#include <biogears/schema/cdm/PatientActions.hxx>
#include <biogears/schema/cdm/Scenario.hxx>

namespace mil {
namespace tatrc {
  namespace physiology {
    namespace datamodel {
    }
  }
}
}

namespace CDM = mil::tatrc::physiology::datamodel;

namespace bio {

enum EventTypes {
  TotalEventTypes,
  UnknownAction,
  PatientAction,
  AcuteStress,
  Apnea,
  AsthmaAttack,
  BrainInjury,
  Bronchoconstriction,
  BurnWound,
  CardiacArrest,
  ChestCompression,
  ChestCompressionForce,
  ChestCompressionForceScale,
  ChestOcclusiveDressing,
  ConsciousRespiration,
  ConsumeNutrients,
  Exercise,
  Hemorrhage,
  Infection,
  Intubation,
  MechanicalVentilation,
  NeedleDecompression,
  PainStimulus,
  PericardialEffusion,
  SubstanceAdministration,
  TensionPneumothorax,
  Tourniquet,
  Urinate,
  Override,
  EnvironmentAction,
  EnvironmentChange,
  ThermalApplication,
  AnesthesiaMachineAction,
  AnesthesiaMachineConfiguration,
  OxygenWallPortPressureLoss,
  OxygenTankPressureLoss,
  ExpiratoryValveLeak,
  ExpiratoryValveObstruction,
  InspiratoryValveLeak,
  InspiratoryValveObstruction,
  MaskLeak,
  SodaLimeFailure,
  TubeCuffLeak,
  VaporizerFailure,
  VentilatorPressureLoss,
  YPieceDisconnect,
  InhalerAction,
  InhalerConfiguration,
  AdvanceTime,
  SerializeState
};

//!
//!  This class is for storing event information for a timeline
//!  A Timeline is QImage
struct Event {
  EventTypes eType;
  QString typeName;

  double startTime;
  double duration;

  QString description;  //The Description of a ActionType
  QString params;       //The list of parameter for the ActionType "TYP1=field1;TYPE2=field1,field2
  QString comment;      //Comment from the ActionData
};

class Timeline : public QObject {
  Q_OBJECT

public:
  Timeline(QString filepath, QString filename);
  Timeline() = default;

  void add_event(Event ev);

private:
  bool process_action(Event& ev, CDM::ActionData& action);
  bool process_action(Event& ev, CDM::PatientActionData* action);
  bool process_action(Event& ev, CDM::EnvironmentActionData* action);
  bool process_action(Event& ev, CDM::AnesthesiaMachineActionData* action);
  bool process_action(Event& ev, CDM::InhalerActionData* action);
  bool process_action(Event& ev, CDM::AdvanceTimeData* action);
  bool process_action(Event& ev, CDM::SerializeStateData* action);

  double duration;
  CDM::ScenarioData _data;
  std::vector<Event> _events;
};

}
