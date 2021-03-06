#pragma once

#include <QAbstractItemModel>
#include <QString>
#include <QVariant>
#include <QVector>

#include <biogears/cdm/properties/SEScalar.h>
#include <biogears/cdm/properties/SEUnitScalar.h>

class PhysiologyRequest {
public:
  PhysiologyRequest();
  PhysiologyRequest(QString prefix, QString name, bool enabled = false, PhysiologyRequest* parent = nullptr);
  ~PhysiologyRequest();

  QString name() const;
  void name(const QString& value);

  QString display_name() const;
  void display_name(const QString& value);

  bool usable() const;
  void usable(bool value);

  int rate() const;
  void rate(int value);

  int nested() const;
  void nested(int value);

  int rows() const;
  int columns() const;

  bool enabled() const;
  void enabled(bool value);

  bool auto_scale() const;
  void auto_scale(bool value);

  double y_max() const;
  void y_max(double value);

  double y_min() const;
  void y_min(double value);

  double x_interval() const;
  void x_interval(double value);

  bool custom() const;
  void custom(std::function<double(void)>&& value, std::function<QString(void)>&& unit);

  biogears::SEUnitScalar const * unit_scalar() const;
  void unit_scalar(biogears::SEUnitScalar*);

  QString unit() const;
  void unit(QString u);

  biogears::SEScalar const* scalar() const;
  void scalar(biogears::SEScalar*);

 void clear();
  PhysiologyRequest const* parent() const;
  PhysiologyRequest* parent();
  PhysiologyRequest* child(int row);
  PhysiologyRequest const* child(int row) const;

  QString header(int col) const;
  PhysiologyRequest* append(QString prefix, QString name, QString display = "", bool enabled = false, bool usable = true);
  void modify(int row, const biogears::SEUnitScalar* data);
  void modify(int row, const biogears::SEScalar* data);
  void modify(int row, int refreshRate);
  void modify(int row, bool enabled);

  QVariant data(int role) const;

  bool operator==(const PhysiologyRequest& rhs)
  {
    return _name == rhs._name
      && _prefix == rhs._prefix;
  }
  bool operator!=(const PhysiologyRequest& rhs)
  {
    return !(*this == rhs);
  }
  void scalar(biogears::SEScalar const* given)
  {
    _scalar = given;
    _unit_scalar = nullptr;
  };
  void unit_scalar(biogears::SEUnitScalar const* given)
  {
    _unit_scalar = given;
    _scalar = nullptr;
  };

private:
  PhysiologyRequest* _parent = nullptr;

  QVector<PhysiologyRequest> _children;
  QString _prefix;
  QString _name;
  QString _display_name;
  QString _unit;
  bool _unit_override = false;    //When user request unit different than base unit stored on _unit_scalar
  bool _usable = false;
  bool _enabled = false;
  bool _custom = false;
  bool _nested = false;
  int _refresh_rate = 10;
  bool _auto_scale;
  double _y_max;
  double _y_min;
  double _x_interval;
  biogears::SEScalar const* _scalar = nullptr;
  biogears::SEUnitScalar const* _unit_scalar = nullptr;
  

  std::function<double(void)> _customValueFunc;
  std::function<QString(void)> _customUnitFunc;
};
