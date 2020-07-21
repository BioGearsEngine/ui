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
      props.schema_location("uri:/mil/tatrc/physiology/datamodel","xsd/BioGearsDataModel.xsd");
      auto scenario = CDM::Scenario(stream, flags, props);
      for (auto action : scenario->Action()) {
        std::cout << action << std::endl;
      }
    } catch (::xsd::cxx::tree::parsing<char> e) {
      std::cout << e << std::endl;
    } 
  }
}
//-----------------------------------------------------------------------------
void Timeline::add_event(Event ev)
{
}
}