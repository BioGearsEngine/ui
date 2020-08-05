#include "Timeline.h"

#include <fstream>
#include <istream>

#include <biogears/cdm/properties/SEScalarTypes.h>
#include <biogears/schema/cdm/Scenario.hxx>
#include <biogears/string/manipulation.h>

namespace bio {

//!
//!  Timeline is a data structure for storing events and converting between XSD <--> QML
//!  It currently only affords Scenario 1.0 from BioGears 6.0 once integrated we will
//!  add support for Scenario 2.0 where events have Durations and Occurance Times.
//!
//!  This would require striking duration and an advanced sorting method for events based off
//!  endtime instead of occurance.

Timeline::Timeline(QString path, QString name)
{
  std::ifstream stream{ (path + "/" + name).toStdString() };

  char buffer[2048];

  stream.clear(); // clear fail and eof bits
  stream.seekg(0, std::ios::beg); // back to the start!

  if (stream.is_open()) {
    try {
      xml_schema::flags flags;
      xml_schema::properties props;
      props.schema_location("uri:/mil/tatrc/physiology/datamodel", "xsd/BioGearsDataModel.xsd");
      auto scenario = CDM::Scenario(stream, flags, props);
      for (auto& action : scenario->Action()) {
        Event ev;

        ev.eType = EventTypes::UnknownAction;
        ev.typeName = "Unknown Action";
        ev.text = (action.Comment().present()) ? action.Comment().get().c_str() : "";

        ///!Scenario 2.0 An Event with no Duration last for ever. When a duration is preset the inverse action occurs when the duration is over
        ///!                   An Event with Occurs starts at the time specified.  If duration < action.Occurs() + action.Duration();
        ///!                   TimeAdvance Events have no extra fields

        ev.startTime = (action.Occurs().present()) ? action.Occurs().get() : duration;
        ev.duration = (action.Duration().present()) ? action.Duration().get() : 0.;

        if (process_action(ev, action)) {
          _events.push_back(ev);
        } else {
          std::cerr << "Error processing the " << ev.typeName.toStdString() << "\n";
        }
      }
    } catch (::xsd::cxx::tree::parsing<char> e) {
      std::cout << e << std::endl;
    }
  }
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(Event& ev, CDM::ActionData& action)
{
  CDM::ActionData* actionPtr = &action;
  ev.eType = EventTypes::UnknownAction;
  ev.typeName = "Unknown Supported Action Type";
  if (auto patientActionPtr = dynamic_cast<CDM::PatientActionData*>(actionPtr)) {
    return process_action(ev, patientActionPtr);
  } else if (auto envrionmentActionPtr = dynamic_cast<CDM::EnvironmentActionData*>(actionPtr)) {
    return process_action(ev, envrionmentActionPtr);
  } else if (auto anesthesiaMachienActionPtr = dynamic_cast<CDM::AnesthesiaMachineActionData*>(actionPtr)) {
    return process_action(ev, anesthesiaMachienActionPtr);
  } else if (auto inhalerActionPtr = dynamic_cast<CDM::InhalerActionData*>(actionPtr)) {
    return process_action(ev, inhalerActionPtr);
  } else if (auto timeAdvanceActionPtr = dynamic_cast<CDM::AdvanceTimeData*>(actionPtr)) {
    return process_action(ev, timeAdvanceActionPtr);
  } else if (auto serialActionPtr = dynamic_cast<CDM::SerializeStateData*>(actionPtr)) {
    return process_action(ev, serialActionPtr);
  } else {
    return false;
  }
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(Event& ev, CDM::PatientActionData* action)
{
  std::cout << "As PatientAction"
            << *action << "\n\n";
  ev.eType = EventTypes::PatientAction;
  ev.typeName = "Patient Events\n";

  if (auto aStress = dynamic_cast<const CDM::AcuteStressData*>(action)) {
    aStress->Comment();
    return true;
  } else if (auto airwayObst = dynamic_cast<const CDM::AirwayObstructionData*>(action)) {
    return true;
  } else if (auto apnea = dynamic_cast<const CDM::ApneaData*>(action)) {
    return true;
  } else if (auto asthmaattack = dynamic_cast<const CDM::AsthmaAttackData*>(action)) {
    return true;
  } else if (auto brainInjury = dynamic_cast<const CDM::BrainInjuryData*>(action)) {
    return true;
  } else if (auto bronchoconstr = dynamic_cast<const CDM::BronchoconstrictionData*>(action)) {
    return true;
  } else if (auto burn = dynamic_cast<const CDM::BurnWoundData*>(action)) {
    return true;
  } else if (auto cardiacarrest = dynamic_cast<const CDM::CardiacArrestData*>(action)) {
    return true;
  } else if (auto chestcomp = dynamic_cast<const CDM::ChestCompressionData*>(action)) {
    ev.eType = EventTypes::ChestCompression;
    ev.typeName = "Chest Compression Action\n";
    if (auto cprForce = dynamic_cast<const CDM::ChestCompressionForceData*>(chestcomp)) {
      return true;
    } else if (auto cprScale = dynamic_cast<const CDM::ChestCompressionForceScaleData*>(chestcomp)) {
      return true;
    }
    return false;
  } else if (auto chestOccl = dynamic_cast<const CDM::ChestOcclusiveDressingData*>(action)) {
    return true;
  } else if (auto conResp = dynamic_cast<const CDM::ConsciousRespirationData*>(action)) {
    return true;
  } else if (auto consume = dynamic_cast<const CDM::ConsumeNutrientsData*>(action)) {
    return true;
  } else if (auto exercise = dynamic_cast<const CDM::ExerciseData*>(action)) {
    return true;
  } else if (auto hem = dynamic_cast<const CDM::HemorrhageData*>(action)) {
    return true;
  } else if (auto infect = dynamic_cast<const CDM::InfectionData*>(action)) {
    return true;
  } else if (auto intubation = dynamic_cast<const CDM::IntubationData*>(action)) {
    return true;
  } else if (auto mvData = dynamic_cast<const CDM::MechanicalVentilationData*>(action)) {
    return true;
  } else if (auto needleDecomp = dynamic_cast<const CDM::NeedleDecompressionData*>(action)) {
    return true;
  } else if (auto pain = dynamic_cast<const CDM::PainStimulusData*>(action)) {
    return true;
  } else if (auto pericardialEff = dynamic_cast<const CDM::PericardialEffusionData*>(action)) {
    return true;
  } else if (auto admin = dynamic_cast<const CDM::SubstanceAdministrationData*>(action)) {
    return true;
  } else if (auto pneumo = dynamic_cast<const CDM::TensionPneumothoraxData*>(action)) {
    return true;
  } else if (auto tournData = dynamic_cast<const CDM::TourniquetData*>(action)) {
    return true;
  } else if (auto urinate = dynamic_cast<const CDM::UrinateData*>(action)) {
    return true;
  } else if (auto orData = dynamic_cast<const CDM::OverrideData*>(action)) {
    return true;
  }
  return false;
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(Event& ev, CDM::EnvironmentActionData* action)
{
  std::cout << "As EnvironmentAction"
            << *action << "\n\n";
  ev.eType = EventTypes::EnvironmentAction;
  ev.typeName = "Environment Action";
  if (auto change = dynamic_cast<const CDM::EnvironmentChangeData*>(action)) {
    return true;
  } else if (auto thermal = dynamic_cast<const CDM::ThermalApplicationData*>(action)) {
    return true;
  }

  return false;
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(Event& ev, CDM::AnesthesiaMachineActionData* action)
{
  std::cout << "As AnesthesiaMachienAction"
            << *action << "\n\n";
  ev.eType = EventTypes::AnesthesiaMachineAction;
  ev.typeName = "Anesthesia Machine Action";
  if (auto anConfig = dynamic_cast<CDM::AnesthesiaMachineConfigurationData*>(action)) {
    ev.eType = EventTypes::AnesthesiaMachineConfiguration;
    ev.typeName = "Anesthesia Machine Configuration";
    ev.description = "Change the configuration of a Anesthesia Machine";
    return true;
  } else if (auto anO2WallLoss = dynamic_cast<CDM::OxygenWallPortPressureLossData*>(action)) {
    ev.eType = EventTypes::OxygenWallPortPressureLoss;
    ev.typeName = "Oxygen Wall Port Pressure Loss";
    ev.description = "Modify the value of any pressure loss between the anesthesia machine and the wall connection";
    return true;
  } else if (auto anO2TankLoss = dynamic_cast<CDM::OxygenTankPressureLossData*>(action)) {
    ev.eType = EventTypes::OxygenTankPressureLoss;
    ev.typeName = "Oxygen tank pressure loss";
    ev.description = "Modify the value of any pressure loss between the anesthesia machine and the oxygen tank";
    return true;
  } else if (auto anExLeak = dynamic_cast<CDM::ExpiratoryValveLeakData*>(action)) {
    ev.eType = EventTypes::ExpiratoryValveLeak;
    ev.typeName = "Expiratory valve leak";
    ev.description = "Modify the value of any pressure loss between the anesthesia machine and the expiratory valve";
    return true;
  } else if (auto anExObs = dynamic_cast<CDM::ExpiratoryValveObstructionData*>(action)) {
    ev.eType = EventTypes::ExpiratoryValveObstruction;
    ev.typeName = "Expiratory valve obstruction";
    ev.description = "Modify the value of any obstruction in the expiratory valve";
    return true;
  } else if (auto anInLeak = dynamic_cast<CDM::InspiratoryValveLeakData*>(action)) {
    ev.eType = EventTypes::InspiratoryValveLeak;
    ev.typeName = "Inspiratory valve pressure loss";
    ev.description = "Modify the value of any pressure loss between the anesthesia machine and inspiratory valve";
    return true;
  } else if (auto anInObs = dynamic_cast<CDM::InspiratoryValveObstructionData*>(action)) {
    ev.eType = EventTypes::InspiratoryValveObstruction;
    ev.typeName = "Inspiratory valve obstruction";
    ev.description = "Modify the value of any obstruction in the inspiratory valve";
    return true;
  } else if (auto anMskLeak = dynamic_cast<CDM::MaskLeakData*>(action)) {
    ev.eType = EventTypes::MaskLeak;
    ev.typeName = "Leak in the Mask Seal";
    ev.description = "Modify the severity and occurence of a mask seal ";
    return true;
  } else if (auto anSodaFail = dynamic_cast<CDM::SodaLimeFailureData*>(action)) {
    ev.eType = EventTypes::SodaLimeFailure;
    ev.typeName = "A failure in the Soda Lime";
    ev.description = "Modifies the delivery of f NaOH & CaO chemicals";
    return true;
  } else if (auto anTubLeak = dynamic_cast<CDM::TubeCuffLeakData*>(action)) {
    ev.eType = EventTypes::TubeCuffLeak;
    ev.typeName = "Leak in the tube cuff";
    ev.description = "Modify the occurence and severity of the tub cuff";
    return true;
  } else if (auto anVapFail = dynamic_cast<CDM::VaporizerFailureData*>(action)) {
    ev.eType = EventTypes::VaporizerFailure;
    ev.typeName = "A failure of the vaporizer";
    ev.description = "Modifies the delivery of f NaOH & CaO chemicals";
    return true;
  } else if (auto anVentLoss = dynamic_cast<CDM::VentilatorPressureLossData*>(action)) {
    ev.eType = EventTypes::VentilatorPressureLoss;
    ev.typeName = "Loss of ventilator pressure";
    ev.description = "Modify the severity of a loss in ventilator pressure";
    return true;
  } else if (auto anYDisc = dynamic_cast<CDM::YPieceDisconnectData*>(action)) {
    ev.eType = EventTypes::YPieceDisconnect;
    ev.typeName = "Disconnection of the Y piece";
    ev.description = "Modifies the occurence of a Y piece disconnection";
    return true;
  }

  return false;
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(Event& ev, CDM::InhalerActionData* action)
{
  using namespace biogears;
  std::cout << "As InhalerAction"
            << *action << "\n\n";
  ev.eType = EventTypes::InhalerAction;
  ev.typeName = "Inhaler Action";
  if (auto inhalerConfig = dynamic_cast<const CDM::InhalerConfigurationData*>(action)) {
    ev.eType = EventTypes::InhalerConfiguration;
    ev.typeName = "Inhaler Configuration";
    ev.description = "Change the configuration of the Inhaler Machine";
    if (inhalerConfig->ConfigurationFile().present()) {
      ev.params = asprintf("ConfigurationFile=%s;", inhalerConfig->ConfigurationFile().get().c_str()).c_str();
    }
    if (inhalerConfig->Configuration().present()) {
      auto config = inhalerConfig->Configuration().get();
      if (config.MeteredDose().present()) {
        auto md = config.MeteredDose().get();
        ev.params = asprintf("MeteredDose=%d,%s;", md.value(), md.unit()->c_str()).c_str();
      }
      if (config.NozzleLoss().present()) {
        auto nl = config.NozzleLoss().get();
        ev.params = asprintf("NozzleLoss=%d,%s;", nl.value(), nl.unit()->c_str()).c_str();
      }
      if (config.SpacerVolume().present()) {
        auto sv = config.SpacerVolume().get();
        ev.params = asprintf("SpacerVolume=%d,%s;", sv.value(), sv.unit()->c_str()).c_str();
      }
      if (config.State().present()) {  
        ev.params = asprintf("State=%s;", ((config.State().get() == CDM::enumOnOff::On) ? "On" : "Off")).c_str();
      }
      if (config.Substance().present()) {
        ev.params = asprintf("Substance=%s;", config.Substance().get().c_str()).c_str();
      }
    }
    if (ev.params.size() && ev.params.back() == ";") {
      ev.params.remove(ev.params.size() - 1);
    }
    return true;
  }
  return false;
  ;
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(Event& ev, CDM::AdvanceTimeData* action)
{
  using namespace biogears;

  std::cout << "As AdvanceTime"
            << *action << "\n\n";

  ev.eType = EventTypes::AdvanceTime;
  ev.typeName = "Time Advancement";
  ev.description = "Advances the time of the simulation by the given duration";
  ev.params = asprintf("Time=%d,%s", action->Time().value(), action->Time().unit()).c_str();

  return true;
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(Event& ev, CDM::SerializeStateData* action)
{
  using namespace biogears;
  std::cout << "As SerializeState"
            << *action << "\n\n";

  ev.eType = EventTypes::SerializeState;
  ev.typeName = asprintf("%s %s", (action->Type() == CDM::enumSerializationType::Load) ? "Load" : "Save", "State").c_str();
  ev.description = "Serializes the current simulation state to disk";

  std::string param_str;
  param_str = asprintf("filename=%s", action->Filename().c_str());
  param_str += asprintf("type=%s", (action->Type() == CDM::enumSerializationType::Load) ? "Load" : "Save");
  ev.params = param_str.c_str();

  return true;
}
//-----------------------------------------------------------------------------
void Timeline::add_event(Event ev)
{
}
}