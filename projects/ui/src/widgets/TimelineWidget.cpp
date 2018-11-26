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
//! \author Matt McDaniel
//! \date   Aug 24 2018
//!
//!
//! \brief Graphical timeline of scenario actions for BioGears UI

#include "TimelineWidget.h"
//External Includes
#include <QLabel>
#include <QLayout>
#include <QLineEdit>
#include <QScrollArea>
#include <QScrollBar>
#include <QT>
#include <QTextEdit>

namespace biogears_ui {

struct DrawProperties {
  float margin;
  float scale;
};

struct TimelineWidget::Implementation : QObject {
public:
  Implementation(QWidget* config);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  void drawShadowRegion(QPainter& painter);
public slots:
  void processLengthChanged();
  void processPaintEvent(QPaintEvent*);

public:
  std::map<ActionData, TimelineEntry*> elementsMap;

  double timeline_length;
  double current_time =0.0;
  int pen_width;

  QSize timeline_demensions;
  QSize minmap_demensions;
  QSize scroll_demensions;
  float screen_dpi;
  DrawProperties timeline_config;

  QColor pen_color;
  QBrush background_brush;

  QLineEdit* f_timeline_length;
  QLabel* l_timeline;
  QLabel* l_minmap;
  QLabel* l_timeline_length;
  QScrollBar* scroll_bar;
};

TimelineWidget::Implementation::Implementation(QWidget* parent)
  : l_timeline(new QLabel(parent))
  , l_minmap(new QLabel(parent))
  , l_timeline_length(new QLabel("Timeline Length", parent))
  , f_timeline_length(new QLineEdit(parent))
  , timeline_demensions(parent->size().width(), 250)
  , minmap_demensions(parent->size().width(), 50)
  , scroll_demensions(parent->size().width(), 250)
  , scroll_bar(new QScrollBar(Qt::Horizontal, parent))
{

  //Widget Layout
  QVBoxLayout* vlayout = new QVBoxLayout;
  parent->setLayout(vlayout);
  //parent->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);

  QWidget* horizontal_layout_object = new QWidget(parent);
  QHBoxLayout* hlayout = new QHBoxLayout;
  horizontal_layout_object->setLayout(hlayout);
  hlayout->addWidget(l_timeline_length);
  hlayout->addWidget(f_timeline_length);
  vlayout->addWidget(horizontal_layout_object);
  vlayout->addWidget(l_timeline);
  vlayout->addWidget(scroll_bar);
  vlayout->addWidget(l_minmap);
  vlayout->addStretch(1);// (new QSpacerItem(1, 1, QSizePolicy::Maximum, QSizePolicy::Maximum));

  //Element Configurations
  f_timeline_length->setValidator(new QIntValidator);

  l_timeline->setBackgroundRole(QPalette::Base);
  //l_timeline->setSizePolicy(QSizePolicy::Maximum, QSizePolicy::Fixed);
  l_timeline->setScaledContents(true);

  l_minmap->setBackgroundRole(QPalette::BrightText);
  //_minmap->setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Fixed);
  l_minmap->setScaledContents(true);

  scroll_bar->setBackgroundRole(QPalette::Dark);
  scroll_bar->setVisible(true);
  //scroll_bar->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Maximum);
  scroll_bar->setMinimum(0);
  scroll_bar->setMaximum(timeline_demensions.width() - scroll_demensions.width());
  scroll_bar->setPageStep(scroll_demensions.width());

  QPixmap timeline(timeline_demensions);
  QPixmap minmap(minmap_demensions);

  //Setup Drawing Surfaces
  l_timeline->setPixmap(timeline);
  l_minmap->setPixmap(minmap);

  //Paramaters
  screen_dpi = QGuiApplication::primaryScreen()->logicalDotsPerInch();
  timeline_config.margin = (1. / 8.) * screen_dpi;

  timeline_length = 0.0;
  pen_width = 3;
  pen_color = Qt::GlobalColor::darkBlue;
  background_brush = QBrush(Qt::GlobalColor::white, Qt::BrushStyle::SolidPattern);
}
//-------------------------------------------------------------------------------
TimelineWidget::Implementation::Implementation(const Implementation& obj)

{
  *this = obj;
}
//-------------------------------------------------------------------------------
TimelineWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
TimelineWidget::Implementation& TimelineWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
TimelineWidget::Implementation& TimelineWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//---------------------------------------------------------------------------------
void TimelineWidget::Implementation::drawShadowRegion(QPainter& painter)
{
  {
    double bar_position, page_step;

    double timeline_width = timeline_demensions.width();
    double minmap_width = minmap_demensions.width();

    if (timeline_width < minmap_width) {
      bar_position = 0;
      page_step = timeline_width;
    } else {
      auto pos = scroll_bar->sliderPosition();
      auto step = scroll_bar->pageStep();
      bar_position = (minmap_width / timeline_width) * pos;
      page_step = (minmap_width / timeline_width) * step;
    }
    auto w_start = static_cast<int>(bar_position);
    auto w_end = static_cast<int>(page_step);
    QRect rect{ w_start, 0, w_end, minmap_demensions.height() };
    painter.setPen(Qt::lightGray);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.fillRect(rect, Qt::Dense6Pattern);
  }
}

//---------------------------------------------------------------------------------
void TimelineWidget::Implementation::processPaintEvent(QPaintEvent* event)
{
  //TODO: Match timeline to scroll_area.rect
  QPixmap timeline{ scroll_demensions };
  QPainter timeline_painter{ &timeline };

  int timeline_width = timeline_demensions.width();
  int minmap_width = l_minmap->width();

  QPixmap minmap{ minmap_width, 50 };
  QPainter minmap_painter{ &minmap };

  double size_ratio = static_cast<double>(minmap_width) / scroll_demensions.width();

  //Step 1: Backgrounds
  timeline_painter.fillRect(timeline.rect(), background_brush);
  minmap_painter.fillRect(minmap.rect(), background_brush);

  //Step 2: Draw Blue Lines
  timeline_painter.setPen(QPen(pen_color, pen_width));
  minmap_painter.setPen(QPen(pen_color, pen_width));

  QLine minmap_line;
  QLine timeline_line{ static_cast<int>(timeline_config.margin), timeline.size().height() / 2, scroll_demensions.width() - static_cast<int>(timeline_config.margin), timeline.size().height() / 2 };
  
  int current_pos = current_time * (timeline.size().width() - 2* timeline_config.margin)/ 10 + timeline_config.margin;

 
  if (timeline_demensions.width() < minmap_demensions.width()) {
    minmap_line.setLine(0 + static_cast<int>(timeline_config.margin), minmap.size().height(), scroll_demensions.width() - static_cast<int>(timeline_config.margin), minmap.size().height());
  } else {
    minmap_line.setLine(0 + static_cast<int>(timeline_config.margin), minmap.size().height(), minmap_width - static_cast<int>(timeline_config.margin), minmap.size().height());
  }
  minmap_painter.drawLine(minmap_line);
  timeline_painter.drawLine(timeline_line);

  timeline_painter.setPen(QPen(Qt::GlobalColor::darkYellow , pen_width));
  QLine current_line{ current_pos, 0, current_pos, timeline.size().height()/5 };
  timeline_painter.drawLine(current_line);
  current_line = QLine{ current_pos, 4* timeline.size().height() / 5, current_pos, timeline.size().height() };
  timeline_painter.drawLine(current_line);
  timeline_painter.setPen(QPen(pen_color, pen_width));

  //Step 3: Draw Events
  auto bar_position = scroll_bar->sliderPosition();
  auto page_step = scroll_bar->pageStep();
  for (const auto& actionPair : elementsMap) {
    const auto& data = actionPair.first;
    const auto& entry = actionPair.second;

    double true_x = data.at / timeline_length * timeline_demensions.width();
    if (bar_position <= true_x && true_x <= bar_position + page_step) {

      auto calc_x = true_x - bar_position;
      auto mapped_x = ((calc_x / scroll_demensions.width()) * (scroll_demensions.width() - (2 * timeline_config.margin))) + timeline_config.margin;
      entry->X(mapped_x);
      entry->drawAtFullDetail(timeline_painter);
    }

    entry->X(data.at / timeline_length * l_timeline->pixmap()->size().width());
    entry->drawAtMinmapDetail(minmap_painter, size_ratio);
  }

  //Step  4: Fill in Shadowed Area on MinMap
  drawShadowRegion(minmap_painter);

  l_minmap->setPixmap(minmap);
  l_timeline->setPixmap(timeline);
  //l_minmap->resize(minmap.width(), minmap.height());
  //l_timeline->resize(timeline.width(), timeline.height());
}
//--------------------------------------------------------------------------------
void TimelineWidget::Implementation::processLengthChanged()
{
  timeline_length = f_timeline_length->displayText().toDouble();
  timeline_demensions = QSize((timeline_length / 10.0) * screen_dpi, 250);
  scroll_bar->setMinimum(0);
  auto timeline_width = timeline_demensions.width();
  auto scroll_width = scroll_demensions.width();
  scroll_bar->setMaximum(timeline_width- scroll_width);
  scroll_bar->setPageStep(scroll_width);
}
//--------------------------------------------------------------------------------
TimelineWidget::TimelineWidget(QWidget* parent)
  : _impl(this)
{
  connect(_impl->f_timeline_length, &QLineEdit::textChanged, _impl.get(), &Implementation::processLengthChanged);
}
//---------------------------------------------------------------------------------
TimelineWidget::~TimelineWidget()
{
  _impl = nullptr;
}
//----------------------------------------------------------------------------------
void TimelineWidget::paintEvent(QPaintEvent* event)
{
  bool oldState = this->blockSignals(true);
  _impl->processPaintEvent(event);
  this->blockSignals(oldState);
}
//----------------------------------------------------------------------------------
void TimelineWidget::keyPressEvent(QKeyEvent* event)
{
  switch (event->key()) {

  case Qt::LeftArrow:
    _impl->scroll_bar->setValue(_impl->scroll_bar->value() - _impl->scroll_bar->singleStep());
    break;
  case Qt::RightArrow:
    _impl->scroll_bar->setValue(_impl->scroll_bar->value() + _impl->scroll_bar->singleStep());
    break;
  case Qt::Key_PageUp:
    _impl->scroll_bar->setValue(_impl->scroll_bar->value() - _impl->scroll_bar->pageStep());
    break;
  case Qt::Key_PageDown:
    _impl->scroll_bar->setValue(_impl->scroll_bar->value() + _impl->scroll_bar->pageStep());
    break;
  case Qt::Key_Home:
    _impl->scroll_bar->setValue(_impl->scroll_bar->minimum());
    break;
  case Qt::Key_End:
    _impl->scroll_bar->setValue(_impl->scroll_bar->maximum());
    break;
  default:
    break;
  }
}
//----------------------------------------------------------------------------------
void TimelineWidget::keyReleaseEvent(QKeyEvent*)
{
}
//----------------------------------------------------------------------------------
void TimelineWidget::resizeEvent(QResizeEvent* event)
{
  
  _impl->minmap_demensions = QSize(event->size().width() - 50, 50);
  _impl->scroll_demensions = QSize(event->size().width() - 50, 250);
  _impl->scroll_bar->setMaximum(_impl->timeline_demensions.width() - _impl->scroll_demensions.width());
  _impl->scroll_bar->setPageStep(_impl->scroll_demensions.width());
  QWidget::resizeEvent(event);

}
//----------------------------------------------------------------------------------
void TimelineWidget::clear()
{
  _impl->elementsMap.clear();
}
//----------------------------------------------------------------------------------
void TimelineWidget::addActionData(const ActionData data)
{
  if (_impl->elementsMap.find(data) == _impl->elementsMap.end()) {
    TimelineAction* sampleAction = new TimelineAction();
    sampleAction->Data(data).X(data.at / _impl->timeline_length * this->rect().width());
    _impl->elementsMap[data] = sampleAction;
  }
}
//----------------------------------------------------------------------------------
bool TimelineWidget::removeActionData(const ActionData data)
{
  bool rValue = false;
  auto itr = _impl->elementsMap.find(data);
  if (itr != _impl->elementsMap.end()) {
    _impl->elementsMap.erase(itr);

    rValue = true;
  }
  QWidget::update();
  return rValue;
}
//----------------------------------------------------------------------------------
double TimelineWidget::ScenarioLength()
{
  return _impl->timeline_length;
}
//----------------------------------------------------------------------------------
void TimelineWidget::ScenarioLength(double time)
{
  auto& impl = *_impl;
  impl.f_timeline_length->setText(QString::number(time));
  QWidget::update();
}
//----------------------------------------------------------------------------------
double TimelineWidget::CurrentTime()
{
  return _impl->current_time;
}
//----------------------------------------------------------------------------------
void TimelineWidget::CurrentTime(double time)
{
  _impl->current_time = time;
  QWidget::update();
}
//----------------------------------------------------------------------------------
void TimelineWidget::Actions(std::vector<ActionData>& actions)
{
  clear();
  for (auto& action : actions) {
    addActionData(action);
  }
  QWidget::update();
}
//----------------------------------------------------------------------------------
void TimelineWidget::addEvent(TimelineEvent* bgEvent)
{
}

//----------------------------------------------------------------------------------
auto TimelineWidget::create(QWidget* parent) -> TimelineWidgetPtr
{
  return new TimelineWidget(parent);
}
//----------------------------------------------------------------------------------
void TimelineWidget::lock()
{
  _impl->f_timeline_length->setEnabled(false);
}
//----------------------------------------------------------------------------------
void TimelineWidget::unlock()
{
  _impl->f_timeline_length->setEnabled(true);
}
}
