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

#include <biogears/exports.h>

namespace biogears {

std::string version_string();
std::string full_version_string();

std::string project_name();
std::string rev_hash();
std::string rev_tag();

int rev_offset();

int biogears_major_version();
int biogears_minor_version();
int biogears_patch_version();

bool biogears_offical_release();

std::string rev_commit_date();;
std::string build_date();


}
