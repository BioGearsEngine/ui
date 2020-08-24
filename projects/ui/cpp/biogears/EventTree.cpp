#include "EventTree.h"

#include <fstream>
#include <istream>

#include <biogears/cdm/properties/SEScalarTypes.h>
#include <biogears/schema/cdm/Scenario.hxx>
#include <biogears/string/manipulation.h>

namespace bio {

//!
//!  EventTree is a data structure for storing events and converting between XSD <--> QML
//!  It currently only affords Scenario 1.0 from BioGears 6.0 once integrated we will
//!  add support for Scenario 2.0 where events have Durations and Occurance Times.
//!
//!  This would require striking duration and an advanced sorting method for events based off
//!  endtime instead of occurance.

//! TODO: Apparently for Scalard Data Unit() is an optional.  But, it should not be for ScalarData.
//!       For debugging reasons we need to add a lot of extra if statments and asserts to avoid
//!       poorly formated Scenario files.

EventTree::EventTree(QObject* parent)
  : QObject(parent)
{
}
//-----------------------------------------------------------------------------
EventTree::EventTree(QString path, QString name, QObject* parent)
  : QObject(parent)
{
  _validity = load(path + "/" + name);
}
//-----------------------------------------------------------------------------
bool EventTree::isValid() const
{
  return _validity;
};
//-----------------------------------------------------------------------------
QString EventTree::Source() const
{
  return _source;
}
//-----------------------------------------------------------------------------
void EventTree::Source(QString source)
{
  if (load(source)) {
    _source = source;
    emit sourceChanged(source);
  }
  std::cout << *this;
}
//-----------------------------------------------------------------------------
bool EventTree::load(QString source)
{
  std::ifstream stream{ source.toStdString() };

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
        ev.comment = (action.Comment().present()) ? action.Comment().get().c_str() : "";

        ///!Scenario 2.0 An Event with no Duration last for ever. When a duration is preset the inverse action occurs when the duration is over
        ///!                   An Event with Occurs starts at the time specified.  If duration < action.Occurs() + action.Duration();
        ///!                   TimeAdvance Events have no extra fields

        ev.startTime = (action.Occurs().present()) ? action.Occurs().get() : _duration;
        ev.duration = (action.Duration().present()) ? action.Duration().get() : 0.;

        if (process_action(ev, action)) {
          if (ev.params.size() && ev.params.back() == ";") {
            ev.params.remove(ev.params.size() - 1);
          }
          _events.push_back(ev);
        } else {
          _validity = false;
          emit validityChanged(_validity);
          emit loadFailure();
          std::cerr << "Error processing the " << ev.typeName.toStdString() << "\n";
        }
      }
    } catch (::xsd::cxx::tree::parsing<char> e) {
      std::cout << e << std::endl;
      _validity = false;
      emit validityChanged(_validity);
      emit loadFailure();
      return false;
    }
    _validity = true;
    emit validityChanged(_validity);
    emit loadSuccess();
  } else {
    _validity = false;
    emit validityChanged(_validity);
    emit loadFailure();
  }
  return _validity;
}
//-----------------------------------------------------------------------------
bool EventTree::process_action(Event& ev, CDM::ActionData& action)
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
bool EventTree::process_action(Event& ev, CDM::PatientActionData* action)
{
  using namespace biogears;

  ev.eType = EventTypes::PatientAction;
  ev.typeName = "Patient Events\n";

  if (auto ards = dynamic_cast<const CDM::AcuteRespiratoryDistressData*>(action)) {
    ev.eType = EventTypes::AcuteRespiratoryDistress;
    ev.typeName = "Acute Respiratory Distress";
    ev.description = "Applies Acute Respiratory Distress insult";
    ev.params = "";

    ev.params.append(asprintf("Severity=%f;", ards->Severity().value()).c_str());
    return true;
  } else if (auto aStress = dynamic_cast<const CDM::AcuteStressData*>(action)) {
    ev.eType = EventTypes::AcuteStress;
    ev.typeName = "Acute Stress";
    ev.description = "Applies Acute Stress insult";
    ev.params = "";

    ev.params.append(asprintf("Severity=%f;", aStress->Severity().value()).c_str());
    return true;
  } else if (auto airwayObst = dynamic_cast<const CDM::AirwayObstructionData*>(action)) {
    ev.eType = EventTypes::AirwayObstruction;
    ev.typeName = "Airway Obstruction";
    ev.description = "Applies an airway obstruction";
    ev.params = "";

    ev.params.append(asprintf("Severity=%f;", airwayObst->Severity().value()).c_str());
    return true;
  } else if (auto apnea = dynamic_cast<const CDM::ApneaData*>(action)) {
    ev.eType = EventTypes::Apnea;
    ev.typeName = "Apnea";
    ev.description = "Applies an apnea insult";
    ev.params = "";

    ev.params.append(asprintf("Severity=%f;", apnea->Severity().value()).c_str());
    return true;
  } else if (auto asthmaattack = dynamic_cast<const CDM::AsthmaAttackData*>(action)) {
    ev.eType = EventTypes::AsthmaAttack;
    ev.typeName = "Asthma Attack";
    ev.description = "Applies Asthma Attack Insult";
    ev.params = "";

    ev.params.append(asprintf("Severity=%f;", asthmaattack->Severity().value()).c_str());
    return true;
  } else if (auto brainInjury = dynamic_cast<const CDM::BrainInjuryData*>(action)) {
    ev.eType = EventTypes::BrainInjury;
    ev.typeName = "Brain Injury";
    ev.description = "Applies a brain injury insults";
    ev.params = "";

    ev.params.append(asprintf("Severity=%f;", brainInjury->Severity().value()).c_str());
    switch (brainInjury->Type()) {
    case CDM::enumBrainInjuryType::value::Diffuse:
      ev.params.append("Type=Diffuse;");
      break;
    case CDM::enumBrainInjuryType::value::LeftFocal:
      ev.params.append("Type=LeftFocal;");
      break;
    case CDM::enumBrainInjuryType::value::RightFocal:
      ev.params.append("Type=RightFocal;");
      break;
    }
    ev.params.append(asprintf("Severity=%f;", brainInjury->Severity().value()).c_str());
    return true;
  } else if (auto bronchoconstr = dynamic_cast<const CDM::BronchoconstrictionData*>(action)) {
    ev.eType = EventTypes::Bronchoconstriction;
    ev.typeName = "Bronchoconstriction";
    ev.description = "Applies a bronchoconstriction insult";
    ev.params = "";

    ev.params.append(asprintf("Severity=%f;", bronchoconstr->Severity().value()).c_str());
    return true;
  } else if (auto burn = dynamic_cast<const CDM::BurnWoundData*>(action)) {
    ev.eType = EventTypes::BurnWound;
    ev.typeName = "Burn Wound";
    ev.description = "Applies a burn wound insult";
    ev.params = "";

    ev.params.append(asprintf("State=%s;", burn->TotalBodySurfaceArea().value(), burn->TotalBodySurfaceArea().unit()->c_str()).c_str());
    return true;
  } else if (auto cardiacarrest = dynamic_cast<const CDM::CardiacArrestData*>(action)) {
    ev.eType = EventTypes::CardiacArrest;
    ev.typeName = "Cardiac Arrest";
    ev.description = "Applies a cardiac arrest insult to the patient";
    ev.params = "";

    ev.params.append(asprintf("State=%s;", cardiacarrest->State() == CDM::enumOnOff::On ? "On" : "Off").c_str());
    return true;
  } else if (auto chestcomp = dynamic_cast<const CDM::ChestCompressionData*>(action)) {
    ev.eType = EventTypes::ChestCompression;
    ev.typeName = "Chest Compression";
    ev.description = "Manual Chest Compression";
    ev.params = "";
    ev.eType = EventTypes::ChestCompression;
    ev.typeName = "Chest Compression Action\n";
    if (auto cprForce = dynamic_cast<const CDM::ChestCompressionForceData*>(chestcomp)) {
      ev.eType = EventTypes::ChestCompressionForce;
      ev.typeName = "Chest Compression Force";
      ev.description = "Chest Compression Force?";
      ev.params = "";

      ev.params.append(asprintf("Force=%f,%s;", cprForce->Force().value(), cprForce->Force().unit()->c_str()).c_str());
      return true;
    } else if (auto cprScale = dynamic_cast<const CDM::ChestCompressionForceScaleData*>(chestcomp)) {
      ev.eType = EventTypes::ChestCompressionForceScale;
      ev.typeName = "Chest Compression Force Scale";
      ev.description = "Chest Compression Force Scale?";
      ev.params = "";

      ev.params.append(asprintf("Side=%f,%s;", cprScale->ForcePeriod()->value(), cprScale->ForcePeriod()->unit()->c_str()).c_str());
      ev.params.append(asprintf("command=%f;", cprScale->ForceScale().value()).c_str());
      return true;
    }
    return false;
  } else if (auto chestOccl = dynamic_cast<const CDM::ChestOcclusiveDressingData*>(action)) {
    ev.eType = EventTypes::ChestOcclusiveDressing;
    ev.typeName = "Chest Occlusive Dressing";
    ev.description = "Applies a occlusive dressing to the chest";
    ev.params = "";

    ev.params.append(asprintf("Side=%s;", chestOccl->Side() == CDM::enumSide::Left ? "Left" : "Right").c_str());
    ev.params.append(asprintf("command=%s;", chestOccl->State() == CDM::enumOnOff::On ? "On" : "Off").c_str());

    return true;
  } else if (auto conResp = dynamic_cast<const CDM::ConsciousRespirationData*>(action)) {
    ev.eType = EventTypes::ConsciousRespiration;
    ev.typeName = "Conscious Respiration";
    ev.description = "Manually Respirate the patient";
    ev.params = "";

    ev.params.append(asprintf("AppendToPrevious=%s;", conResp->AppendToPrevious() ? "True" : "False").c_str());
    auto index = 0;
    for (auto& command : conResp->Command()) {
      if (auto exhale = dynamic_cast<const CDM::ForcedExhaleData*>(&command)) {
        ev.params.append(asprintf("%d:ForcedExhale-ExpiratoryReserveVolumeFraction=%f;", index, exhale->ExpiratoryReserveVolumeFraction().value()).c_str());
        ev.params.append(asprintf("%d:ForcedExhale-Period=%f,%s;", index, exhale->Period().value(), exhale->Period().unit()->c_str()).c_str());
      } else if (auto inhale = dynamic_cast<const CDM::ForcedInhaleData*>(&command)) {
        ev.params.append(asprintf("%d:ForcedInhale-InspiratoryCapacityFraction=%f;", index, inhale->InspiratoryCapacityFraction().value()).c_str());
        ev.params.append(asprintf("%d:ForcedInhale-Period=%f,%s;", index, inhale->Period().value(), inhale->Period().unit()->c_str()).c_str());
      } else if (auto breathHold = dynamic_cast<const CDM::BreathHoldData*>(&command)) {
        ev.params.append(asprintf("%d:BreathHold-Period=%f,%s;", index, breathHold->Period().value(), breathHold->Period().unit()->c_str()).c_str());
      } else if (auto inhaler = dynamic_cast<const CDM::UseInhalerData*>(&command)) {
        ev.params.append(asprintf("%d:UseInhaler;", index).c_str());
      }
      ++index;
    }

    return true;
  } else if (auto consume = dynamic_cast<const CDM::ConsumeNutrientsData*>(action)) {
    ev.eType = EventTypes::ConsumeNutrients;
    ev.typeName = "Consume Nutrients";
    ev.description = "Force the patient to consume nutrients";
    ev.params = "";

    if (consume->Nutrition().present()) {
      auto nutrition = consume->Nutrition().get();
      if (nutrition.Name().present()) {
        ev.params.append(asprintf("Name=%s;", nutrition.Name()->c_str()).c_str());
      }
      if (nutrition.Calcium().present()) {
        ev.params.append(asprintf("Calcium=%f,%s;", nutrition.Calcium()->value(), nutrition.Calcium()->unit()->c_str()).c_str());
      }
      if (nutrition.Carbohydrate().present()) {
        ev.params.append(asprintf("Carbohydrate=%f,%s;", nutrition.Carbohydrate()->value(), nutrition.Carbohydrate()->unit()->c_str()).c_str());
      }
      if (nutrition.Fat().present()) {
        ev.params.append(asprintf("Fat=%f,%s;", nutrition.Fat()->value(), nutrition.Fat()->unit()->c_str()).c_str());
      }

      if (nutrition.Protein().present()) {
        ev.params.append(asprintf("Water=%f,%s;", nutrition.Protein()->value(), nutrition.Protein()->unit()->c_str()).c_str());
      }

      if (nutrition.Sodium().present()) {
        ev.params.append(asprintf("Water=%f,%s;", nutrition.Sodium()->value(), nutrition.Sodium()->unit()->c_str()).c_str());
      }
      if (nutrition.Water().present()) {
        ev.params.append(asprintf("Water=%f,%s;", nutrition.Water()->value(), nutrition.Water()->unit()->c_str()).c_str());
      }
    }
    if (consume->NutritionFile().present()) {
      ev.params.append(asprintf("NutritionFile=%s;", consume->NutritionFile()->c_str()).c_str());
    }
    return true;

  } else if (auto exercise = dynamic_cast<const CDM::ExerciseData*>(action)) {
    ev.eType = EventTypes::Exercise;
    ev.typeName = "Exercise";
    ev.description = "Force the patient in to an exercise state";
    ev.params = "";

    if (exercise->GenericExercise().present()) {
      auto& generic = exercise->GenericExercise().get();
      ev.eSubType = EventTypes::GenericExercise;
      ev.typeName = "General Exercise";
      ev.description = "Generic Exercise Action";

      if (generic.DesiredWorkRate().present()) {
        ev.params.append(asprintf("DesiredWorkRate=%f,%s;", generic.DesiredWorkRate()->value(), generic.DesiredWorkRate()->unit()->c_str()).c_str());
      }
      if (generic.Intensity().present()) {
        ev.params.append(asprintf("Intensity=%f,%s;", generic.Intensity()->value(), generic.Intensity()->unit()->c_str()).c_str());
      }
    }
    if (exercise->CyclingExercise().present()) {
      auto& cycling = exercise->CyclingExercise().get();
      ev.eSubType = EventTypes::CyclingExercise;
      ev.typeName = "Cycling Exercise";
      ev.description = "Cycling Exercise Action";

      if (cycling.AddedWeight().present()) {
        ev.params.append(asprintf("AddedWeight=%f,%s;", cycling.AddedWeight()->value(), cycling.AddedWeight()->unit()->c_str()).c_str());
      }
      ev.params.append(asprintf("Power=%f,%s;", cycling.Power().value(), cycling.Power().unit()->c_str()).c_str());
      ev.params.append(asprintf("Cadence=%f,%s;", cycling.Cadence().value(), cycling.Cadence().unit()->c_str()).c_str());
    }
    if (exercise->RunningExercise().present()) {
      auto& running = exercise->RunningExercise().get();
      ev.eSubType = EventTypes::RunningExercise;
      ev.typeName = "Running Exercise";
      ev.description = "Running Exercise Action";

      if (running.AddedWeight().present()) {
        ev.params.append(asprintf("AddedWeight=%f,%s;", running.AddedWeight()->value(), running.AddedWeight()->unit()->c_str()).c_str());
      }
      ev.params.append(asprintf("Power=%f;", running.Incline().value()).c_str());
      ev.params.append(asprintf("Cadence=%f,%s;", running.Speed().value(), running.Speed().unit()->c_str()).c_str());
    }
    if (exercise->StrengthExercise().present()) {
      auto& strength = exercise->StrengthExercise().get();
      ev.eSubType = EventTypes::StengthExercise;
      ev.typeName = "Strength Exercise";
      ev.description = "Strength Exercise Action";

      ev.params.append(asprintf("Repetitions=%f;", strength.Repetitions().value()).c_str());
      ev.params.append(asprintf("Weight=%f,%s;", strength.Weight().value(), strength.Weight().unit()->c_str()).c_str());
    }

    return true;
  } else if (auto hem = dynamic_cast<const CDM::HemorrhageData*>(action)) {
    ev.eType = EventTypes::Hemorrhage;
    ev.typeName = "Hemorrhage";
    ev.description = "Applies a hemorrhage insult to the patient for a given compartment";
    ev.params = "";

    ev.params.append(asprintf("Compartment=%s;", hem->Compartment().c_str()).c_str());
    ev.params.append(asprintf("InitialRate=%f,%s;", hem->InitialRate().value(), hem->InitialRate().unit()->c_str()).c_str());
    return true;
  } else if (auto infect = dynamic_cast<const CDM::InfectionData*>(action)) {
    ev.eType = EventTypes::Infection;
    ev.typeName = "Infection";
    ev.description = "Applies an bacterial infection to the patient";
    ev.params = "";

    switch (infect->Severity()) {
    case CDM::enumInfectionSeverity::Eliminated:
      ev.params.append("Severity=Eliminated;");
      break;
    case CDM::enumInfectionSeverity::Mild:
      ev.params.append("Severity=Mild;");
      break;
    case CDM::enumInfectionSeverity::Moderate:
      ev.params.append("Severity=Moderate;");
      break;
    case CDM::enumInfectionSeverity::Severe:
      ev.params.append("Severity=Severe;");
      break;
    }
    ev.params.append(asprintf("Location=%s;", infect->Location().c_str()).c_str());
    ev.params.append(asprintf("MinimumInhibitoryConcentration=%f;", infect->MinimumInhibitoryConcentration().value()).c_str());

    return true;
  } else if (auto intubation = dynamic_cast<const CDM::IntubationData*>(action)) {
    ev.eType = EventTypes::Intubation;
    ev.typeName = "Intubation";
    ev.description = "Intubate the Patient";
    ev.params = "";

    switch (intubation->Type()) {
    case CDM::enumIntubationType::Off:
      ev.params.append(asprintf("Type=Off;").c_str());
      break;
    case CDM::enumIntubationType::Esophageal:
      ev.params.append(asprintf("Type=Esophageal;").c_str());
      break;
    case CDM::enumIntubationType::LeftMainstem:
      ev.params.append(asprintf("Type=LeftMainstem;").c_str());
      break;
    case CDM::enumIntubationType::RightMainstem:
      ev.params.append(asprintf("Type=RightMainstem;").c_str());
      break;
    case CDM::enumIntubationType::Tracheal:
      ev.params.append(asprintf("Type=Tracheal;").c_str());
      break;
    }
    return true;
  } else if (auto mvData = dynamic_cast<const CDM::MechanicalVentilationData*>(action)) {
    ev.eType = EventTypes::MechanicalVentilation;
    ev.typeName = "Mechanical Ventilation";
    ev.description = "Mechanical Ventilation the patient";
    ev.params = "";

    ev.params.append(asprintf("State=%s;", mvData->State() == CDM::enumSide::Left ? "Left" : "Right").c_str());
    if (mvData->Flow().present()) {
      ev.params.append(asprintf("Flow=%f,%s;", mvData->Flow()->value(), mvData->Flow()->unit()->c_str()).c_str());
    }
    for (auto gas : mvData->GasFraction()) {
      ev.params.append(asprintf("GasFraction=%s,%f;", gas.Name().c_str(), gas.FractionAmount().value()).c_str());
    }
    ev.params.append(asprintf("Pressure=%f,%s;", mvData->Pressure()->value(), mvData->Pressure()->unit()->c_str()).c_str());

    return true;
  } else if (auto needleDecomp = dynamic_cast<const CDM::NeedleDecompressionData*>(action)) {
    ev.eType = EventTypes::NeedleDecompression;
    ev.typeName = "Needle Decompression";
    ev.description = "Applies a needle decompression";
    ev.params = "";

    ev.params.append(asprintf("Side=%s;", needleDecomp->Side() == CDM::enumSide::Left ? "Left" : "Right").c_str());
    ev.params.append(asprintf("State=%s;", needleDecomp->State() == CDM::enumOnOff::On ? "On" : "Off").c_str());
    return true;
  } else if (auto pain = dynamic_cast<const CDM::PainStimulusData*>(action)) {
    ev.eType = EventTypes::PainStimulus;
    ev.typeName = "Pain Stimulus";
    ev.description = "Applies pain stimulus to a compartment";
    ev.params = "";

    ev.params.append(asprintf("Severity=%f;", pain->Severity().value()).c_str());
    if (pain->HalfLife().present()) {
      ev.params.append(asprintf("HalfLife=%f,%s;", pain->HalfLife()->value(), pain->HalfLife()->unit()->c_str()).c_str());
    }
    ev.params.append(asprintf("Location=%s", pain->Location().c_str()).c_str());

    return true;
  } else if (auto pericardialEff = dynamic_cast<const CDM::PericardialEffusionData*>(action)) {
    ev.eType = EventTypes::PericardialEffusion;
    ev.typeName = "Pericardial Effusion";
    ev.description = "Pericardial Effusion Insult";
    ev.params = "";

    ev.params.append(asprintf("EffusionRate=%f,%s", pericardialEff->EffusionRate().value(), pericardialEff->EffusionRate().unit()->c_str()).c_str());
    return true;
  } else if (auto admin = dynamic_cast<const CDM::SubstanceAdministrationData*>(action)) {
    ev.eType = EventTypes::SubstanceAdministration;
    ev.typeName = "Substance Administration";
    ev.description = "Apply a substance to the patient";
    ev.params = "";

    if (auto bolusData = dynamic_cast<const CDM::SubstanceBolusData*>(admin)) {
      ev.eType = EventTypes::SubstanceBolus;
      ev.typeName = "Substance Administration by Bolus";
      ev.description = "Apply a substance bolus to the patient";
      ev.params = "";

      switch (bolusData->AdminRoute()) {
      case CDM::enumBolusAdministration::Intraarterial:
        ev.params.append(asprintf("AdminRoute=Intraarterial;").c_str());
        break;
      case CDM::enumBolusAdministration::Intravenous:
        ev.params.append(asprintf("AdminRoute=Intravenous;").c_str());
        break;
      case CDM::enumBolusAdministration::Intramuscular:
        ev.params.append(asprintf("AdminRoute=Intramuscular;").c_str());
        break;
      default:
        ev.params.append(asprintf("AdminRoute=Unknown;").c_str());
        break;
      }
      ev.params.append(asprintf("Dose=%f,%s;", bolusData->Dose().value(), bolusData->Dose().unit()->c_str()).c_str());
      ev.params.append(asprintf("AdminTime=%f,%s;", bolusData->AdminTime()->value(), bolusData->AdminTime()->unit()->c_str()).c_str());
      ev.params.append(asprintf("AdminRoute=%s;", bolusData->AdminRoute() == CDM::enumOralAdministration::Gastrointestinal ? "Gastrointestinal" : "Transmucosal").c_str());
      ev.params.append(asprintf("Substance=%s;", bolusData->Substance().c_str()).c_str());
      return true;
    }
    if (auto oralData = dynamic_cast<const CDM::SubstanceOralDoseData*>(admin)) {
      ev.eType = EventTypes::SubstanceAdministration;
      ev.eSubType = EventTypes::SubstanceOralDose;
      ev.typeName = "Substance Administration by Oral Dose";
      ev.description = "Apply an oral dose of a substance to the patient";
      ev.params = "";

      ev.params.append(asprintf("Concentration=%f,%s;", oralData->Dose().value(), oralData->Dose().unit()->c_str()).c_str());
      ev.params.append(asprintf("AdminRoute=%s;", oralData->AdminRoute() == CDM::enumOralAdministration::Gastrointestinal ? "Gastrointestinal" : "Transmucosal").c_str());
      ev.params.append(asprintf("Substance=%s;", oralData->Substance().c_str()).c_str());
      return true;
    }
    if (auto subInfuzData = dynamic_cast<const CDM::SubstanceInfusionData*>(admin)) {
      ev.eType = EventTypes::SubstanceAdministration;
      ev.eSubType = EventTypes::SubstanceInfusion;
      ev.typeName = "Substance Administration by Infusion";
      ev.description = "Apply a substance infusion to the patient";
      ev.params = "";

      ev.params.append(asprintf("Concentration=%f,%s;", subInfuzData->Concentration().value(), subInfuzData->Concentration().unit()->c_str()).c_str());
      ev.params.append(asprintf("Rate=%f,%s;", subInfuzData->Rate().value(), subInfuzData->Rate().unit()->c_str()).c_str());
      ev.params.append(asprintf("Substance=%s;", subInfuzData->Substance().c_str()).c_str());
      return true;
    }
    if (auto subCInfuzData = dynamic_cast<const CDM::SubstanceCompoundInfusionData*>(admin)) {
      ev.eType = EventTypes::SubstanceAdministration;
      ev.eSubType = EventTypes::SubstanceCompoundInfusion;
      ev.typeName = "Substance Compound Administration by Infusion";
      ev.description = "Apply a substance compound infusion to the patient";
      ev.params = "";

      ev.params.append(asprintf("BagVolume=%f,%s;", subCInfuzData->BagVolume().value(), subCInfuzData->BagVolume().unit()->c_str()).c_str());
      ev.params.append(asprintf("Rate=%f,%s;", subCInfuzData->Rate().value(), subCInfuzData->BagVolume().unit()->c_str()).c_str());
      ev.params.append(asprintf("SubstanceCompound=%s;", subCInfuzData->SubstanceCompound().c_str()).c_str());
      return true;
    }

    return false;
  } else if (auto pneumo = dynamic_cast<const CDM::TensionPneumothoraxData*>(action)) {
    ev.eType = EventTypes::TensionPneumothorax;
    ev.typeName = "Tension Pneumothorax";
    ev.description = "Application of a Tension Pneumothorax insult";
    ev.params = "";

    ev.params.append(asprintf("Type=%s;", (pneumo->Type() == CDM::enumPneumothoraxType::Open) ? "Open" : "Closed").c_str());
    ev.params.append(asprintf("Severity=%f;", pneumo->Severity().value()).c_str());
    ev.params.append(asprintf("Side=%s;", (pneumo->Side() == CDM::enumSide::Left) ? "Left" : "Right").c_str());

    return true;
  } else if (auto tournData = dynamic_cast<const CDM::TourniquetData*>(action)) {
    ev.eType = EventTypes::Tourniquet;
    ev.typeName = "Tourniquet";
    ev.description = "Tourniquet application to a compartment";
    ev.params = "";

    ev.params.append(asprintf("", tournData->Compartment().c_str()).c_str());

    switch (tournData->TourniquetLevel()) {
    case CDM::enumTourniquetApplicationLevel::Applied:
      ev.params.append(asprintf("TourniquetLevel=%s;", "Applied").c_str());
      break;
    case CDM::enumTourniquetApplicationLevel::Misapplied:
      ev.params.append(asprintf("TourniquetLevel=%s;", "Misapplied").c_str());
      break;
    case CDM::enumTourniquetApplicationLevel::None:
      ev.params.append(asprintf("TourniquetLevel=%s;", "None").c_str());
      break;
    }
    return true;
  } else if (auto urinate = dynamic_cast<const CDM::UrinateData*>(action)) {
    ev.eType = EventTypes::Urinate;
    ev.typeName = "Force Urination";
    ev.description = "Causes patient to to empty bladder";
    ev.params = "";
    return true;
  } else if (auto orData = dynamic_cast<const CDM::OverrideData*>(action)) {
    ev.eType = EventTypes::Override;
    ev.typeName = "Value Override";
    ev.description = "Configure the current value override values";
    ev.params = "";

    //TODO: Implement OverrideData
    return true;
  } else if (auto assessment = dynamic_cast<const CDM::PatientAssessmentRequestData*>(action)) {
    ev.eType = EventTypes::PatientAssessmentRequest;
    ev.typeName = "Patient Assessment";
    ev.description = "Perform a Patient Assessment";
    ev.params = "";

    switch (assessment->Type()) {
    case CDM::enumPatientAssessment::CompleteBloodCount:
      ev.params.append(asprintf("Type=CompleteBloodCount").c_str());
      break;
    case CDM::enumPatientAssessment::ComprehensiveMetabolicPanel:
      ev.params.append(asprintf("Type=ComprehensiveMetabolicPanel").c_str());
      break;
    case CDM::enumPatientAssessment::PulmonaryFunctionTest:
      ev.params.append(asprintf("Type=PulmonaryFunctionTest").c_str());
      break;
    case CDM::enumPatientAssessment::SequentialOrganFailureAssessment:
      ev.params.append(asprintf("Type=SequentialOrganFailureAssessment").c_str());
      break;
    case CDM::enumPatientAssessment::Urinalysis:
      ev.params.append(asprintf("Type=Urinalysis").c_str());
      break;
    }

    //TODO: Implement OverrideData
    return true;
  }
  return false;
}
//-----------------------------------------------------------------------------
bool EventTree::process_action(Event& ev, CDM::EnvironmentActionData* action)
{
  using namespace biogears;
  ev.eType = EventTypes::EnvironmentAction;
  ev.typeName = "Environment Action";
  if (auto change = dynamic_cast<const CDM::EnvironmentChangeData*>(action)) {
    ev.eType = EventTypes::EnvironmentChange;
    ev.typeName = "EnvironmentChange";
    ev.description = "Modify the current environment";
    ev.params = "";
    if (change->ConditionsFile().present()) {
      ev.params += asprintf("conditionFile=%s;", change->ConditionsFile()->c_str()).c_str();
    }
    if (change->Conditions().present()) {
      auto conditions = change->Conditions();
      if (conditions->Name().present()) {
        ev.params += asprintf("Conditions-Name=%s;", conditions->Name()->c_str()).c_str();
      }
      if (conditions->SurroundingType().present()) {
        ev.params += asprintf("Conditions-SurroundingType=%s;", (conditions->SurroundingType().get() == CDM::enumSurroundingType::Air) ? "Air" : "Water").c_str();
      }
      if (conditions->AirDensity().present()) {
        auto airDensity = conditions->AirDensity().get();
        ev.params += asprintf("Conditions-AirDensity=%f,%s;", airDensity.value(), airDensity.unit()->c_str()).c_str();
      }
      if (conditions->AirVelocity().present()) {
        auto velocity = conditions->AirVelocity().get();
        ev.params += asprintf("Conditions-AirDensity=%f,%s;", velocity.value(), velocity.unit()->c_str()).c_str();
      }
      if (conditions->AmbientTemperature().present()) {
        auto ambientTemp = conditions->AmbientTemperature().get();
        ev.params += asprintf("Conditions-AirDensity=%f,%s;", ambientTemp.value(), ambientTemp.unit()->c_str()).c_str();
      }
      if (conditions->AtmosphericPressure().present()) {
        auto ap = conditions->AtmosphericPressure().get();
        ev.params += asprintf("Conditions-AirDensity=%f,%s;", ap.value(), ap.unit()->c_str()).c_str();
      }
      if (conditions->ClothingResistance().present()) {
        auto cr = conditions->ClothingResistance().get();
        ev.params += asprintf("Conditions-ClothingResistance=%f,%s;", cr.value(), cr.unit()->c_str()).c_str();
      }
      if (conditions->Emissivity().present()) {
        auto em = conditions->Emissivity().get();
        ev.params += asprintf("Conditions-Emissivity=%f,%s;", em.value(), em.unit()->c_str()).c_str();
      }
      if (conditions->MeanRadiantTemperature().present()) {
        auto mrt = conditions->MeanRadiantTemperature().get();
        ev.params += asprintf("Conditions-MeanRadiantTemperature=%f,%s;", mrt.value(), mrt.unit()->c_str()).c_str();
      }
      if (conditions->RelativeHumidity().present()) {
        auto rh = conditions->RelativeHumidity().get();
        ev.params += asprintf("Conditions-RelativeHumidity=%f,%s;", rh.value(), rh.unit()->c_str()).c_str();
      }
      if (conditions->RespirationAmbientTemperature().present()) {
        auto rat = conditions->RelativeHumidity().get();
        ev.params += asprintf("Conditions-RespirationAmbientTemperature=%f,%s;", rat.value(), rat.unit()->c_str()).c_str();
      }
      for (auto& gas : conditions->AmbientGas()) {
        ev.params += asprintf("ConfigurationFile-AmbientGas=%s,%f;", gas.Name().c_str(), gas.FractionAmount().value()).c_str();
      }
      for (auto& aerosol : conditions->AmbientAerosol()) {
        ev.params += asprintf("ConfigurationFile-AmbientGas=%s,%f,%u;", aerosol.Name().c_str(), aerosol.Concentration().value(), aerosol.Concentration().unit()->c_str()).c_str();
      }
    }
    return true;
  } else if (auto thermal = dynamic_cast<const CDM::ThermalApplicationData*>(action)) {
    ev.eType = EventTypes::ThermalApplication;
    ev.typeName = "Thermal Application";
    ev.description = "Apply active heating/cooling";
    ev.params = "";
    if (thermal->ActiveCooling().present()) {
      auto ac = thermal->ActiveCooling().get();
      ev.params.append(asprintf("ActiveCooling-Power=%f,%s", ac.Power().value(), ac.Power().unit()->c_str()).c_str());

      if (ac.SurfaceArea().present()) {
        ev.params.append(asprintf("ActiveCooling-SurfaceArea=%f,%s", ac.SurfaceArea()->value(), ac.SurfaceArea()->unit()->c_str()).c_str());
      }
      if (ac.SurfaceAreaFraction().present()) {
        ev.params.append(asprintf("ActiveCooling-SurfaceAreaFraction=%f", ac.SurfaceAreaFraction()->value()).c_str());
      }
    }
    if (thermal->ActiveHeating().present()) {
      auto ah = thermal->ActiveHeating().get();
      ev.params.append(asprintf("ActiveHeating-Power=%f,%s", ah.Power().value(), ah.Power().unit()->c_str()).c_str());

      if (ah.SurfaceArea().present()) {
        ev.params.append(asprintf("ActiveHeating-SurfaceArea=%f,%s", ah.SurfaceArea()->value(), ah.SurfaceArea()->unit()->c_str()).c_str());
      }
      if (ah.SurfaceAreaFraction().present()) {
        ev.params.append(asprintf("ActiveHeating-SurfaceAreaFraction=%f", ah.SurfaceAreaFraction()->value()).c_str());
      }
    }
    if (thermal->AppliedTemperature().present()) {
      auto at = thermal->AppliedTemperature().get();
      if (at.Temperature().present()) {
        ev.params.append(asprintf("AppliedTemperature-Temperature=%f,%s", at.Temperature()->value(), at.Temperature()->unit()->c_str()).c_str());
      }
      if (at.State().present()) {
        ev.params.append(asprintf("AppliedTemperature-State=%s", at.State().get() == CDM::enumOnOff::On ? "On" : "Off").c_str());
      }
      if (at.SurfaceAreaFraction().present()) {
        ev.params.append(asprintf("AppliedTemperature-SurfaceAreaFraction=%f", at.SurfaceAreaFraction()->value()).c_str());
      }
      if (at.SurfaceArea().present()) {
        ev.params.append(asprintf("AppliedTemperature-SurfaceArea=%f,%s", at.SurfaceAreaFraction()->value(), at.SurfaceAreaFraction()->unit()->c_str()).c_str());
      }
    }
    if (thermal->AppendToPrevious()) {
      ev.params.append(asprintf("AppendToPrevious=%s", thermal->AppendToPrevious() ? "True" : "False").c_str());
    }
    return true;
  }

  return false;
}
//-----------------------------------------------------------------------------
bool EventTree::process_action(Event& ev, CDM::AnesthesiaMachineActionData* action)
{
  using namespace biogears;

  ev.eType = EventTypes::AnesthesiaMachineAction;
  ev.typeName = "Anesthesia Machine Action";
  if (auto anConfig = dynamic_cast<CDM::AnesthesiaMachineConfigurationData*>(action)) {
    ev.eType = EventTypes::AnesthesiaMachineConfiguration;
    ev.typeName = "Anesthesia Machine Configuration";
    ev.description = "Change the configuration of a Anesthesia Machine";
    ev.params = "";
    if (anConfig->ConfigurationFile().present()) {
      ev.params = asprintf("ConfigurationFile=%s;", anConfig->ConfigurationFile().get().c_str()).c_str();
    }
    if (anConfig->Configuration().present()) {
      auto config = anConfig->Configuration().get();
      if (config.Connection().present()) {
        switch (config.Connection().get()) {
        case CDM::enumAnesthesiaMachineConnection::Mask:
          ev.params += asprintf("Connection=%s;", "Mask;").c_str();
          break;
        case CDM::enumAnesthesiaMachineConnection::Off:
          ev.params += asprintf("Connection=%s;", "Off;").c_str();
          break;
        case CDM::enumAnesthesiaMachineConnection::Tube:
          ev.params += asprintf("Connection=%s;", "Tube;").c_str();
          break;
        default:
          ev.params += asprintf("Connection=%s;", "Off;").c_str();
          break;
        }
      }
      if (config.InletFlow().present()) {
        auto inletFlow = config.InletFlow().get();
        ev.params += asprintf("InletFlow=%f,%s;", inletFlow.value(), inletFlow.unit()->c_str()).c_str();
      }
      if (config.InspiratoryExpiratoryRatio().present()) {
        auto ratio = config.InspiratoryExpiratoryRatio().get();
        ev.params += asprintf("InspiratoryExpiratoryRatio=%f,%s;", ratio.value(), ratio.unit()->c_str()).c_str();
      }
      if (config.OxygenFraction().present()) {
        auto oxygenFraction = config.OxygenFraction().get();
        ev.params += asprintf("OxygenFraction=%f,%s;", oxygenFraction.value(), oxygenFraction.unit()->c_str()).c_str();
      }
      if (config.OxygenSource().present()) {
        switch (config.OxygenSource().get()) {
        case CDM::enumAnesthesiaMachineOxygenSource::BottleOne:
          ev.params += asprintf("OxygenSource=%s;", "BottleOne").c_str();
          break;
        case CDM::enumAnesthesiaMachineOxygenSource::BottleTwo:
          ev.params += asprintf("OxygenSource=%s;", "BottleTwo").c_str();
          break;
        case CDM::enumAnesthesiaMachineOxygenSource::Wall:
          ev.params += asprintf("OxygenSource=%s;", "Wall").c_str();
          break;
        }
      }
      if (config.PositiveEndExpiredPressure().present()) {
        auto positiveEndExpiredPressure = config.PositiveEndExpiredPressure().get();
        ev.params += asprintf("PositiveEndExpiredPressure=%f,%s;", positiveEndExpiredPressure.value(), positiveEndExpiredPressure.unit()->c_str()).c_str();
      }
      if (config.PrimaryGas().present()) {
        auto primaryGas = config.PrimaryGas().get();
        ev.params += asprintf("PositiveEndExpiredPressure=%s;", primaryGas.c_str()).c_str();
      }
      if (config.ReliefValvePressure().present()) {
        auto reliefValvePressure = config.ReliefValvePressure().get();
        ev.params += asprintf("PositiveEndExpiredPressure=%f,%s;", reliefValvePressure.value(), reliefValvePressure.unit()->c_str()).c_str();
      }
      if (config.RespiratoryRate().present()) {
        auto respiratoryRate = config.RespiratoryRate().get();
        ev.params += asprintf("PositiveEndExpiredPressure=%f,%s;", respiratoryRate.value(), respiratoryRate.unit()->c_str()).c_str();
      }
      if (config.VentilatorPressure().present()) {
        auto respiratoryRate = config.VentilatorPressure().get();
        ev.params += asprintf("PositiveEndExpiredPressure=%f,%s;", respiratoryRate.value(), respiratoryRate.unit()->c_str()).c_str();
      }
      if (config.LeftChamber().present()) {
        auto leftChamber = config.LeftChamber().get();
        if (leftChamber.Substance().present()) {
          ev.params += asprintf("LeftChamber-Substance=%s;", leftChamber.Substance()->c_str()).c_str();
        }
        if (leftChamber.State().present()) {
          ev.params += asprintf("LeftChamber-State=%s;", (leftChamber.State().get() == CDM::enumOnOff::On) ? "On" : "Off").c_str();
        }
        if (leftChamber.SubstanceFraction().present()) {
          ev.params += asprintf("LeftChamber-SubstanceFraction=%f;", leftChamber.SubstanceFraction()->value()).c_str();
        }
      }
      if (config.RightChamber().present()) {
        auto rightChamber = config.RightChamber().get();
        if (rightChamber.Substance().present()) {
          ev.params += asprintf("RightChamber-Substance=%s;", rightChamber.Substance()->c_str()).c_str();
        }
        if (rightChamber.State().present()) {
          ev.params += asprintf("RightChamber-State=%s;", (rightChamber.State().get() == CDM::enumOnOff::On) ? "On" : "Off").c_str();
        }
        if (rightChamber.SubstanceFraction().present()) {
          ev.params += asprintf("RightChamber-SubstanceFraction=%f;", rightChamber.SubstanceFraction()->value()).c_str();
        }
      }
      if (config.OxygenBottleOne().present() && config.OxygenBottleOne()->Volume().present()) {
        auto oxygenBottle = config.OxygenBottleOne()->Volume().get();
        ev.params += asprintf("OxygenBottleOne-Volume=%f,%s;", oxygenBottle.value(), oxygenBottle.unit()->c_str()).c_str();
      }
      if (config.OxygenBottleTwo().present() && config.OxygenBottleTwo().get().Volume().present()) {
        auto oxygenBottle = config.OxygenBottleTwo()->Volume().get();
        ev.params += asprintf("OxygenBottleOne-Volume=%f,%s;", oxygenBottle.value(), oxygenBottle.unit()->c_str()).c_str();
      }
      for (auto& event : config.ActiveEvent()) {
        switch (event.Event()) {
        case CDM::enumAnesthesiaMachineEvent::OxygenBottle1Exhausted:
          ev.params += asprintf("ActiveEvent=%s;", "OxygenBottle1Exhausted").c_str();
          break;
        case CDM::enumAnesthesiaMachineEvent::OxygenBottle2Exhausted:
          ev.params += asprintf("ActiveEvent=%s;", "OxygenBottle2Exhausted").c_str();
          break;
        case CDM::enumAnesthesiaMachineEvent::ReliefValveActive:
          ev.params += asprintf("ActiveEvent=%s;", "ReliefValveActive").c_str();
          break;
        }
      }
    }
    return true;
  } else if (auto anO2WallLoss = dynamic_cast<CDM::OxygenWallPortPressureLossData*>(action)) {
    ev.eType = EventTypes::OxygenWallPortPressureLoss;
    ev.typeName = "Oxygen Wall Port Pressure Loss";
    ev.description = "Modify the value of any pressure loss between the anesthesia machine and the wall connection";
    ev.params = asprintf("State=%s;", (anO2WallLoss->State() == CDM::enumOnOff::On ? "On" : "Off")).c_str();
    return true;
  } else if (auto anO2TankLoss = dynamic_cast<CDM::OxygenTankPressureLossData*>(action)) {
    ev.eType = EventTypes::OxygenTankPressureLoss;
    ev.typeName = "Oxygen tank pressure loss";
    ev.description = "Modify the value of any pressure loss between the anesthesia machine and the oxygen tank";
    ev.params = asprintf("State=%s;", (anO2TankLoss->State() == CDM::enumOnOff::On ? "On" : "Off")).c_str();
    return true;
  } else if (auto anExLeak = dynamic_cast<CDM::ExpiratoryValveLeakData*>(action)) {
    ev.eType = EventTypes::ExpiratoryValveLeak;
    ev.typeName = "Expiratory valve leak";
    ev.description = "Modify the value of any pressure loss between the anesthesia machine and the expiratory valve";
    ev.params = asprintf("Severity=%f,%s;", anExLeak->Severity().value(), anExLeak->Severity().unit()->c_str()).c_str();
    return true;
  } else if (auto anExObs = dynamic_cast<CDM::ExpiratoryValveObstructionData*>(action)) {
    ev.eType = EventTypes::ExpiratoryValveObstruction;
    ev.typeName = "Expiratory valve obstruction";
    ev.description = "Modify the value of any obstruction in the expiratory valve";
    ev.params = asprintf("Severity=%f,%s;", anExObs->Severity().value(), anExObs->Severity().unit()->c_str()).c_str();
    return true;
  } else if (auto anInLeak = dynamic_cast<CDM::InspiratoryValveLeakData*>(action)) {
    ev.eType = EventTypes::InspiratoryValveLeak;
    ev.typeName = "Inspiratory valve pressure loss";
    ev.description = "Modify the value of any pressure loss between the anesthesia machine and inspiratory valve";
    ev.params = asprintf("Severity=%f,%s;", anInLeak->Severity().value(), anInLeak->Severity().unit()->c_str()).c_str();
    return true;
  } else if (auto anInObs = dynamic_cast<CDM::InspiratoryValveObstructionData*>(action)) {
    ev.eType = EventTypes::InspiratoryValveObstruction;
    ev.typeName = "Inspiratory valve obstruction";
    ev.description = "Modify the value of any obstruction in the inspiratory valve";
    ev.params = asprintf("Severity=%f,%s;", anInObs->Severity().value(), anInObs->Severity().unit()->c_str()).c_str();
    return true;
  } else if (auto anMskLeak = dynamic_cast<CDM::MaskLeakData*>(action)) {
    ev.eType = EventTypes::MaskLeak;
    ev.typeName = "Leak in the Mask Seal";
    ev.description = "Modify the severity and occurence of a mask seal ";
    ev.params = asprintf("Severity=%f,%s;", anMskLeak->Severity().value(), anMskLeak->Severity().unit()->c_str()).c_str();
    return true;
  } else if (auto anSodaFail = dynamic_cast<CDM::SodaLimeFailureData*>(action)) {
    ev.eType = EventTypes::SodaLimeFailure;
    ev.typeName = "A failure in the Soda Lime";
    ev.description = "Modifies the delivery of f NaOH & CaO chemicals";
    ev.params = asprintf("Severity=%f,%s;", anSodaFail->Severity().value(), anSodaFail->Severity().unit()->c_str()).c_str();
    return true;
  } else if (auto anTubLeak = dynamic_cast<CDM::TubeCuffLeakData*>(action)) {
    ev.eType = EventTypes::TubeCuffLeak;
    ev.typeName = "Leak in the tube cuff";
    ev.description = "Modify the occurence and severity of the tub cuff";
    ev.params = asprintf("Severity=%f,%s;", anTubLeak->Severity().value(), anTubLeak->Severity().unit()->c_str()).c_str();
    return true;
  } else if (auto anVapFail = dynamic_cast<CDM::VaporizerFailureData*>(action)) {
    ev.eType = EventTypes::VaporizerFailure;
    ev.typeName = "A failure of the vaporizer";
    ev.description = "Modifies the delivery of f NaOH & CaO chemicals";
    ev.params = asprintf("Severity=%f,%s;", anVapFail->Severity().value(), anVapFail->Severity().unit()->c_str()).c_str();
    return true;
  } else if (auto anVentLoss = dynamic_cast<CDM::VentilatorPressureLossData*>(action)) {
    ev.eType = EventTypes::VentilatorPressureLoss;
    ev.typeName = "Loss of ventilator pressure";
    ev.description = "Modify the severity of a loss in ventilator pressure";
    ev.params = asprintf("Severity=%f,%s;", anVentLoss->Severity().value(), anVentLoss->Severity().unit()->c_str()).c_str();
    return true;
  } else if (auto anYDisc = dynamic_cast<CDM::YPieceDisconnectData*>(action)) {
    ev.eType = EventTypes::YPieceDisconnect;
    ev.typeName = "Disconnection of the Y piece";
    ev.description = "Modifies the occurence of a Y piece disconnection";
    ev.params = asprintf("Severity=%f,%s;", anYDisc->Severity().value(), anYDisc->Severity().unit()->c_str()).c_str();
    return true;
  }

  return false;
}
//-----------------------------------------------------------------------------
bool EventTree::process_action(Event& ev, CDM::InhalerActionData* action)
{
  using namespace biogears;
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
        ev.params = asprintf("MeteredDose=%f,%s;", md.value(), md.unit()->c_str()).c_str();
      }
      if (config.NozzleLoss().present()) {
        auto nl = config.NozzleLoss().get();
        ev.params = asprintf("NozzleLoss=%f;", nl.value()).c_str();
      }
      if (config.SpacerVolume().present()) {
        auto sv = config.SpacerVolume().get();
        ev.params = asprintf("SpacerVolume=%f,%s;", sv.value(), sv.unit()->c_str()).c_str();
      }
      if (config.State().present()) {
        ev.params = asprintf("State=%s;", ((config.State().get() == CDM::enumOnOff::On) ? "On" : "Off")).c_str();
      }
      if (config.Substance().present()) {
        ev.params = asprintf("Substance=%s;", config.Substance().get().c_str()).c_str();
      }
    }
    return true;
  }
  return false;
  ;
}
//-----------------------------------------------------------------------------
bool EventTree::process_action(Event& ev, CDM::AdvanceTimeData* action)
{
  using namespace biogears;

  ev.eType = EventTypes::AdvanceTime;
  ev.typeName = "Time Advancement";
  ev.description = "Advances the time of the simulation by the given duration";
  ev.params = asprintf("Time=%f,%s", action->Time().value(), action->Time().unit()->c_str()).c_str();

  return true;
}
//-----------------------------------------------------------------------------
bool EventTree::process_action(Event& ev, CDM::SerializeStateData* action)
{
  using namespace biogears;

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
void EventTree::add_event(Event ev)
{
  _events.push_back(ev);
}
//-----------------------------------------------------------------------------
void EventTree::add_event(QString name, int type, int subType, QString params, double startTime_s, double duration_s)
{
  Event ev;
  ev.typeName = name;
  ev.eType = (EventTypes)type;
  ev.eSubType = (EventTypes)subType;
  ev.params = params;
  ev.startTime = startTime_s;
  ev.duration = duration_s;
  add_event(ev);
  //Handle "off" action
  if (duration_s > 0.0) {
    Event offEvent;
    QString offParams = params;
    int startLoc;
    int endLoc;
    //Most actions are severity based -- set severity to 0 to turn off
    if (offParams.contains("Severity")) {
      startLoc = params.indexOf("Severity");
      endLoc = params.indexOf(";", startLoc);
      offParams.replace(startLoc, endLoc - startLoc, "Severity:0");
    } else if (offParams.contains("Rate")) {
      //Actions like hemorrhage and drug infusion are deactivated by setting a rate to 0
      startLoc = params.indexOf("Rate");
      endLoc = params.indexOf(",", startLoc); //Replace up to unit (demarcated by , )
      offParams.replace(startLoc, endLoc - startLoc, "Rate:0");
    } else if (name.contains("Exercise")) {
      //Exercise is the oddball and there are about a zillion ways to deactivate it depending on the type
      if (offParams.contains("Intensity")) {
        //Generic-Intensity based
        startLoc = params.indexOf("Intensity");
        endLoc = params.indexOf(";", startLoc);
        offParams.replace(startLoc, endLoc - startLoc, "Intensity:0");
      } else if (offParams.contains("DesiredWorkRate")) {
        //Generic-Work rate based
        startLoc = params.indexOf("DesiredWorkRate");
        endLoc = params.indexOf(",", startLoc);
        offParams.replace(startLoc, endLoc - startLoc, "DesiredWorkRate:0");
      } else if (offParams.contains("Cadence")) {
        //Cycling
        startLoc = params.indexOf("Cadence");
        endLoc = params.indexOf(",", startLoc);
        offParams.replace(startLoc, endLoc - startLoc, "Cadence:0");
        startLoc = params.indexOf("Power");
        endLoc = params.indexOf(",", startLoc);
        offParams.replace(startLoc, endLoc - startLoc, "Power:0");
      } else if (offParams.contains("Speed")) {
        //Running
        startLoc = params.indexOf("Speed");
        endLoc = params.indexOf(",", startLoc);
        offParams.replace(startLoc, endLoc - startLoc, "Speed:0");
      }
    } else if (params.contains("On")) {
      //Action with on/off (Cardiac Arrest, Anesthesia Machine Connection)
      startLoc = params.indexOf("On");
      endLoc = params.indexOf(";", startLoc);
      QString replaced = offParams.replace(startLoc, endLoc - startLoc, "Off");
    } 
    offEvent.typeName = name;
    offEvent.eType = type;
    offEvent.eSubType = subType;
    offEvent.params = offParams;
    offEvent.startTime = startTime_s + duration_s;
    offEvent.duration = 0.0;
    _events.push_back(offEvent);
  }
}
//-----------------------------------------------------------------------------
void EventTree::sort_events()
{
  //Implementing a fairly naive insertion sort.  The event list comring from scenario builder is mostly ordered (only "deactivate" actions
  // are potentially out of order), so I don't think we'll hit the worst case number of comparisons.  Plus the list probably isn't going to be too long.
  for (unsigned int i = 1; i < _events.size(); ++i) {
    Event tempEvent = _events[i];
    int compIndex = i - 1;
    while (compIndex > -1 && _events[i].startTime < _events[compIndex].startTime) {
      _events[compIndex + 1] = _events[compIndex];
      --compIndex;
    }
    _events[compIndex + 1] = tempEvent;
  }
}
//-----------------------------------------------------------------------------
biogears::SEAction* EventTree::decode_action(Event& ev, biogears::SESubstanceManager& subMgr)
{
  biogears::SEAction* action = nullptr;
  
  switch (ev.eType) {
  case EventTypes::AdvanceTime:
    action = decode_advance_time(ev);
    break;
  case EventTypes::AcuteRespiratoryDistress:
    action = decode_acute_respiratory_distress(ev);
    break;
  case EventTypes::AcuteStress:
    action = decode_acute_stress(ev);
    break;
  case EventTypes::AirwayObstruction:
    action = decode_airway_obstruction(ev);
    break;
  case EventTypes::AnesthesiaMachineConfiguration:
    action = decode_anesthesia_machine_configuration(ev, subMgr);
    break;
  case EventTypes::Apnea:
    action = decode_apnea(ev);
    break;
  case EventTypes::AsthmaAttack:
    action = decode_asthma_attack(ev);
    break;
  case EventTypes::Bronchoconstriction:
    action = decode_bronchoconstriction(ev);
    break;
  case EventTypes::BurnWound:
    action = decode_burn_wound(ev);
    break;
  case EventTypes::CardiacArrest:
    action = decode_cardiac_arrest(ev);
    break;
  case EventTypes::ConsumeNutrients:
    action = decode_consume_nutrients(ev);
    break;
  case EventTypes::SubstanceAdministration:
    action = decode_substance_administration(ev, subMgr);
    break;
  case EventTypes::Exercise:
    action = decode_exercise(ev);
    break;
  case EventTypes::Hemorrhage:
    action = decode_hemorrhage(ev);
    break;
  case EventTypes::Infection:
    action = decode_infection(ev);
    break;
  case EventTypes::NeedleDecompression:
    action = decode_needle_decompression(ev);
    break;
  case EventTypes::PainStimulus:
    action = decode_pain_stimulus(ev);
    break;
  case EventTypes::TensionPneumothorax:
    action = decode_tension_pneumothorax(ev);
    break;
  case EventTypes::Tourniquet:
    action = decode_tourniquet(ev);
    break;
  case EventTypes::BrainInjury:
    action = decode_traumatic_brain_injury(ev);
    break;
  }


  return action;
}
//-----------------------------------------------------------------------------
//Decode actions used to write scenario data from qml to SEAction types for write to Scenario xml file
//-----------------------------------------------------------------------------
biogears::SEAdvanceTime* EventTree::decode_advance_time(Event& ev)
{
  biogears::SEAdvanceTime* action = new biogears::SEAdvanceTime();
  //Hanlding AdvanceTime differently from others:  All we need is length of time, so just use duration_s field of Event struct
  action->GetTime().SetValue(ev.duration, biogears::TimeUnit::s);
  return action;
}
biogears::SEAcuteRespiratoryDistress* EventTree::decode_acute_respiratory_distress(Event& ev)
{
  biogears::SEAcuteRespiratoryDistress* action = new biogears::SEAcuteRespiratoryDistress();
  //Only one arg (severity), split at ":" --> e.g. severity:0.5
  double input = std::stod(biogears::split(ev.params.toStdString(), ':')[1]);
  action->GetSeverity().SetValue(input);
  return action;
}
//-----------------------------------------------------------------------------
biogears::SEAcuteStress* EventTree::decode_acute_stress(Event& ev)
{
  biogears::SEAcuteStress* action = new biogears::SEAcuteStress();
  //Only one arg (severity), split at ":" --> e.g. severity:0.5
  double input = std::stod(biogears::split(ev.params.toStdString(), ':')[1]);
  action->GetSeverity().SetValue(input);
  return action;
}
//-----------------------------------------------------------------------------
biogears::SEAirwayObstruction* EventTree::decode_airway_obstruction(Event& ev)
{
  biogears::SEAirwayObstruction* action = new biogears::SEAirwayObstruction();
  //Only one arg (severity), split at ":" --> e.g. severity:0.5
  double input = std::stod(biogears::split(ev.params.toStdString(), ':')[1]);
  action->GetSeverity().SetValue(input);
  return action;
}
//-----------------------------------------------------------------------------
biogears::SEAnesthesiaMachineConfiguration* EventTree::decode_anesthesia_machine_configuration(Event& ev, biogears::SESubstanceManager& subMgr)
{
  biogears::SEAnesthesiaMachineConfiguration* action = new biogears::SEAnesthesiaMachineConfiguration(subMgr);
  auto& config = action->GetConfiguration();
  //Split parameter string so that every parameter has individual entry, e.g. ["Connection:Mask", "OxygenSource:Wall", ...]
  std::vector<std::string> inputs = biogears::split(ev.params.toStdString(), ';');
  //Re-usable variables
  std::vector<std::string> nameSplit;
  std::vector<std::string> valueUnitPair;
  std::string value;
  //For substance fractions, we need to make sure that all data is present before we set up the config.  Store values while looping over inputs and then process later
  std::string leftSubstance = "";
  std::string rightSubstance = "";
  double leftSubFraction = 0.0;
  double rightSubFraction = 0.0;

  for (unsigned int i = 0; i < inputs.size(); ++i) {
    nameSplit = biogears::split(inputs[i], ':');   //e.g. separates name from input; eg: "Ventilator:10,cmH2O" --> ["Ventilator", "10,cmH2O"]
    if (nameSplit.size() == 1) {
      //Nothing after ":", so empty and do not parse
      continue;
    }
    if (nameSplit[0] == "Connection") {
      value = nameSplit[1];
      int connection = value == "Off" ? 0 : value == "Mask" ? 1 : 2;
      config.SetConnection((CDM::enumAnesthesiaMachineConnection::value)connection);
    } else if (nameSplit[0] == "PrimaryGas") {
      value = nameSplit[1];
      int gas = value == "Air" ? 0 : 1;
      config.SetPrimaryGas((CDM::enumAnesthesiaMachinePrimaryGas::value)gas);
    } else if (nameSplit[0] == "OxygenSource") {
      value = nameSplit[1];
      int source = value == " Wall" ? 0 : value == "OxygenBottleOne" ? 1 : 2;
      config.SetOxygenSource((CDM::enumAnesthesiaMachineOxygenSource::value)source);
    } else if (nameSplit[0] == "VentilatorPressure") {
      valueUnitPair = biogears::split(nameSplit[1], ',');
      config.GetVentilatorPressure().SetValue(std::stod(valueUnitPair[0]), biogears::PressureUnit::GetCompoundUnit(valueUnitPair[1]));
    } else if (nameSplit[0] == "PositiveEndExpiredPressure") {
      valueUnitPair = biogears::split(nameSplit[1], ',');
      config.GetPositiveEndExpiredPressure().SetValue(std::stod(valueUnitPair[0]), biogears::PressureUnit::GetCompoundUnit(valueUnitPair[1]));
    } else if (nameSplit[0] == "InletFlow") {
      valueUnitPair = biogears::split(nameSplit[1], ',');
      config.GetInletFlow().SetValue(std::stod(valueUnitPair[0]), biogears::VolumePerTimeUnit::GetCompoundUnit(valueUnitPair[1]));
    } else if (nameSplit[0] == "RespirationRate") {
      valueUnitPair = biogears::split(nameSplit[1], ',');
      config.GetRespiratoryRate().SetValue(std::stod(valueUnitPair[0]), biogears::FrequencyUnit::GetCompoundUnit(valueUnitPair[1]));
    } else if (nameSplit[0] == "InspiratoryExpiratoryRatio") {
      value = nameSplit[1];
      config.GetInspiratoryExpiratoryRatio().SetValue(std::stod(value));
    } else if (nameSplit[0] == "OxygenFraction") {
      value = nameSplit[1];
      config.GetOxygenFraction().SetValue(std::stod(value));
    } else if (nameSplit[0] == "ReliefValvePressure") {
      valueUnitPair = biogears::split(nameSplit[1], ',');
      config.GetReliefValvePressure().SetValue(std::stod(valueUnitPair[0]), biogears::PressureUnit::GetCompoundUnit(valueUnitPair[1]));
    } else if (nameSplit[0] == "OxygenBottleOne") {
      valueUnitPair = biogears::split(nameSplit[1], ',');
      config.GetOxygenBottleOne().GetVolume().SetValue(std::stod(valueUnitPair[0]), biogears::VolumeUnit::GetCompoundUnit(valueUnitPair[1]));
    } else if (nameSplit[0] == "OxygenBottleTwo") {
      config.GetOxygenBottleTwo().GetVolume().SetValue(std::stod(valueUnitPair[0]), biogears::VolumeUnit::GetCompoundUnit(valueUnitPair[1]));
    } else if (nameSplit[0] == "LeftChamberSubstance") {
      leftSubstance = nameSplit[1];
    } else if (nameSplit[0] == "RightChamberSubstance") {
      rightSubstance = nameSplit[1];
    } else if (nameSplit[0] == "LeftChamberSubstanceFraction") {
      leftSubFraction = std::stod(nameSplit[1]);
    } else if (nameSplit[0] == "RightChamberSubstanceFractin") {
      rightSubFraction = std::stod(nameSplit[1]);
    }
  }
  //Check to see if left/right chamber need to be set up
  if (!leftSubstance.empty() && leftSubFraction > 0.0) {
    config.GetLeftChamber().SetSubstance(*subMgr.GetSubstance(leftSubstance));
    config.GetLeftChamber().GetSubstanceFraction().SetValue(leftSubFraction);
    config.GetLeftChamber().SetState(CDM::enumOnOff::On);
  }
  if (!rightSubstance.empty() && rightSubFraction > 0.0) {
    config.GetRightChamber().SetSubstance(*subMgr.GetSubstance(rightSubstance));
    config.GetRightChamber().GetSubstanceFraction().SetValue(rightSubFraction);
    config.GetRightChamber().SetState(CDM::enumOnOff::On);
  }
  
  return action;
}
biogears::SEApnea* EventTree::decode_apnea(Event& ev)
{
  biogears::SEApnea* action = new biogears::SEApnea();
  //Only one arg (severity), split at ":" --> e.g. severity:0.5
  double input = std::stod(biogears::split(ev.params.toStdString(), ':')[1]);
  action->GetSeverity().SetValue(input);
  return action;
}
//-----------------------------------------------------------------------------
biogears::SEAsthmaAttack* EventTree::decode_asthma_attack(Event& ev)
{
  biogears::SEAsthmaAttack* action = new biogears::SEAsthmaAttack();
  //Only one arg (severity), split at ":" --> e.g. severity:0.5
  double input = std::stod(biogears::split(ev.params.toStdString(), ':')[1]);
  action->GetSeverity().SetValue(input);
  return action;
}
//-----------------------------------------------------------------------------
biogears::SEBronchoconstriction* EventTree::decode_bronchoconstriction(Event& ev)
{
  biogears::SEBronchoconstriction* action = new biogears::SEBronchoconstriction();
  //Only one arg (severity), split at ":" --> e.g. severity:0.5
  double input = std::stod(biogears::split(ev.params.toStdString(), ':')[1]);
  action->GetSeverity().SetValue(input);
  return action;
}
//-----------------------------------------------------------------------------
biogears::SEBurnWound* EventTree::decode_burn_wound(Event& ev)
{
  biogears::SEBurnWound* action = new biogears::SEBurnWound();
  //Only one arg (severity), split at ":" --> e.g. severity:0.5
  double input = std::stod(biogears::split(ev.params.toStdString(), ':')[1]);
  action->GetTotalBodySurfaceArea().SetValue(input);
  return action;
}
//-----------------------------------------------------------------------------
biogears::SECardiacArrest* EventTree::decode_cardiac_arrest(Event& ev)
{
  biogears::SECardiacArrest* action = new biogears::SECardiacArrest();
  //Only one arg (on/off), split at ":" --> e.g. State:On
  std::string state = biogears::split(ev.params.toStdString(), ':')[1];
  action->SetActive(state=="On");
  return action;
}
//-----------------------------------------------------------------------------
biogears::SEConsumeNutrients* EventTree::decode_consume_nutrients(Event& ev)
{
  biogears::SEConsumeNutrients* action = new biogears::SEConsumeNutrients();
  //Split parameter string so that every parameter has individual entry, e.g. ["Connection:Mask", "OxygenSource:Wall", ...]
  std::vector<std::string> inputs = biogears::split(ev.params.toStdString(), ';');
  //Re-usable variables
  std::vector<std::string> nameSplit;
  std::vector<std::string> valueUnitPair;
  for (unsigned int i = 0; i < inputs.size(); ++i) {
    nameSplit = biogears::split(inputs[i], ':'); //e.g. separates name from input; eg: "Ventilator:10,cmH2O" --> ["Ventilator", "10,cmH2O"]
    if (nameSplit.size() == 1) {
      //Nothing after ":", so empty and do not parse
      continue;
    }
    if (nameSplit[0] == "Carbohydrate") {
      valueUnitPair = biogears::split(nameSplit[1], ',');
      action->GetNutrition().GetCarbohydrate().SetValue(std::stod(valueUnitPair[0]), biogears::MassUnit::GetCompoundUnit(valueUnitPair[1]));
    } else if (nameSplit[0] == "Fat") {
      valueUnitPair = biogears::split(nameSplit[1], ',');
      action->GetNutrition().GetFat().SetValue(std::stod(valueUnitPair[0]), biogears::MassUnit::GetCompoundUnit(valueUnitPair[1]));
    } else if (nameSplit[0] == "Protein") {
      valueUnitPair = biogears::split(nameSplit[1], ',');
      action->GetNutrition().GetProtein().SetValue(std::stod(valueUnitPair[0]), biogears::MassUnit::GetCompoundUnit(valueUnitPair[1]));
    } else if (nameSplit[0] == "Calcium") {
      valueUnitPair = biogears::split(nameSplit[1], ',');
      action->GetNutrition().GetCalcium().SetValue(std::stod(valueUnitPair[0]), biogears::MassUnit::GetCompoundUnit(valueUnitPair[1]));
    } else if (nameSplit[0] == "Sodium") {
      valueUnitPair = biogears::split(nameSplit[1], ',');
      action->GetNutrition().GetSodium().SetValue(std::stod(valueUnitPair[0]), biogears::MassUnit::GetCompoundUnit(valueUnitPair[1]));
    } else if (nameSplit[0] == "Water") {
      valueUnitPair = biogears::split(nameSplit[1], ',');
      action->GetNutrition().GetWater().SetValue(std::stod(valueUnitPair[0]), biogears::VolumeUnit::GetCompoundUnit(valueUnitPair[1]));
    }
  }
  return action;
}
//-----------------------------------------------------------------------------
biogears::SESubstanceAdministration* EventTree::decode_substance_administration(Event& ev, biogears::SESubstanceManager& subMgr)
{
  //Split parameter string so that every parameter has individual entry, e.g. ["Connection:Mask", "OxygenSource:Wall", ...]
  std::vector<std::string> inputs = biogears::split(ev.params.toStdString(), ';');
  //Re-usable variables
  std::vector<std::string> nameSplit;
  std::vector<std::string> valueUnitPair;
  std::string value;
  //Need to extract substance or substance compound name -- params string set up so that Substance/SubstanceCompound name is first element
  std::string sub = biogears::split(inputs[0], ':')[1];
  switch (ev.eSubType) {
  case EventTypes::SubstanceBolus: {
    biogears::SESubstanceBolus* bolus = new biogears::SESubstanceBolus(*subMgr.GetSubstance(sub));
    for (unsigned int i = 1; i < inputs.size(); ++i) {
      //Starting at i = 1 because sub name was index 0
      nameSplit = biogears::split(inputs[i], ':');
      if (nameSplit[0] == "Concentration") {
        valueUnitPair = biogears::split(nameSplit[1], ',');
        bolus->GetConcentration().SetValue(std::stod(valueUnitPair[0]), biogears::MassPerVolumeUnit::GetCompoundUnit(valueUnitPair[1]));
      } else if (nameSplit[0] == "Dose") {
        valueUnitPair = biogears::split(nameSplit[1], ',');
        bolus->GetDose().SetValue(std::stod(valueUnitPair[0]), biogears::VolumeUnit::GetCompoundUnit(valueUnitPair[1]));
      } else if (nameSplit[0] == "Route") {
        value = nameSplit[1];
        int route = value == "Bolus-Intraarterial" ? 0 : value=="Bolus-Intramuscular" ? 1 : 2;
        bolus->SetAdminRoute((CDM::enumBolusAdministration::value)route);
      }
    }
    return bolus;
  }
  case EventTypes::SubstanceInfusion: {
    biogears::SESubstanceInfusion* infuse = new biogears::SESubstanceInfusion(*subMgr.GetSubstance(sub));
    for (unsigned int i = 1; i < inputs.size(); ++i) {
      //Starting at i = 1 because sub name was index 0
      nameSplit = biogears::split(inputs[i], ':');
      if (nameSplit[0] == "Concentration") {
        valueUnitPair = biogears::split(nameSplit[1], ',');
        infuse->GetConcentration().SetValue(std::stod(valueUnitPair[0]), biogears::MassPerVolumeUnit::GetCompoundUnit(valueUnitPair[1]));
      } else if (nameSplit[0] == "Rate") {
        valueUnitPair = biogears::split(nameSplit[1], ',');
       infuse->GetRate().SetValue(std::stod(valueUnitPair[0]), biogears::VolumePerTimeUnit::GetCompoundUnit(valueUnitPair[1]));
      }
    }
    return infuse;
  } 
  case EventTypes::SubstanceOralDose: {
    biogears::SESubstanceOralDose* oDose = new biogears::SESubstanceOralDose(*subMgr.GetSubstance(sub));
    for (unsigned int i = 1; i < inputs.size(); ++i) {
      //Starting at i = 1 because sub name was index 0
      nameSplit = biogears::split(inputs[i], ':');
      if (nameSplit[0] == "Dose") {
        valueUnitPair = biogears::split(nameSplit[1], ',');
        oDose->GetDose().SetValue(std::stod(valueUnitPair[0]), biogears::MassUnit::GetCompoundUnit(valueUnitPair[1]));
      } else if (nameSplit[0] == "Route") {
        value = nameSplit[1];
        int route = value == "Oral-Transmucosal" ? 0 : 1;
        oDose->SetAdminRoute((CDM::enumOralAdministration::value)route);
      }
    }
    return oDose;
  }
  case EventTypes::SubstanceCompoundInfusion: {
    biogears::SESubstanceCompoundInfusion* infuse = new biogears::SESubstanceCompoundInfusion(*subMgr.GetCompound(sub));
    for (unsigned int i = 1; i < inputs.size(); ++i) {
      //Starting at i = 1 because compound name was index 0
      nameSplit = biogears::split(inputs[i], ':');
      if (nameSplit[0] == "Rate") {
        valueUnitPair = biogears::split(nameSplit[1], ',');
        infuse->GetRate().SetValue(std::stod(valueUnitPair[0]), biogears::VolumePerTimeUnit::GetCompoundUnit(valueUnitPair[1]));
      } else if (nameSplit[0] == "BagVolume") {
        valueUnitPair = biogears::split(nameSplit[1], ',');
        infuse->GetBagVolume().SetValue(std::stod(valueUnitPair[0]), biogears::VolumeUnit::GetCompoundUnit(valueUnitPair[1]));
      }
    }
    return infuse;
  }
  default:
    return nullptr;
  }
}
//-----------------------------------------------------------------------------
biogears::SEExercise* EventTree::decode_exercise(Event& ev)
{
  biogears::SEExercise* action = new biogears::SEExercise();
  //Split parameter string so that every parameter has individual entry, e.g. ["Connection:Mask", "OxygenSource:Wall", ...]
  std::vector<std::string> inputs = biogears::split(ev.params.toStdString(), ';');
  //Re-usable variables
  std::vector<std::string> nameSplit;
  std::vector<std::string> valueUnitPair;
  std::string value;
  switch (ev.eSubType) {
  case EventTypes::GenericExercise: {
    biogears::SEExercise::SEGeneric gen;
    for (unsigned int i = 0; i < inputs.size(); ++i) {
      nameSplit = biogears::split(inputs[i], ':');
      if (nameSplit[0] == "Intensity") {
        gen.Intensity.SetValue(std::stod(nameSplit[1]));
      } else if (nameSplit[0] == "DesiredWorkRate") {
        valueUnitPair = biogears::split(nameSplit[1], ',');
        gen.DesiredWorkRate.SetValue(std::stod(valueUnitPair[0]), biogears::PowerUnit::GetCompoundUnit(valueUnitPair[1]));
      }
    }
    action->SetGenericExercise(gen);
  } break;
  case EventTypes::CyclingExercise: {
    biogears::SEExercise::SECycling cycle;
    for (unsigned int i = 0; i < inputs.size(); ++i) {
      nameSplit = biogears::split(inputs[i], ':');
      if (nameSplit[0] == "Cadence") {
        valueUnitPair = biogears::split(nameSplit[1], ',');
        cycle.CadenceCycle.SetValue(std::stod(valueUnitPair[0]), biogears::FrequencyUnit::GetCompoundUnit(valueUnitPair[1]));
      } else if (nameSplit[0] == "Power") {
        valueUnitPair = biogears::split(nameSplit[1], ',');
        cycle.PowerCycle.SetValue(std::stod(valueUnitPair[0]), biogears::PowerUnit::GetCompoundUnit(valueUnitPair[1]));
      } else if (nameSplit[0] == "AddedWeight") {
        valueUnitPair = biogears::split(nameSplit[1], ',');
        cycle.AddedWeight.SetValue(std::stod(valueUnitPair[0]), biogears::MassUnit::GetCompoundUnit(valueUnitPair[1]));
      }
    }
    action->SetCyclingExercise(cycle);
  } break;
  case EventTypes::RunningExercise: {
    biogears::SEExercise::SERunning run;
    for (unsigned int i = 0; i < inputs.size(); ++i) {
      nameSplit = biogears::split(inputs[i], ':');
      if (nameSplit[0] == "Speed") {
        valueUnitPair = biogears::split(nameSplit[1], ',');
        run.SpeedRun.SetValue(std::stod(valueUnitPair[0]), biogears::LengthPerTimeUnit::GetCompoundUnit(valueUnitPair[1]));
      } else if (nameSplit[0] == "Incline") {
        run.InclineRun.SetValue(std::stod(nameSplit[1]));
      } else if (nameSplit[0] == "AddedWeight") {
        valueUnitPair = biogears::split(nameSplit[1], ',');
        run.AddedWeight.SetValue(std::stod(valueUnitPair[0]), biogears::MassUnit::GetCompoundUnit(valueUnitPair[1]));
      }
    }
    action->SetRunningExercise(run);
  } break;
  case EventTypes::StengthExercise: {
    biogears::SEExercise::SEStrengthTraining strength;
    for (unsigned int i = 0; i < inputs.size(); ++i) {
      nameSplit = biogears::split(inputs[i], ':');
      if (nameSplit[0] == "Weight") {
        valueUnitPair = biogears::split(nameSplit[1], ',');
        strength.WeightStrength.SetValue(std::stod(valueUnitPair[0]), biogears::MassUnit::GetCompoundUnit(valueUnitPair[1]));
      } else if (nameSplit[0] == "Repetitions") {
        strength.RepsStrength.SetValue(std::stod(nameSplit[1]));
      }
    }
    action->SetStrengthExercise(strength);
  } break;
  }
  return action;
}
//-----------------------------------------------------------------------------
biogears::SEHemorrhage* EventTree::decode_hemorrhage(Event& ev)
{
  biogears::SEHemorrhage* action = new biogears::SEHemorrhage();
  //Split parameter string so that every parameter has individual entry, e.g. ["Connection:Mask", "OxygenSource:Wall", ...]
  std::vector<std::string> inputs = biogears::split(ev.params.toStdString(), ';');
  //Re-usable variables
  std::vector<std::string> nameSplit;
  std::vector<std::string> valueUnitPair;
  for (unsigned int i = 0; i < inputs.size(); ++i) {
    nameSplit = biogears::split(inputs[i], ':');
    if (nameSplit[0] == "InitialRate") {
      valueUnitPair = biogears::split(nameSplit[1], ',');
      action->GetInitialRate().SetValue(std::stod(valueUnitPair[0]), biogears::VolumePerTimeUnit::GetCompoundUnit(valueUnitPair[1]));
    } else if (nameSplit[0] == "Compartment") {
      action->SetCompartment(nameSplit[1]);
    }
  }
  return action;
}
//-----------------------------------------------------------------------------
biogears::SEInfection* EventTree::decode_infection(Event& ev)
{
  biogears::SEInfection* action = new biogears::SEInfection();
  //Split parameter string so that every parameter has individual entry, e.g. ["Connection:Mask", "OxygenSource:Wall", ...]
  std::vector<std::string> inputs = biogears::split(ev.params.toStdString(), ';');
  //Re-usable variables
  std::vector<std::string> nameSplit;
  std::vector<std::string> valueUnitPair;
  for (unsigned int i = 0; i < inputs.size(); ++i) {
    nameSplit = biogears::split(inputs[i], ':');
    if (nameSplit[0] == "MinimumInhibitoryConcentration") {
      valueUnitPair = biogears::split(nameSplit[1], ',');
      action->GetMinimumInhibitoryConcentration().SetValue(std::stod(valueUnitPair[0]), biogears::MassPerVolumeUnit::GetCompoundUnit(valueUnitPair[1]));
    } else if (nameSplit[0] == "Location") {
      action->SetLocation(nameSplit[1]);
    } else if (nameSplit[0] == "Severity") {
      action->SetSeverity((CDM::enumInfectionSeverity::value)std::stoi(nameSplit[1]));
    }
  }
  return action;
}
//-----------------------------------------------------------------------------
biogears::SENeedleDecompression* EventTree::decode_needle_decompression(Event& ev)
{
  biogears::SENeedleDecompression* action = new biogears::SENeedleDecompression();
  //Only one arg (side), split at ":" --> e.g. side:0
  int input = std::stoi(biogears::split(ev.params.toStdString(), ':')[1]);
  action->SetSide((CDM::enumSide::value)input);
  return action;
}
//-----------------------------------------------------------------------------
biogears::SEPainStimulus* EventTree::decode_pain_stimulus(Event& ev)
{
  biogears::SEPainStimulus* action = new biogears::SEPainStimulus();
  //Split parameter string so that every parameter has individual entry, e.g. ["Connection:Mask", "OxygenSource:Wall", ...]
  std::vector<std::string> inputs = biogears::split(ev.params.toStdString(), ';');
  //Re-usable variables
  std::vector<std::string> nameSplit;
  std::vector<std::string> valueUnitPair;
  for (unsigned int i = 0; i < inputs.size(); ++i) {
    nameSplit = biogears::split(inputs[i], ':');
    if (nameSplit[0] == "Severity") {
      action->GetSeverity().SetValue(std::stod(nameSplit[1]));
    } else if (nameSplit[0] == "Location") {
      action->SetLocation(nameSplit[1]);
    }
  }
  return action;
}
//-----------------------------------------------------------------------------
biogears::SETensionPneumothorax* EventTree::decode_tension_pneumothorax(Event& ev)
{
  biogears::SETensionPneumothorax* action = new biogears::SETensionPneumothorax();
  //Split parameter string so that every parameter has individual entry, e.g. ["Connection:Mask", "OxygenSource:Wall", ...]
  std::vector<std::string> inputs = biogears::split(ev.params.toStdString(), ';');
  //Re-usable variables
  std::vector<std::string> nameSplit;
  std::vector<std::string> valueUnitPair;
  for (unsigned int i = 0; i < inputs.size(); ++i) {
    nameSplit = biogears::split(inputs[i], ':');
    if (nameSplit[0] == "Severity") {
      action->GetSeverity().SetValue(std::stod(nameSplit[1]));
    } else if (nameSplit[0] == "Side") {
      action->SetSide((CDM::enumSide::value)std::stoi(nameSplit[1]));
    } else if (nameSplit[0] == "Type") {
      action->SetType((CDM::enumPneumothoraxType::value)std::stoi(nameSplit[1]));
    }
  }
  return action;
}
//-----------------------------------------------------------------------------
biogears::SETourniquet* EventTree::decode_tourniquet(Event& ev)
{
  biogears::SETourniquet* action = new biogears::SETourniquet();
  //Split parameter string so that every parameter has individual entry, e.g. ["Connection:Mask", "OxygenSource:Wall", ...]
  std::vector<std::string> inputs = biogears::split(ev.params.toStdString(), ';');
  //Re-usable variables
  std::vector<std::string> nameSplit;
  std::vector<std::string> valueUnitPair;
  for (unsigned int i = 0; i < inputs.size(); ++i) {
    nameSplit = biogears::split(inputs[i], ':');
    if (nameSplit[0] == "Compartment") {
      action->SetCompartment(nameSplit[1]);
    } else if (nameSplit[0] == "TourniquetLevel") {
      action->SetTourniquetLevel((CDM::enumTourniquetApplicationLevel::value)std::stoi(nameSplit[1]));
    }
  }
  return action;
}
//-----------------------------------------------------------------------------
biogears::SEBrainInjury* EventTree::decode_traumatic_brain_injury(Event& ev)
{
  biogears::SEBrainInjury* action = new biogears::SEBrainInjury();
  //Split parameter string so that every parameter has individual entry, e.g. ["Connection:Mask", "OxygenSource:Wall", ...]
  std::vector<std::string> inputs = biogears::split(ev.params.toStdString(), ';');
  //Re-usable variables
  std::vector<std::string> nameSplit;
  std::vector<std::string> valueUnitPair;
  for (unsigned int i = 0; i < inputs.size(); ++i) {
    nameSplit = biogears::split(inputs[i], ':');
    if (nameSplit[0] == "Severity") {
      action->GetSeverity().SetValue(std::stod(nameSplit[1]));
    } else if (nameSplit[0] == "Type") {
      action->SetType((CDM::enumBrainInjuryType::value)std::stoi(nameSplit[1]));
    }
  }
  return action;
}
}