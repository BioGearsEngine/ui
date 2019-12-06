#pragma once
#include <functional>
#include <memory>
#include <vector>
#include <map>

#include <QString>
#include <QtQuick>
#include <QVariant>

#include <biogears/cdm/scenario/SEAction.h>
#include <biogears/container/concurrent_queue.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>
#include <biogears/engine/Controller/BioGearsEngine.h>
#include <biogears/framework/scmp/scmp_channel.h>
#include <biogears/threading/runnable.h>
#include <biogears/threading/steppable.h>

#include "PatientConditions.h"
#include "PatientMetrics.h"
#include "PatientState.h"
#include "DataRequest.h"
#include "DataRequestModel.h"

namespace bio {

class Scenario : public QObject, public biogears::Runnable {

  Q_OBJECT
  Q_PROPERTY(double time READ get_simulation_time NOTIFY timeAdvance)

public:
  Scenario(QObject* parent = Q_NULLPTR);
  Scenario(QString name, QObject* parent = Q_NULLPTR);
  ~Scenario();

  using ActionQueue = biogears::ConcurrentQueue<std::unique_ptr<biogears::SEAction>>;
  using Channel = biogears::scmp::Channel<ActionQueue>;
  using Source = biogears::scmp::Source<ActionQueue>;

  Q_INVOKABLE QString patient_name();
  Q_INVOKABLE QString environment_name();

  Q_INVOKABLE Scenario& patinet_name(QString);
  Q_INVOKABLE Scenario& environment_name(QString);

  Q_INVOKABLE Scenario& load_patient(QString);


  Q_INVOKABLE double get_simulation_time();

  Q_INVOKABLE void run() final;
  Q_INVOKABLE void stop() final;
  Q_INVOKABLE void join() final;
  Q_INVOKABLE void step();

public: //Action Factory Interface;
  Q_INVOKABLE void create_hemorrhage_action(QString compartment, double ml_Per_min);
  Q_INVOKABLE void create_asthma_action();
  Q_INVOKABLE void create_substance_infusion_action();
  Q_INVOKABLE void create_burn_action();
  Q_INVOKABLE void create_infection_action();

signals:
  void patientStateChanged(PatientState patientState);
  void patientMetricsChanged(PatientMetrics metrics);
  void patientConditionsChanged(PatientConditions conditions);
  void timeAdvance();

protected:
  PatientState get_physiology_state();
  PatientMetrics get_physiology_metrics();
  PatientConditions get_physiology_conditions();


protected:
  void physiology_thread_main();
  void physiology_thread_step();

private:
  std::thread _thread;
  biogears::Logger _logger;
  std::unique_ptr<biogears::BioGears> _engine;
  Channel _action_queue;

  std::atomic<bool> _running;
  std::atomic<bool> _throttle;

  std::vector<std::pair<biogears::SEScalar const *, std::string>> _data_requests;
  std::unordered_map<std::string, size_t> _data_request_table;

};

}
