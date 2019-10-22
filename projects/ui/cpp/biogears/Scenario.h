#pragma once
#include <functional>

#include <QString>
#include <QtQuick>

#include <biogears/cdm/scenario/SEAction.h>
#include <biogears/container/concurrent_queue.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>
#include <biogears/engine/Controller/BioGearsEngine.h>
#include <biogears/framework/scmp/scmp_channel.h>
#include <biogears/threading/runnable.h>
#include <biogears/threading/steppable.h>
namespace bio {

  struct State;
  struct Metrics;
  struct Conditions;

class Scenario : public QObject, public biogears::Runnable, public biogears::Steppable<void(void)> {

  Q_OBJECT
  Q_PROPERTY(State state READ get_physiology_state NOTIFY stateChanged)
  Q_PROPERTY(Metrics metrics READ get_pysiology_metrics NOTIFY metricsChanged)
  Q_PROPERTY(Conditions conditions READ get_pysiology_conditions NOTIFY conditionsChanged)
  Q_PROPERTY(double time READ get_simulation_time NOTIFY timeAdvance)


public:
  Scenario(QObject* parent = Q_NULLPTR);
  Scenario(QString name, QObject* parent = Q_NULLPTR);
  ~Scenario();

  using ActionQueue = biogears::ConcurrentQueue<std::queue<biogears::SEAction>>;
  using Channel = biogears::scmp::Channel<ActionQueue>;
  using Source = biogears::scmp::Source<ActionQueue>;

  Q_INVOKABLE QString patient_name();
  Q_INVOKABLE QString environment_name();

  Q_INVOKABLE Scenario& patinet_name(QString&);
  Q_INVOKABLE Scenario& environment_name(QString&);


  Q_INVOKABLE State get_physiology_state();
  Q_INVOKABLE Metrics get_pysiology_metrics();
  Q_INVOKABLE Conditions get_pysiology_conditions();
  Q_INVOKABLE double get_simulation_time();

  void run() final;
  void stop() final;
  void join() final;
  void step() final;
  std::function<void(void)> step_as_func() final;

  Source get_channel();

signals:
  void stateChanged();
  void metricsChanged();
  void conditionsChanged();
  void timeAdvance();

protected:
  void physiology_thread_main();
  void physiology_thread_step();

private:
  std::thread _thread;
  biogears::Logger _logger;
  std::unique_ptr<biogears::BioGears> _engine;
  Channel _action_queue;

  std::atomic<bool> _running = false;
  std::atomic<bool> _throttle = true;
};

}
