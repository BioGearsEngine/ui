#pragma once

#include <QObject>
#include <QString>

#include <vector>
#include <map>

#include <biogears/engine/BioGearsPhysiologyEngine.h>
#include <biogears/schema/cdm/Scenario.hxx>
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

class Timeline : public QObject{
Q_OBJECT

public:
Timeline(QString filepath, QString filename);
Timeline() = default;

void add_event(Event ev);

private:
double duration;
CDM::ScenarioData _data;
std::vector<Event> _events;
};

}
