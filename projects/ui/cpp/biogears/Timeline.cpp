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

//! TODO: Apparently for Scalard Data Unit() is an optional.  But, it should not be for ScalarData.
//!       For debugging reasons we need to add a lot of extra if statments and asserts to avoid
//!       poorly formated Scenario files.

Timeline::Timeline(QString path, QString name)
{
  std::ifstream stream{ (path + "/" + name).toStdString() };

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

        ev.eType = Event::UnknownAction;
        ev.typeName = "Unknown Action";
        ev.comment = (action.Comment().present()) ? action.Comment().get().c_str() : "";

        ///!Scenario 2.0 An Event with no Duration last for ever. When a duration is preset the inverse action occurs when the duration is over
        ///!                   An Event with Occurs starts at the time specified.  If duration < action.Occurs() + action.Duration();
        ///!                   TimeAdvance Events have no extra fields

        ev.startTime = (action.Occurs().present()) ? action.Occurs().get() : duration;
        ev.duration = (action.Duration().present()) ? action.Duration().get() : 0.;

        if (process_action(ev, action)) {
          if (ev.params.size() && ev.params.back() == ";") {
            ev.params.remove(ev.params.size() - 1);
          }
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
  ev.eType = Event::UnknownAction;
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
  using namespace biogears;

  std::cout << "As PatientAction"
            << *action << "\n\n";
  ev.eType = Event::PatientAction;
  ev.typeName = "Patient Events\n";

  if (auto aStress = dynamic_cast<const CDM::AcuteStressData*>(action)) {
    ev.eType = Event::AcuteStress;
    ev.typeName = "Acute Stress";
    ev.description = "Applies Acute Stress insult";
    ev.params = "";

    ev.params.append(asprintf("Severity=%f;", aStress->Severity().value()).c_str());
    return true;
  }
  else if (auto airwayObst = dynamic_cast<const CDM::AirwayObstructionData*>(action)) {
    ev.eType = Event::AirwayObstructionData;
    ev.typeName = "Airway Obstruction";
    ev.description = "Applies an airway obstruction";
    ev.params = "";

    ev.params.append(asprintf("Severity=%f;", airwayObst->Severity().value()).c_str());
    return true;
  }
  else if (auto apnea = dynamic_cast<const CDM::ApneaData*>(action)) {
    ev.eType = Event::Apnea;
    ev.typeName = "Apnea";
    ev.description = "Applies an apnea insult";
    ev.params = "";

    ev.params.append(asprintf("Severity=%f;", apnea->Severity().value()).c_str());
    return true;
  }
  else if (auto asthmaattack = dynamic_cast<const CDM::AsthmaAttackData*>(action)) {
    ev.eType = Event::AsthmaAttack;
    ev.typeName = "Asthma Attack";
    ev.description = "Applies Asthma Attack Insult";
    ev.params = "";

    ev.params.append(asprintf("Severity=%f;", asthmaattack->Severity().value()).c_str());
    return true;
  }
  else if (auto brainInjury = dynamic_cast<const CDM::BrainInjuryData*>(action)) {
    ev.eType = Event::BrainInjury;
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
  }
  else if (auto bronchoconstr = dynamic_cast<const CDM::BronchoconstrictionData*>(action)) {
    ev.eType = Event::Bronchoconstriction;
    ev.typeName = "Bronchoconstriction";
    ev.description = "Applies a bronchoconstriction insult";
    ev.params = "";

    ev.params.append(asprintf("Severity=%f;", bronchoconstr->Severity().value()).c_str());
    return true;
  }
  else if (auto burn = dynamic_cast<const CDM::BurnWoundData*>(action)) {
    ev.eType = Event::BurnWound;
    ev.typeName = "Burn Wound";
    ev.description = "Applies a burn wound insult";
    ev.params = "";

    ev.params.append(asprintf("State=%s;", burn->TotalBodySurfaceArea().value(), burn->TotalBodySurfaceArea().unit()->c_str()).c_str());
    return true;
  }
  else if (auto cardiacarrest = dynamic_cast<const CDM::CardiacArrestData*>(action)) {
    ev.eType = Event::CardiacArrest;
    ev.typeName = "Cardiac Arrest";
    ev.description = "Applies a cardiac arrest insult to the patient";
    ev.params = "";

    ev.params.append(asprintf("State=%s;", cardiacarrest->State() == CDM::enumOnOff::On ? "On" : "Off").c_str());
    return true;
  }
  else if (auto chestcomp = dynamic_cast<const CDM::ChestCompressionData*>(action)) {
    ev.eType = Event::ChestCompression;
    ev.typeName = "Chest Compression";
    ev.description = "Manual Chest Compression";
    ev.params = "";
    ev.eType = Event::ChestCompression;
    ev.typeName = "Chest Compression Action\n";
    if (auto cprForce = dynamic_cast<const CDM::ChestCompressionForceData*>(chestcomp)) {
      ev.eType = Event::ChestCompressionForce;
      ev.typeName = "Chest Compression Force";
      ev.description = "Chest Compression Force?";
      ev.params = "";

      ev.params.append(asprintf("Force=%f,%s;", cprForce->Force().value(), cprForce->Force().unit()->c_str()).c_str());
      return true;
    } else if (auto cprScale = dynamic_cast<const CDM::ChestCompressionForceScaleData*>(chestcomp)) {
      ev.eType = Event::ChestCompressionForceScale;
      ev.typeName = "Chest Compression Force Scale";
      ev.description = "Chest Compression Force Scale?";
      ev.params = "";

      ev.params.append(asprintf("Side=%f,%s;", cprScale->ForcePeriod()->value(), cprScale->ForcePeriod()->unit()->c_str()).c_str());
      ev.params.append(asprintf("command=%f;", cprScale->ForceScale().value()).c_str());
      return true;
    }
    return false;
  } else if (auto chestOccl = dynamic_cast<const CDM::ChestOcclusiveDressingData*>(action)) {
    ev.eType = Event::ChestOcclusiveDressing;
    ev.typeName = "Chest Occlusive Dressing";
    ev.description = "Applies a occlusive dressing to the chest";
    ev.params = "";

    ev.params.append(asprintf("Side=%s;", chestOccl->Side() == CDM::enumSide::Left ? "Left" : "Right").c_str());
    ev.params.append(asprintf("command=%s;", chestOccl->State() == CDM::enumOnOff::On ? "On" : "Off").c_str());

    return true;
  } else if (auto conResp = dynamic_cast<const CDM::ConsciousRespirationData*>(action)) {
    ev.eType = Event::ConsciousRespiration;
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
    ev.eType = Event::ConsumeNutrients;
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
    ev.eType = Event::Exercise;
    ev.typeName = "Exercise";
    ev.description = "Force the patient in to an exercise state";
    ev.params = "";

    if (exercise->GenericExercise().present()) {
      auto& generic = exercise->GenericExercise().get();
      ev.eType = Event::GeneralExercise;
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
      ev.eType = Event::CyclingExercise;
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
      ev.eType = Event::RunningExercise;
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
      ev.eType = Event::StengthExercise;
      ev.typeName = "Strength Exercise";
      ev.description = "Strength Exercise Action";

      ev.params.append(asprintf("Repetitions=%f;", strength.Repetitions().value()).c_str());
      ev.params.append(asprintf("Weight=%f,%s;", strength.Weight().value(), strength.Weight().unit()->c_str()).c_str());
    }

    return true;
  } else if (auto hem = dynamic_cast<const CDM::HemorrhageData*>(action)) {
    ev.eType = Event::Hemorrhage;
    ev.typeName = "Hemorrhage";
    ev.description = "Applies a hemorrhage insult to the patient for a given compartment";
    ev.params = "";

    ev.params.append(asprintf("Compartment=%s;", hem->Compartment().c_str()).c_str());
    ev.params.append(asprintf("InitialRate=%f,%s;", hem->InitialRate().value(), hem->InitialRate().unit()->c_str()).c_str());
    return true;
  } else if (auto infect = dynamic_cast<const CDM::InfectionData*>(action)) {
    ev.eType = Event::Infection;
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
    ev.eType = Event::Intubation;
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
    ev.eType = Event::MechanicalVentilation;
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
  }
  else if (auto needleDecomp = dynamic_cast<const CDM::NeedleDecompressionData*>(action)) {
    ev.eType = Event::NeedleDecompression;
    ev.typeName = "Needle Decompression";
    ev.description = "Applies a needle decompression";
    ev.params = "";

    ev.params.append(asprintf("Side=%s;", needleDecomp->Side() == CDM::enumSide::Left ? "Left" : "Right").c_str());
    ev.params.append(asprintf("State=%s;", needleDecomp->State() == CDM::enumOnOff::On ? "On" : "Off").c_str());
    return true;
  } else if (auto pain = dynamic_cast<const CDM::PainStimulusData*>(action)) {
    ev.eType = Event::PainStimulus;
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
    ev.eType = Event::PericardialEffusion;
    ev.typeName = "Pericardial Effusion";
    ev.description = "Pericardial Effusion Insult";
    ev.params = "";

    ev.params.append(asprintf("EffusionRate=%f,%s", pericardialEff->EffusionRate().value(), pericardialEff->EffusionRate().unit()->c_str()).c_str());
    return true;
  } else if (auto admin = dynamic_cast<const CDM::SubstanceAdministrationData*>(action)) {
    ev.eType = Event::SubstanceAdministration;
    ev.typeName = "Substance Administration";
    ev.description = "Apply a substance to the patient";
    ev.params = "";

    if (auto bolusData = dynamic_cast<const CDM::SubstanceBolusData*>(admin)) {
      ev.eType = Event::SubstanceBolus;
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
      ev.eType = Event::SubstanceOralDose;
      ev.typeName = "Substance Administration by Oral Dose";
      ev.description = "Apply an oral dose of a substance to the patient";
      ev.params = "";

      ev.params.append(asprintf("Concentration=%f,%s;", oralData->Dose().value(), oralData->Dose().unit()->c_str()).c_str());
      ev.params.append(asprintf("AdminRoute=%s;", oralData->AdminRoute() == CDM::enumOralAdministration::Gastrointestinal ? "Gastrointestinal" : "Transmucosal").c_str());
      ev.params.append(asprintf("Substance=%s;", oralData->Substance().c_str()).c_str());
      return true;
    }
    if (auto subInfuzData = dynamic_cast<const CDM::SubstanceInfusionData*>(admin)) {
      ev.eType = Event::SubstanceInfusion;
      ev.typeName = "Substance Administration by Infusion";
      ev.description = "Apply a substance infusion to the patient";
      ev.params = "";

      ev.params.append(asprintf("Concentration=%f,%s;", subInfuzData->Concentration().value(), subInfuzData->Concentration().unit()->c_str()).c_str());
      ev.params.append(asprintf("Rate=%f,%s;", subInfuzData->Rate().value(), subInfuzData->Rate().unit()->c_str()).c_str());
      ev.params.append(asprintf("Substance=%s;", subInfuzData->Substance().c_str()).c_str());
      return true;
    }
    if (auto subCInfuzData = dynamic_cast<const CDM::SubstanceCompoundInfusionData*>(admin)) {
      ev.eType = Event::SubstanceCompoundInfusion;
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
    ev.eType = Event::TensionPneumothorax;
    ev.typeName = "Tension Pneumothorax";
    ev.description = "Application of a Tension Pneumothorax insult";
    ev.params = "";

    ev.params.append(asprintf("Type=%s;", (pneumo->Type() == CDM::enumPneumothoraxType::Open) ? "Open" : "Closed").c_str());
    ev.params.append(asprintf("Severity=%f;", pneumo->Severity().value()).c_str());
    ev.params.append(asprintf("Side=%s;", (pneumo->Side() == CDM::enumSide::Left) ? "Left" : "Right").c_str());

    return true;
  } else if (auto tournData = dynamic_cast<const CDM::TourniquetData*>(action)) {
    ev.eType = Event::Tourniquet;
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
    ev.eType = Event::Urinate;
    ev.typeName = "Force Urination";
    ev.description = "Causes patient to to empty bladder";
    ev.params = "";
    return true;
  }
  else if (auto orData = dynamic_cast<const CDM::OverrideData*>(action)) {
    ev.eType = Event::Override;
    ev.typeName = "Value Override";
    ev.description = "Configure the current value override values";
    ev.params = "";

    //TODO: Implement OverrideData
    return true;
  } else if (auto assessment = dynamic_cast<const CDM::PatientAssessmentRequestData*>(action)) {
    ev.eType = Event::PatientAssessmentRequest;
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
bool Timeline::process_action(Event& ev, CDM::EnvironmentActionData* action)
{
  using namespace biogears;
  std::cout << "As EnvironmentAction"
            << *action << "\n\n";
  ev.eType = Event::EnvironmentAction;
  ev.typeName = "Environment Action";
  if (auto change = dynamic_cast<const CDM::EnvironmentChangeData*>(action)) {
    ev.eType = Event::EnvironmentChange;
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
  }
  else if (auto thermal = dynamic_cast<const CDM::ThermalApplicationData*>(action)) {
    ev.eType = Event::ThermalApplication;
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
bool Timeline::process_action(Event& ev, CDM::AnesthesiaMachineActionData* action)
{
  using namespace biogears;

  std::cout << "As AnesthesiaMachienAction"
            << *action << "\n\n";
  ev.eType = Event::AnesthesiaMachineAction;
  ev.typeName = "Anesthesia Machine Action";
  if (auto anConfig = dynamic_cast<CDM::AnesthesiaMachineConfigurationData*>(action)) {
    ev.eType = Event::AnesthesiaMachineConfiguration;
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
  }
  else if (auto anO2WallLoss = dynamic_cast<CDM::OxygenWallPortPressureLossData*>(action)) {
    ev.eType = Event::OxygenWallPortPressureLoss;
    ev.typeName = "Oxygen Wall Port Pressure Loss";
    ev.description = "Modify the value of any pressure loss between the anesthesia machine and the wall connection";
    ev.params = asprintf("State=%s;", (anO2WallLoss->State() == CDM::enumOnOff::On ? "On" : "Off")).c_str();
    return true;
  }
  else if (auto anO2TankLoss = dynamic_cast<CDM::OxygenTankPressureLossData*>(action)) {
    ev.eType = Event::OxygenTankPressureLoss;
    ev.typeName = "Oxygen tank pressure loss";
    ev.description = "Modify the value of any pressure loss between the anesthesia machine and the oxygen tank";
    ev.params = asprintf("State=%s;", (anO2TankLoss->State() == CDM::enumOnOff::On ? "On" : "Off")).c_str();
    return true;
  }
  else if (auto anExLeak = dynamic_cast<CDM::ExpiratoryValveLeakData*>(action)) {
    ev.eType = Event::ExpiratoryValveLeak;
    ev.typeName = "Expiratory valve leak";
    ev.description = "Modify the value of any pressure loss between the anesthesia machine and the expiratory valve";
    ev.params = asprintf("Severity=%f,%s;", anExLeak->Severity().value(), anExLeak->Severity().unit()->c_str()).c_str();
    return true;
  }
  else if (auto anExObs = dynamic_cast<CDM::ExpiratoryValveObstructionData*>(action)) {
    ev.eType = Event::ExpiratoryValveObstruction;
    ev.typeName = "Expiratory valve obstruction";
    ev.description = "Modify the value of any obstruction in the expiratory valve";
    ev.params = asprintf("Severity=%f,%s;", anExObs->Severity().value(), anExObs->Severity().unit()->c_str()).c_str();
    return true;
  }
  else if (auto anInLeak = dynamic_cast<CDM::InspiratoryValveLeakData*>(action)) {
    ev.eType = Event::InspiratoryValveLeak;
    ev.typeName = "Inspiratory valve pressure loss";
    ev.description = "Modify the value of any pressure loss between the anesthesia machine and inspiratory valve";
    ev.params = asprintf("Severity=%f,%s;", anInLeak->Severity().value(), anInLeak->Severity().unit()->c_str()).c_str();
    return true;
  }
  else if (auto anInObs = dynamic_cast<CDM::InspiratoryValveObstructionData*>(action)) {
    ev.eType = Event::InspiratoryValveObstruction;
    ev.typeName = "Inspiratory valve obstruction";
    ev.description = "Modify the value of any obstruction in the inspiratory valve";
    ev.params = asprintf("Severity=%f,%s;", anInObs->Severity().value(), anInObs->Severity().unit()->c_str()).c_str();
    return true;
  }
  else if (auto anMskLeak = dynamic_cast<CDM::MaskLeakData*>(action)) {
    ev.eType = Event::MaskLeak;
    ev.typeName = "Leak in the Mask Seal";
    ev.description = "Modify the severity and occurence of a mask seal ";
    ev.params = asprintf("Severity=%f,%s;", anMskLeak->Severity().value(), anMskLeak->Severity().unit()->c_str()).c_str();
    return true;
  }
  else if (auto anSodaFail = dynamic_cast<CDM::SodaLimeFailureData*>(action)) {
    ev.eType = Event::SodaLimeFailure;
    ev.typeName = "A failure in the Soda Lime";
    ev.description = "Modifies the delivery of f NaOH & CaO chemicals";
    ev.params = asprintf("Severity=%f,%s;", anSodaFail->Severity().value(), anSodaFail->Severity().unit()->c_str()).c_str();
    return true;
  }
  else if (auto anTubLeak = dynamic_cast<CDM::TubeCuffLeakData*>(action)) {
    ev.eType = Event::TubeCuffLeak;
    ev.typeName = "Leak in the tube cuff";
    ev.description = "Modify the occurence and severity of the tub cuff";
    ev.params = asprintf("Severity=%f,%s;", anTubLeak->Severity().value(), anTubLeak->Severity().unit()->c_str()).c_str();
    return true;
  }
  else if (auto anVapFail = dynamic_cast<CDM::VaporizerFailureData*>(action)) {
    ev.eType = Event::VaporizerFailure;
    ev.typeName = "A failure of the vaporizer";
    ev.description = "Modifies the delivery of f NaOH & CaO chemicals";
    ev.params = asprintf("Severity=%f,%s;", anVapFail->Severity().value(), anVapFail->Severity().unit()->c_str()).c_str();
    return true;
  }
  else if (auto anVentLoss = dynamic_cast<CDM::VentilatorPressureLossData*>(action)) {
    ev.eType = Event::VentilatorPressureLoss;
    ev.typeName = "Loss of ventilator pressure";
    ev.description = "Modify the severity of a loss in ventilator pressure";
    ev.params = asprintf("Severity=%f,%s;", anVentLoss->Severity().value(), anVentLoss->Severity().unit()->c_str()).c_str();
    return true;
  }
  else if (auto anYDisc = dynamic_cast<CDM::YPieceDisconnectData*>(action)) {
    ev.eType = Event::YPieceDisconnect;
    ev.typeName = "Disconnection of the Y piece";
    ev.description = "Modifies the occurence of a Y piece disconnection";
    ev.params = asprintf("Severity=%f,%s;", anYDisc->Severity().value(), anYDisc->Severity().unit()->c_str()).c_str();
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
  ev.eType = Event::InhalerAction;
  ev.typeName = "Inhaler Action";
  if (auto inhalerConfig = dynamic_cast<const CDM::InhalerConfigurationData*>(action)) {
    ev.eType = Event::InhalerConfiguration;
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
bool Timeline::process_action(Event& ev, CDM::AdvanceTimeData* action)
{
  using namespace biogears;

  std::cout << "As AdvanceTime"
            << *action << "\n\n";

  ev.eType = Event::AdvanceTime;
  ev.typeName = "Time Advancement";
  ev.description = "Advances the time of the simulation by the given duration";
  ev.params = asprintf("Time=%f,%s", action->Time().value(), action->Time().unit()->c_str()).c_str();

  return true;
}
//-----------------------------------------------------------------------------
bool Timeline::process_action(Event& ev, CDM::SerializeStateData* action)
{
  using namespace biogears;
  std::cout << "As SerializeState"
            << *action << "\n\n";

  ev.eType = Event::SerializeState;
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