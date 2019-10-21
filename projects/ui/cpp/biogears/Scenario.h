#pragma once
#include <functional>

#include <QString>

#include <biogears/engine/BioGearsPhysiologyEngine.h>
#include <biogears/threading/steppable.h>
#include <biogears/threading/runnable.h>  
//#include <biogears/framework/scmp/scmp_channel.h>
namespace bio {
struct State
{
  bool alive;
  bool tacycardia;
};
struct Conditions {
  bool diabieties;
};
struct Metrics {
  double respretory_rate_bpm;
  double heart_rate_bpm;
};

class Scenario : public biogears::Runnable, public biogears::Steppable<void(void)> {
public:
  Scenario(QString name);
  ~Scenario();

  QString patient_name();
  QString environment_name();
  QString config_file();
  
  Scenario& patinet_name(QString&);
  Scenario& environment_name(QString&);
  Scenario& config_file(QString&);
  
  State get_physiology_state() &;
  Metrics get_pysiology_metrics() &;

  void run() final;
  void stop() final;
  void join() final;
  void step() final;
  std::function<void(void)> step_as_func() final;

  //biogears::scmp::Source<biogears::SEAction> get_channel();

protected:
  //void physiology_thread_main();
  //void physiology_thread_step();
private:
  std::thread _thread;
  biogears::Logger _logger;
  std::unique_ptr<biogears::PhysiologyEngine> _engine;
  //biogears::scmp::Channel<biogears::SEAction> _action_queue;

  std::atomic<bool> _running = false;
  std::atomic<bool> _throttle = true;

};
}