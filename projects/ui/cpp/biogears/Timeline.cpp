#include "Timeline.h"

#include <fstream>
#include <istream>

#include <biogears/schema/cdm/Scenario.hxx>

namespace bio {

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
        process_action(action);
      }
    } catch (::xsd::cxx::tree::parsing<char> e) {
      std::cout << e << std::endl;
    }
  }
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(CDM::ActionData& action)
{
  CDM::ActionData* actionPtr = &action;

  if (auto patientActionPtr = dynamic_cast<CDM::PatientActionData*>(actionPtr)) {
    return process_action(patientActionPtr);
  } else if (auto envrionmentActionPtr = dynamic_cast<CDM::EnvironmentActionData*>(actionPtr)) {
    return process_action(envrionmentActionPtr);
  } else if (auto anesthesiaMachienActionPtr = dynamic_cast<CDM::AnesthesiaMachineActionData*>(actionPtr)) {
    return process_action(anesthesiaMachienActionPtr);
  } else if (auto inhalerActionPtr = dynamic_cast<CDM::InhalerActionData*>(actionPtr)) {
    return process_action(inhalerActionPtr);
  } else if (auto timeAdvanceActionPtr = dynamic_cast<CDM::AdvanceTimeData*>(actionPtr)) {
    return process_action(timeAdvanceActionPtr);
  } else if (auto serialActionPtr = dynamic_cast<CDM::SerializeStateData*>(actionPtr)) {
    return process_action(serialActionPtr);
  } else {
    return false;
  }
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(CDM::PatientActionData* action)
{
  std::cout << "As PatientAction"
            << *action << "\n\n";
  if (auto aStress = dynamic_cast<const CDM::AcuteStressData*>(action)) {
  } else if (auto airwayObst = dynamic_cast<const CDM::AirwayObstructionData*>(action)) {
  } else if (auto apnea = dynamic_cast<const CDM::ApneaData*>(action)) {
  } else if (auto asthmaattack = dynamic_cast<const CDM::AsthmaAttackData*>(action)) {
  } else if (auto brainInjury = dynamic_cast<const CDM::BrainInjuryData*>(action)) {
  } else if (auto bronchoconstr = dynamic_cast<const CDM::BronchoconstrictionData*>(action)) {
  } else if (auto burn = dynamic_cast<const CDM::BurnWoundData*>(action)) {
  } else if (auto cardiacarrest = dynamic_cast<const CDM::CardiacArrestData*>(action)) {
  } else if (auto chestcomp = dynamic_cast<const CDM::ChestCompressionData*>(action)) {
    // -->const CDM::ChestCompressionForceData* cprForce = dynamic_cast<const CDM::ChestCompressionForceData*>(chestcomp)
    // -->const CDM::ChestCompressionForceScaleData* cprScale = dynamic_cast<const CDM::ChestCompressionForceScaleData*>(chestcomp)
  } else if (auto chestOccl = dynamic_cast<const CDM::ChestOcclusiveDressingData*>(action)) {
  } else if (auto conResp = dynamic_cast<const CDM::ConsciousRespirationData*>(action)) {
  } else if (auto consume = dynamic_cast<const CDM::ConsumeNutrientsData*>(action)) {
  } else if (auto exercise = dynamic_cast<const CDM::ExerciseData*>(action)) {
  } else if (auto hem = dynamic_cast<const CDM::HemorrhageData*>(action)) {
  } else if (auto infect = dynamic_cast<const CDM::InfectionData*>(action)) {
  } else if (auto intubation = dynamic_cast<const CDM::IntubationData*>(action)) {
  } else if (auto mvData = dynamic_cast<const CDM::MechanicalVentilationData*>(action)) {
  } else if (auto needleDecomp = dynamic_cast<const CDM::NeedleDecompressionData*>(action)) {
  } else if (auto pain = dynamic_cast<const CDM::PainStimulusData*>(action)) {
  } else if (auto pericardialEff = dynamic_cast<const CDM::PericardialEffusionData*>(action)) {
  } else if (auto admin = dynamic_cast<const CDM::SubstanceAdministrationData*>(action)) {
  } else if (auto pneumo = dynamic_cast<const CDM::TensionPneumothoraxData*>(action)) {
  } else if (auto tournData = dynamic_cast<const CDM::TourniquetData*>(action)) {
  } else if (auto urinate = dynamic_cast<const CDM::UrinateData*>(action)) {
  } else if (auto orData = dynamic_cast<const CDM::OverrideData*>(action)) {
  }

  return true;
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(CDM::EnvironmentActionData* action)
{
  std::cout << "As EnvironmentAction"
            << *action << "\n\n";

  if (auto change = dynamic_cast<const CDM::EnvironmentChangeData*>(action)) {
  } else if (auto thermal = dynamic_cast<const CDM::ThermalApplicationData*>(action)) {
  }

  return true;
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(CDM::AnesthesiaMachineActionData* action)
{
  std::cout << "As AnesthesiaMachienAction"
            << *action << "\n\n";
  if (auto anConfig = dynamic_cast<CDM::AnesthesiaMachineConfigurationData*>(action)) {
  } else if (auto anO2WallLoss = dynamic_cast<CDM::OxygenWallPortPressureLossData*>(action)) {
  } else if (auto anO2TankLoss = dynamic_cast<CDM::OxygenTankPressureLossData*>(action)) {
  } else if (auto anExLeak = dynamic_cast<CDM::ExpiratoryValveLeakData*>(action)) {
  } else if (auto anExObs = dynamic_cast<CDM::ExpiratoryValveObstructionData*>(action)) {
  } else if (auto anInLeak = dynamic_cast<CDM::InspiratoryValveLeakData*>(action)) {
  } else if (auto anInObs = dynamic_cast<CDM::InspiratoryValveObstructionData*>(action)) {
  } else if (auto anMskLeak = dynamic_cast<CDM::MaskLeakData*>(action)) {
  } else if (auto anSodaFail = dynamic_cast<CDM::SodaLimeFailureData*>(action)) {
  } else if (auto anTubLeak = dynamic_cast<CDM::TubeCuffLeakData*>(action)) {
  } else if (auto anVapFail = dynamic_cast<CDM::VaporizerFailureData*>(action)) {
  } else if (auto anVentLoss = dynamic_cast<CDM::VentilatorPressureLossData*>(action)) {
  } else if (auto anYDisc = dynamic_cast<CDM::YPieceDisconnectData*>(action)) {
  }

  return true;
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(CDM::InhalerActionData* action)
{
  std::cout << "As InhalerAction"
            << *action << "\n\n";
  if (auto config = dynamic_cast<const CDM::InhalerConfigurationData*>(action)) {
  }
  return true;
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(CDM::AdvanceTimeData* action)
{
  std::cout << "As AdvanceTime"
            << *action << "\n\n";
  return true;
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(CDM::SerializeStateData* action)
{
  std::cout << "As SerializeState"
            << *action << "\n\n";
  return true;
}
//-----------------------------------------------------------------------------
void Timeline::add_event(Event ev)
{
}
}