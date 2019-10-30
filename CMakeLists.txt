###############################################################################
# CMAKE DEFINITIONS AND setTINGS
#
# Requires the following environmental variables:
#
#   BUILD TYPE      ENV VARIABLE        Description
#   ANDROID         ANDROID_NDK         Android NDK root folder location
#                                           (also required for toolchain file)
#   ANDROID         GRADLE_EXECUTABLE   Location of the Gradle executable
###############################################################################
set(ROOT_PROJECT_NAME Visualizer)
set(${ROOT_PROJECT_NAME}_CMAKE_MIN_VERSION 3.11.0)
set(${ROOT_PROJECT_NAME}_CMAKE_POLICY 3.11.0)

cmake_minimum_required(VERSION ${${ROOT_PROJECT_NAME}_CMAKE_MIN_VERSION})

set(${ROOT_PROJECT_NAME}_VERSION_MAJOR 0)
set(${ROOT_PROJECT_NAME}_VERSION_MINOR 1)
set(${ROOT_PROJECT_NAME}_VERSION_PATCH 0)
set(${ROOT_PROJECT_NAME}_VERSION_TAG  "-beta")

include(cmake/cmake-common_logic.cmake)
################################################################################
# STEP 1: 
# Change this to custimize your project
################################################################################
project( ${ROOT_PROJECT_NAME}  LANGUAGES CXX C)


 list(APPEND CMAKE_MODULE_PATH  ${PROJECT_SOURCE_DIR}/cmake  ${PROJECT_SOURCE_DIR}/cmake/common)
 list(APPEND CMAKE_PREFIX_PATH  )
 list(APPEND CMAKE_LIBRARY_PATH )
 list(APPEND CMAKE_INCLUDE_PATH )
 list(APPEND CMAKE_FIND_ROOT_PATH   ${PROJECT_SOURCE_DIR}/cmake/common)

 message(STATUS "
    Using the following search paths
    CMAKE_MODULE_PATH = ${CMAKE_MODULE_PATH}
    CMAKE_PREFIX_PATH  = ${CMAKE_PREFIX_PATH}
    CMAKE_LIBRARY_PATH = ${CMAKE_LIBRARY_PATH}
    CMAKE_INCLUDE_PATH = ${CMAKE_INCLUDE_PATH}
    CMAKE_FIND_ROOT_PATH = ${CMAKE_FIND_ROOT_PATH}
    ")

find_package(Git)
if(Git_FOUND)
  configure_version_information(GIT_SUCESS)
endif()
if(NOT GIT_SUCESS)
  # Update these variables to ensure out of source build have some sane tags
  message(WARNING "GIT_EXECUTABLE was not found or no corrisponding GIT_REPO is avaliable.\n" 
    "If you are building with in a git repo you should ensure GIT is in your current path. " 
	"If you are building outside of a repo ignore this message.")
  set(${ROOT_PROJECT_NAME}_VERSION_MAJOR 0)
  set(${ROOT_PROJECT_NAME}_VERSION_MINOR 0)
  set(${ROOT_PROJECT_NAME}_VERSION_PATCH 2)
  set(${ROOT_PROJECT_NAME}_VERSION_TWEAK 0)
  set(${ROOT_PROJECT_NAME}_LIB_VERSION ${${ROOT_PROJECT_NAME}_VERSION_MAJOR}.${${ROOT_PROJECT_NAME}_VERSION_MINOR} )
  set(${ROOT_PROJECT_NAME}_VERSION_TAG "Beta")
  set(${ROOT_PROJECT_NAME}_DIRTY_BUILD true)

  string(TIMESTAMP ${ROOT_PROJECT_NAME}_COMMIT_DATE "%Y-%m-%d %H:%M")
endif()
############################# ##################################################
# Add Repository Subdirectories
###############################################################################
add_subdirectory(projects)
set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT BioGearsUI)
###############################################################################
# Step 2:
# You likely need to add on project to stage for every executable you would like
# to stage (AKA move dep DLLs to the run folder for debugging.
################################################################################
if(${ROOT_PROJECT_NAME}_BUILD_${ROOT_PROJECT_NAME})
add_dependencies(STAGE ${ROOT_PROJECT_NAME})
endif()

###############################################################################
# Step 3:
# Infrastructure Installation for each library
# your project outputs create a Find${lib}.cmake file
# list them here. This will install them in your sysroot
# so other projects can build off those libraries
###############################################################################
install(FILES cmake/Find${ROOT_PROJECT_NAME}.cmake
        DESTINATION cmake/)

generate_project_suffix()
