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
  TotalEventTypes
};

//!
//!  This class is for storing event information for a timeline
//!  A Timeline is QImage
struct Event {
  EventTypes eType;
  QString typeName;

  double startTime;
  double duration;

  QString summary;
  QString details;
  QString text;
};

class Timeline : public QObject {
  Q_OBJECT

public:
  Timeline(QString filepath, QString filename);
  Timeline() = default;

  void add_event(Event ev);

private:
  bool process_action(CDM::ActionData& action);
  bool process_action(CDM::PatientActionData* action);
  bool process_action(CDM::EnvironmentActionData* action);
  bool process_action(CDM::AnesthesiaMachineActionData* action);
  bool process_action(CDM::InhalerActionData* action);
  bool process_action(CDM::AdvanceTimeData* action);
  bool process_action(CDM::SerializeStateData* action);

  double duration;
  CDM::ScenarioData _data;
  std::vector<Event> _events;
};

}
