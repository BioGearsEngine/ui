#pragma once

#include <QObject>

namespace bio {

struct State {
  bool alive = false;
  bool tacycardia = false;

  bool operator==(const State& rhs) const { return alive == rhs.alive && tacycardia == rhs.tacycardia; }
  bool operator!=(const State& rhs) const { return !(*this == rhs); }

private:
  Q_GADGET
  Q_PROPERTY(bool alive MEMBER alive)
  Q_PROPERTY(bool tacycardia MEMBER tacycardia)
};

struct Conditions {
  bool diabieties = false;

  bool operator==(const Conditions& rhs) const { return diabieties == rhs.diabieties; }
  bool operator!=(const Conditions& rhs) const { return !(*this == rhs); }

private:
  Q_GADGET
  Q_PROPERTY(bool diabieties MEMBER diabieties)
};

struct Metrics {
  double respretory_rate_bpm = 0.0;
  double heart_rate_bpm = 0.0;

  bool operator==(const Metrics& rhs) const { return respretory_rate_bpm == rhs.respretory_rate_bpm && heart_rate_bpm == rhs.heart_rate_bpm; }
  bool operator!=(const Metrics& rhs) const { return !(*this == rhs); }

private:
  Q_GADGET
  Q_PROPERTY(double respretory_rate_bpm MEMBER respretory_rate_bpm)
  Q_PROPERTY(double heart_rate_bpm MEMBER heart_rate_bpm)
};


}
Q_DECLARE_METATYPE(bio::State)
Q_DECLARE_METATYPE(bio::Conditions)
Q_DECLARE_METATYPE(bio::Metrics)
