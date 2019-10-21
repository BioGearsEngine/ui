#pragma once
#include <functional>

#include <QString>
#include <QtQuick>

#include <biogears/cdm/scenario/SEAction.h>
#include <biogears/container/concurrent_queue.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>
#include <biogears/framework/scmp/scmp_channel.h>
#include <biogears/threading/runnable.h>
#include <biogears/threading/steppable.h>
namespace bio {
struct State {
  Q_GADGET
  bool alive;
  bool tacycardia;

  Q_PROPERTY(bool alive MEMBER alive)
  Q_PROPERTY(bool tacycardia MEMBER tacycardia)
};
struct Conditions {
  Q_GADGET
  bool diabieties;
  Q_PROPERTY(bool diabieties MEMBER diabieties)
};
struct Metrics {
  Q_GADGET
  double respretory_rate_bpm;
  double heart_rate_bpm;
  Q_PROPERTY(double respretory_rate_bpm MEMBER respretory_rate_bpm)
  Q_PROPERTY(double heart_rate_bpm MEMBER heart_rate_bpm)
};

class Scenario : public QObject, public biogears::Runnable, public biogears::Steppable<void(void)> {
  Q_OBJECT
  Q_PROPERTY(State state READ get_physiology_state NOTIFY stateChanged)
  Q_PROPERTY(Metrics metrics READ get_pysiology_metrics NOTIFY metricsChanged)
  Q_PROPERTY(Conditions conditions READ get_pysiology_conditions NOTIFY conditionsChanged)
  Q_PROPERTY(double time READ get_simulation_time NOTIFY timeAdvance)

public:
  Scenario(QString name);
  ~Scenario();

  using ActionQueue = biogears::ConcurrentQueue<std::queue<biogears::SEAction>>;
  using Channel = biogears::scmp::Channel<ActionQueue>;
  using Source = biogears::scmp::Source<ActionQueue>;

  QString patient_name();
  QString environment_name();
  QString config_file();

  Scenario& patinet_name(QString&);
  Scenario& environment_name(QString&);
  Scenario& config_file(QString&);

  State get_physiology_state();
  Metrics get_pysiology_metrics();
  Conditions get_pysiology_conditions();
  double get_simulation_time();

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
  std::unique_ptr<biogears::PhysiologyEngine> _engine;
  Channel _action_queue;

  std::atomic<bool> _running = false;
  std::atomic<bool> _throttle = true;
};
}
