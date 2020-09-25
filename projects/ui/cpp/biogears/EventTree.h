#pragma once

#include <QObject>
#include <QString>
#include <QVariantMap>

#include <map>
#include <vector>

#include <biogears/cdm/patient/actions/SEPatientAction.h>
#include <biogears/cdm/scenario/SEAction.h>
#include <biogears/cdm/substance/SESubstanceManager.h>
#include <biogears/cdm/substance/SESubstance.h>

#include <biogears/schema/cdm/AnesthesiaActions.hxx>
#include <biogears/schema/cdm/EnvironmentActions.hxx>
#include <biogears/schema/cdm/InhalerActions.hxx>
#include <biogears/schema/cdm/PatientActions.hxx>
#include <biogears/schema/cdm/Scenario.hxx>

#include <biogears/cdm/scenario/SEAdvanceTime.h>
#include <biogears/cdm/patient/actions/SEAcuteRespiratoryDistress.h>
#include <biogears/cdm/patient/actions/SEAcuteStress.h>
#include <biogears/cdm/patient/actions/SEAirwayObstruction.h>
#include <biogears/cdm/system/equipment/Anesthesia/actions/SEAnesthesiaMachineConfiguration.h>
#include <biogears/cdm/system/equipment/Anesthesia/SEAnesthesiaMachine.h>
#include <biogears/cdm/system/equipment/Anesthesia/SEAnesthesiaMachineChamber.h>
#include <biogears/cdm/system/equipment/Anesthesia/SEAnesthesiaMachineOxygenBottle.h>
#include <biogears/cdm/system/equipment/Anesthesia/actions/SEAnesthesiaMachineAction.h>
#include <biogears/cdm/patient/actions/SEApnea.h>
#include <biogears/cdm/patient/actions/SEAsthmaAttack.h>
#include <biogears/cdm/patient/actions/SEBrainInjury.h>
#include <biogears/cdm/patient/actions/SEBronchoconstriction.h>
#include <biogears/cdm/patient/actions/SEBurnWound.h>
#include <biogears/cdm/patient/actions/SECardiacArrest.h>
#include <biogears/cdm/patient/actions/SEConsumeNutrients.h>
#include <biogears/cdm/patient/actions/SEExercise.h>
#include <biogears/cdm/patient/actions/SEHemorrhage.h>
#include <biogears/cdm/patient/actions/SEInfection.h>
#include <biogears/cdm/patient/actions/SEIntubation.h>
#include <biogears/cdm/patient/actions/SENeedleDecompression.h>
#include <biogears/cdm/patient/actions/SEPainStimulus.h>
#include <biogears/cdm/patient/actions/SEPatientAssessmentRequest.h>
#include <biogears/cdm/scenario/SESerializeState.h>
#include <biogears/cdm/patient/actions/SESubstanceBolus.h>
#include <biogears/cdm/patient/actions/SESubstanceCompoundInfusion.h>
#include <biogears/cdm/patient/actions/SESubstanceInfusion.h>
#include <biogears/cdm/patient/actions/SESubstanceOralDose.h>
#include <biogears/cdm/patient/actions/SETensionPneumothorax.h>
#include <biogears/cdm/patient/actions/SETourniquet.h>


namespace mil {
namespace tatrc {
  namespace physiology {
    namespace datamodel {
    }
  }
}
}

namespace CDM = mil::tatrc::physiology::datamodel;


//!  This class is for storing event information for a EventTree
//!  A EventTree is QImage
struct Event {
  int eType;
  int eSubType = -1; //For actions like "Substance Bolus", which can be grouped by SubstanceAdministration type and then by specific route
  QString typeName;
  double startTime = -1;
  double duration = 0.0;
  QString description; //The Description of a ActionType
  QString params; //The list of parameter for the ActionType "TYP1=field1;TYPE2=field1,field2
  QString comment; //Comment from the ActionData
  
  bool operator==(const Event& rhs) const { return eType == rhs.eType && eSubType == rhs.eSubType; }
  bool operator!=(const Event& rhs) const { return !(*this == rhs); }

  private:
  Q_GADGET
  Q_PROPERTY(int Type MEMBER eType);
  Q_PROPERTY(int SubType MEMBER eSubType);
  Q_PROPERTY(QString TypeName MEMBER typeName);
  Q_PROPERTY(QString Params MEMBER params);
  Q_PROPERTY(double StartTime MEMBER startTime);
  Q_PROPERTY(double Duration MEMBER duration);
};
Q_DECLARE_METATYPE(Event);

inline std::ostream& operator<<(std::ostream& os, const Event& e)
{
  os << "Event=" << e.typeName.toStdString()  << "\n";
  if (e.startTime) {
    os << "StartTime=" << e.startTime << "\n";
  }
  if (e.duration) {
    os << "Duration=" << e.duration << "\n";
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

namespace bio {
class EventTree : public QObject {
  Q_OBJECT

  Q_PROPERTY(QString source READ Source WRITE Source NOTIFY sourceChanged)
  Q_PROPERTY(bool isValid READ isValid NOTIFY validityChanged)

public:
  enum EventTypes {
    TotalEventTypes,
    UnknownAction,
    PatientAction,
    AcuteRespiratoryDistress,
    AcuteStress,
    AirwayObstruction,
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
    GenericExercise,
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
    Transfusion,
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
  Q_ENUMS(EventTypes);

  EventTree(QObject* parent = nullptr);
  EventTree(QString filepath, QString filename, QObject* parent = nullptr);

  Q_INVOKABLE void add_event(Event ev);
  Q_INVOKABLE void add_event(QString name, int type, int subType, QString params, double startTime_s, double duration_s);
  Q_INVOKABLE Event get_event(int index) { return _events[index]; };
  Q_INVOKABLE int get_event_count() { return _events.size(); };
  Q_INVOKABLE void clear_events() { return _events.clear(); };
  Q_INVOKABLE QString get_timeline_name() { return _timeline_name; };
  Q_INVOKABLE QString get_patient_name() { return _patient_name; }; 
  Q_INVOKABLE void set_timeline_name(QString tName) { _timeline_name = tName; };
  Q_INVOKABLE void set_patient_name(QString pName) { _patient_name = pName; }; 

  void Source(QString source);
  QString Source() const;

  bool isValid() const;
  void sort_events();
  std::vector<Event> get_events() { return _events; };
  biogears::SEAction* decode_action(Event& ev, biogears::SESubstanceManager& subMgr);
  void encode_actions(CDM::ScenarioData* scenario);

  friend std::ostream& operator<<(std::ostream& os, EventTree& EventTree);

signals:
  void sourceChanged(QString source);
  void validityChanged(bool isValid);

  void loadSuccess();
  void loadFailure();

private:

  bool load(QString source);
  bool deactivateEvent(Event& ev);

  bool process_action(Event& ev, CDM::ActionData& action);
  bool process_action(Event& ev, CDM::PatientActionData* action);
  bool process_action(Event& ev, CDM::EnvironmentActionData* action);
  bool process_action(Event& ev, CDM::AnesthesiaMachineActionData* action);
  bool process_action(Event& ev, CDM::InhalerActionData* action);
  bool process_action(Event& ev, CDM::AdvanceTimeData* action);
  bool process_action(Event& ev, CDM::SerializeStateData* action);

  //Decode functions -- accept event data and create an SEAction that is added to Scenario file
  biogears::SEAdvanceTime* decode_advance_time(Event& ev);
  biogears::SEAcuteRespiratoryDistress* decode_acute_respiratory_distress(Event& ev);
  biogears::SEAcuteStress* decode_acute_stress(Event& ev);
  biogears::SEAirwayObstruction* decode_airway_obstruction(Event& ev);
  biogears::SEAnesthesiaMachineConfiguration* decode_anesthesia_machine_configuration(Event& ev, biogears::SESubstanceManager& subMgr);
  biogears::SEApnea* decode_apnea(Event& ev);
  biogears::SEAsthmaAttack* decode_asthma_attack(Event& ev);
  biogears::SEBronchoconstriction* decode_bronchoconstriction(Event& ev);
  biogears::SEBurnWound* decode_burn_wound(Event& ev);
  biogears::SECardiacArrest* decode_cardiac_arrest(Event& ev);
  biogears::SEConsumeNutrients* decode_consume_nutrients(Event& ev);
  biogears::SESubstanceAdministration* decode_substance_administration(Event& ev, biogears::SESubstanceManager& subMgr);
  biogears::SEExercise* decode_exercise(Event& ev);
  biogears::SEHemorrhage* decode_hemorrhage(Event& ev);
  biogears::SEInfection* decode_infection(Event& ev);
  biogears::SENeedleDecompression* decode_needle_decompression(Event& ev);
  biogears::SEPainStimulus* decode_pain_stimulus(Event& ev);
  biogears::SEPatientAssessmentRequest* decode_patient_assessment(Event& ev);
  biogears::SESerializeState* decode_serialize_state(Event& ev);
  biogears::SETensionPneumothorax* decode_tension_pneumothorax(Event& ev);
  biogears::SETourniquet* decode_tourniquet(Event& ev);
  biogears::SEBrainInjury* decode_traumatic_brain_injury(Event& ev);


  double _duration;
  bool _validity;
  QString _source;
  QString _timeline_name;
  QString _patient_name;
  CDM::ScenarioData _data;
  std::vector<Event> _events;
};

inline std::ostream& operator<<(std::ostream& os, EventTree& EventTree)
{
  os << "Begin EventTree\n";
  for (auto event : EventTree._events) {
    os << event << "\n";
  }
  os << "End EventTree\n";
  return os;
}

}
