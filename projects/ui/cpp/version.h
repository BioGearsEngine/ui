/**************************************************************************************
Copyright 2019 Applied Research Associates, Inc.
Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the License
at:
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
**************************************************************************************/

#pragma once
#include <iostream>
#include <sstream>
#include <string>

#include <QObject>
#include <QString>

#include <biogears/exports.h>

namespace bgui {

  QString version_string();
  QString full_version_string();
  QString project_name();
  QString rev_hash();
  QString rev_tag();

  int bgui_major_version();
  int bgui_minor_version();
  int bgui_patch_version();

  bool bgui_offical_release();

  QString rev_commit_date();
  QString biogears_build_date();


class SystemInformation : public QObject {

 public:
  QString about();


signals:
  void aboutChanged();
 private:
  Q_OBJECT
public:
  //This Codes Library Info
  Q_PROPERTY(QString About  READ about NOTIFY aboutChanged)

};

}
