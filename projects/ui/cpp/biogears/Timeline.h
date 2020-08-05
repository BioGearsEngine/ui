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

//!
//!  This class is for storing event information for a timeline
//!  A Timeline is QImage
struct Event {
  enum EventTypes {
    TotalEventTypes,
    UnknownAction,
    PatientAction,
    AcuteStress,
    AirwayObstructionData,
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
    ForcedExhaleData,
    ForcedInhaleData,
    BreathHoldData,
    UseInhalerData,
    ConsumeNutrients,
    Exercise,
    GeneralExercise,
    RunningExercise,
    CyclingExercise,
    StengthExercise,
    Hemorrhage,
    Infection,
    Intubation,
    MechanicalVentilation,
    NeedleDecompression,
    PainStimulus,
    PericardialEffusion,
    SubstanceAdministration,
    SubstanceBolus,
    SubstanceOralDose,
    SubstanceInfusion,
    SubstanceCompoundInfusion,
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
    PatientAssessmentRequest,
    AdvanceTime,
    SerializeState
  };

  EventTypes eType;
  QString typeName;

  double startTime = -1;
  double duration = -1.;

  QString description; //The Description of a ActionType
  QString params; //The list of parameter for the ActionType "TYP1=field1;TYPE2=field1,field2
  QString comment; //Comment from the ActionData
};

inline std::ostream& operator<<(std::ostream& os, const Event& e)
{
  os << "Event=" << e.typeName.toStdString()  << "\n";
  if (e.startTime) {
    os << "startTime=" << e.startTime << "\n";
  }
  if (e.duration) {
    os << "startTime=" << e.duration << "\n";
  }
  if (e.description.size()) {
    os << "Description=" << e.description.toStdString() << "\n";
  }
  if (e.comment.size()) {
    os << "Comment=" << e.comment.toStdString() << "\n";
  }
  os << "Params:\n";
  auto params = e.params.split(";");
  for (auto param : params) {
    os << "\t" << param.toStdString() << "\n";
  }
  return os;
}

class Timeline : public QObject {
  Q_OBJECT

public:
  Timeline(QString filepath, QString filename);
  Timeline() = default;

  void add_event(Event ev);

  friend std::ostream& operator<<(std::ostream& os, Timeline& timeline);

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

inline std::ostream& operator<<(std::ostream& os, Timeline& timeline)
{
  os << "Begin Timeline\n";
  for (auto event : timeline._events) {
    os << event << "\n";
  }
  os << "End Timeline\n";
  return os;
}

}
