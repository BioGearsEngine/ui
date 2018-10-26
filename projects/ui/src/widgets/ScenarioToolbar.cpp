//-------------------------------------------------------------------------------------------
//- Copyright 2018 Applied Research Associates, Inc.
//- Licensed under the Apache License, Version 2.0 (the "License"); you may not use
//- this file except in compliance with the License. You may obtain a copy of the License
//- at:
//- http://www.apache.org/licenses/LICENSE-2.0
//- Unless required by applicable law or agreed to in writing, software distributed under
//- the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//- CONDITIONS OF ANY KIND, either express or implied. See the License for the
//-  specific language governing permissions and limitations under the License.
//-------------------------------------------------------------------------------------------

//!
//! \author Steven A White
//! \date   August 21st 2018
//!
//!
//! \brief Primary window of BioGears UI

#include "ScenarioToolbar.h"
//External Includes
#include <QtWidgets>
//Project Includes
#include "../utils/Resources.h"
namespace biogears_ui {

struct ScenarioToolbar::Implementation : public QObject {

public:
  Implementation(QWidget* parent);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

public:
  QComboBox* patients;
  QComboBox* enviroments;
  QComboBox* timelines;
};
//-------------------------------------------------------------------------------
ScenarioToolbar::Implementation::Implementation(QWidget* parent)
  : patients(new QComboBox(parent))
  , enviroments(new QComboBox(parent))
  , timelines(new QComboBox(parent))

{
  //Toolbar Patient
  patients->addItem(tr("Select a Patient"));
  patients->addItem(tr("New Patient"));
  auto fileList = Resources::list_directory("patients", R"(.*\.xml)" );
  for (const auto& file : fileList) {
    patients->addItem( file.c_str() );
  }
  patients->addItem(tr("Load patient from file..."));
  //Toolbar Enviroments
  enviroments->addItem(tr("Select an Environment"));
  enviroments->addItem(tr("New Environment"));
  fileList = Resources::list_directory("environments", R"(.*\.xml)" );
  for (const auto& file : fileList) {
    enviroments->addItem(file.c_str());
  }
  enviroments->addItem(tr("Load environment from file..."));
  //Toolbar timelines
  timelines->addItem(tr("Select an Timeline"));
  timelines->addItem(tr("New Timeline"));
  ;
  fileList = Resources::list_directory("timelines", R"(.*\.xml)" );
  for (const auto& file : fileList) {
    timelines->addItem(file.c_str());
  }
  fileList = Resources::list_directory("Scenarios", R"(.*\.xml)");
  for (const auto& file : fileList) {
    timelines->addItem(file.c_str());
  }
  timelines->addItem(tr("Load timeline from file..."));

}
//-------------------------------------------------------------------------------
ScenarioToolbar::Implementation::Implementation(const Implementation& obj)

{
  *this = obj;
}
//-------------------------------------------------------------------------------
ScenarioToolbar::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
ScenarioToolbar::Implementation& ScenarioToolbar::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
ScenarioToolbar::Implementation& ScenarioToolbar::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
ScenarioToolbar::ScenarioToolbar(QWidget* parent)
  : QToolBar(tr("Simulation"),parent)
  , _impl(this)
{
  addWidget(_impl->patients);
  addSeparator();
  addWidget(_impl->enviroments);
  addSeparator();
  addWidget(_impl->timelines);
  addSeparator();

  QIcon launchIcon = QIcon::fromTheme("Launch", QIcon(":/img/play.png"));
  QAction* action = new QAction(launchIcon, tr("Launch Simulation"), this);
  action->setStatusTip(tr("Run current simulation"));
  addAction(action);
  connect(action, &QAction::triggered, this, &ScenarioToolbar::resumeSimulation);

  QIcon pauseIcon = QIcon::fromTheme("Pause", QIcon(":/img/pause.png"));
  action = new QAction(pauseIcon, tr("Pause Simulation"), this);
  action->setStatusTip(tr("Pause running simulation"));
  addAction(action);
  connect(action, &QAction::triggered, this, &ScenarioToolbar::pauseSimulation);

  connect(_impl->patients, QOverload<int>::of(&QComboBox::activated), this, &ScenarioToolbar::patientChanged);
  connect(_impl->enviroments, QOverload<int>::of(&QComboBox::activated), this, &ScenarioToolbar::envonmentChanged);
  connect(_impl->timelines, QOverload<int>::of(&QComboBox::activated), this, &ScenarioToolbar::timelineChanged);

  setContextMenuPolicy(Qt::PreventContextMenu);
}
//-------------------------------------------------------------------------------
ScenarioToolbar::~ScenarioToolbar()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
std::string ScenarioToolbar::Patient() const
{
  return _impl->patients->currentText().toStdString();
};
//-------------------------------------------------------------------------------
std::string ScenarioToolbar::Environment() const 
{
  return _impl->enviroments->currentText().toStdString();
};
//-------------------------------------------------------------------------------
std::string ScenarioToolbar::Timeline() const
{
  return _impl->timelines->currentText().toStdString();
};
//-------------------------------------------------------------------------------
int ScenarioToolbar::patientListSize() { return _impl->patients->count(); }
//-------------------------------------------------------------------------------
int ScenarioToolbar::envrionmentListSize() { return _impl->enviroments->count(); }
//-------------------------------------------------------------------------------
int ScenarioToolbar::timelineListSize() { return _impl->timelines->count(); }
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto ScenarioToolbar::create(QWidget* parent) -> ScenarioToolbarPtr
{
  return new ScenarioToolbar(parent);
}
//-------------------------------------------------------------------------------
void ScenarioToolbar::lock()
{
  _impl->patients->setEnabled(false);
  _impl->timelines->setEnabled(false);
  _impl->enviroments->setEnabled(false);
}
//-------------------------------------------------------------------------------
void ScenarioToolbar::unlock()
{
  _impl->patients->setEnabled(true);
  _impl->timelines->setEnabled(true);
  _impl->enviroments->setEnabled(true);
}
}