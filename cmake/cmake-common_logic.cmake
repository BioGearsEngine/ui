if( NOT CMAKE_DEBUG_POSTFIX )
  set( CMAKE_DEBUG_POSTFIX "_d" CACHE STRING "This string is appended to target names in debug mode." FORCE )
endif()
if( NOT CMAKE_BUILD_TYPE )
  set(CMAKE_BUILD_TYPE Debug FORCE )
  set(BUILD_OPTIONS_STRINGS
    "Debug"
    "Release"
  ) 
  if(ANDROID)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Release;Debug" FORCE)
  else()
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Release;Debug" FORCE)
  endif()
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${BUILD_OPTIONS_STRINGS})
endif()

if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set (CMAKE_INSTALL_PREFIX "${_ROOT}/usr" CACHE PATH "default install path" FORCE )
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

set(CMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS 1)
set(CMAKE_CXX_USE_RESPONSE_FILE_FOR_INCLUDES 1)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY AUTOGEN_TARGETS_FOLDER "Code Generators" )
set_property(GLOBAL PROPERTY AUTOGEN_SOURCE_GROUP  "Generated")

####
#
#  A simple macro to check for PACKAGE_FOUND and warn the user to 
#
####
function(verify_package package)
  find_package(${package})
  if(NOT ${package}_FOUND)
      message(WARNING "The following packages ${package} were not found."
        " If this continues you may need to set your CMAKE_FIND_ROOT_PATH to include any non standard system directories where your third party deps might be found"
        "")
  endif()
  find_package(${package} ${ARGN})
endfunction(verify_package)
####
#
#  Simple macro for taking a list of header files and asking them to be included
#
####
function(install_headers header_list out_dir)

    FOREACH(HEADER ${${header_list}})
        STRING(REGEX MATCH "(.\\\*)\\\[/\\\]" DIR ${HEADER})
        INSTALL(FILES ${HEADER} DESTINATION ${out_dir}/${DIR})
    ENDFOREACH(HEADER)

endfunction()
########################################################################################################
# 
# Source File Managment Macros
# 
########################################################################################################
function(CHILDLIST result curdir)
  file(GLOB children RELATIVE ${curdir} ${curdir}/*)
  set(dirlist "")
  foreach(child ${children})
    if(IS_DIRECTORY ${curdir}/${child})
      list(APPEND dirlist ${child})
    endif()
  endforeach()
  set(${result} ${dirlist} PARENT_SCOPE)
endfunction()

function(add_source_files var prefix regex source_group)
    message(STATUS "add_source_files( ${var} \"${prefix}\" ${regex} \"${source_group}\")")
    file(GLOB TEMP "${prefix}/${regex}")

    source_group("${source_group}" FILES ${TEMP})

    CHILDLIST( result ${prefix})
    
    foreach( dir IN LISTS result)
#     message(STATUS "add_source_files( ${var} \"${prefix}/${dir}\" ${regex} \"${source_group}\\${dir}\")")
      add_source_files( ${var} "${prefix}/${dir}" ${regex} "${source_group}${dir}\\")
    endforeach()

    set(${var} ${${var}} ${TEMP} PARENT_SCOPE)
endfunction()

########################################################################################################
#
# Remove Duplicate LIbraries
#
########################################################################################################
function(remove_duplicate_libraries libraries)
  list(LENGTH ${libraries} LIST_LENGTH)
  while( ${libraries} )
     list(GET ${libraries} 0 item )
     if( item STREQUAL debug)
        list(GET ${libraries} 1 item )
        list(REMOVE_AT ${libraries} 0 1 )
        list(APPEND debug_libraries  ${item})
     elseif( item STREQUAL optimized)
        list(GET ${libraries} 1 item )
        list(REMOVE_AT ${libraries} 0 1 )
        list(APPEND release_libraries  ${item})
     else()
        list(REMOVE_AT ${libraries} 0 )
        list(APPEND common_libraries ${item})
     endif()  
  endwhile()
  if(common_libraries)
    list(REMOVE_DUPLICATES common_libraries)
  endif()
  if(release_libraries)
    list(REMOVE_DUPLICATES release_libraries)
   endif()
  if(debug_libraries)
    list(REMOVE_DUPLICATES debug_libraries)
   endif()
  set( results )
  foreach( item IN LISTS release_libraries)
    list(APPEND results "optimized" ${item})
  endforeach()
  
  foreach( item IN LISTS debug_libraries)
    list(APPEND results "debug" ${item})
  endforeach()
  
  set( ${libraries} ${common_libraries} ${results} PARENT_SCOPE)
endfunction()
########################################################################################################
# 
# Git Version Macro
# 
# List Tags in the order they appear assumes the version of the project is the latest version split by '.'
# Creates the following variabels
#
# ${ROOT_PROJECT_NAME}_VERSION_MAJOR  #First group of characters in the split
# ${ROOT_PROJECT_NAME}_VERSION_MINOR  #Second group of characters in the split
# ${ROOT_PROJECT_NAME}_VERSION_PATCH  #Third set of characters in the split
# ${ROOT_PROJECT_NAME}_VERSION_TWEAK  #Forth set of characters in the split
# ${ROOT_PROJECT_NAME}_VERSION_TAG    #A string tag based on how dirty the tag is usually -dirty 
# ${ROOT_PROJECT_NAME}_VERSION_HASH   #Abriviated Git Hash for the specific commit
# ${ROOT_PROJECT_NAME}_LIB_VERSION    #MAJOR.MINOR.PATCH - This really only works if your tags use this format
# ${ROOT_PROJECT_NAME}_DIRTY_BUILD    #True if the number of commits since the last tag is greater then 0
# ${ROOT_PROJECT_NAME}_COMMIT_DATE    #Date of the latest commit in the repo git  log -1 --format=%ai 
#
########################################################################################################

function(configure_version_information _SUCESS_CHECK)
  cmake_parse_arguments( "_"  "" "MAJOR;MINOR;PATCH;TWEAK"
                         "" ${ARGN} )

  if(NOT _MAJOR) 
    set(_MAJOR -1)
  endif()
  if(NOT _MINOR) 
    set(_MINOR -1)
  endif()
  if(NOT _PATCH) 
    set(_PATCH -1)
  endif()
  if(NOT _TWEAK) 
    set(_TWEAK  "source" )
  endif()
  execute_process(COMMAND ${GIT_EXECUTABLE}  describe --tags
                  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                  OUTPUT_VARIABLE _GIT_REV
                  RESULT_VARIABLE  _RESULT_VARIABLE
                                  ERROR_QUIET)
  
  if(_RESULT_VARIABLE EQUAL 0)
    message(STATUS "GIT_REV=${_GIT_REV}")
    string(REPLACE "-" ";"  _GIT_REV_LIST "${_GIT_REV}" )
    string(REPLACE "." ";"  _GIT_FULL_REV_LIST "${_GIT_REV_LIST}") 
    list(LENGTH _GIT_FULL_REV_LIST _len)

    list(GET _GIT_REV_LIST 0 _VERSION_TAG)
    if(_len GREATER 0)
      list(GET _GIT_FULL_REV_LIST 0 _VERSION_MAJOR)
    endif()
    if(_len GREATER 1)
      list(GET _GIT_FULL_REV_LIST 1 _VERSION_MINOR)
    endif()
    if(_len GREATER 2)
      list(GET _GIT_FULL_REV_LIST 2 _VERSION_PATCH)
    endif()
    if(_len GREATER 4)
      set(_DIRTY_BUILD true)
      list(GET _GIT_FULL_REV_LIST 3 _VERSION_TWEAK)
      math(EXPR _last "${_len} - 1")
      list(GET _GIT_FULL_REV_LIST ${_last}  _VERSION_HASH )
      
    else()
      set(_DIRTY_BUILD false)
      set(_VERSION_TWEAK 0)
      list(GET _GIT_FULL_REV_LIST 3 _VERSION_HASH )
    endif()
    string(STRIP "${_VERSION_HASH}" _VERSION_HASH )
 

    set( ${ROOT_PROJECT_NAME}_VERSION_TAG ${_VERSION_TAG} PARENT_SCOPE)
    if( _VERSION_MAJOR MATCHES "[0-9]+")
	    set( ${ROOT_PROJECT_NAME}_VERSION_MAJOR ${_VERSION_MAJOR} PARENT_SCOPE)
    else()
      set( ${ROOT_PROJECT_NAME}_VERSION_MAJOR ${_MAJOR} PARENT_SCOPE)  
    endif()
    if( _VERSION_MINOR MATCHES "[0-9]+")
      set( ${ROOT_PROJECT_NAME}_VERSION_MINOR ${_VERSION_MINOR} PARENT_SCOPE)
    else()
      set( ${ROOT_PROJECT_NAME}_VERSION_MINOR ${_MINOR} PARENT_SCOPE)  
    endif()
    if( _VERSION_PATCH MATCHES "[0-9]+")
      set( ${ROOT_PROJECT_NAME}_VERSION_PATCH ${_VERSION_PATCH} PARENT_SCOPE)
    else()
      set( ${ROOT_PROJECT_NAME}_VERSION_PATCH ${_PATCH} PARENT_SCOPE)  
    endif()
    if( _VERSION_TWEAK MATCHES "[0-9]+")
      set( ${ROOT_PROJECT_NAME}_VERSION_TWEAK ${_VERSION_TWEAK} PARENT_SCOPE)
    else()
      set( ${ROOT_PROJECT_NAME}_VERSION_TWEAK ${_TWEAK} PARENT_SCOPE)  
    endif()
    set( ${ROOT_PROJECT_NAME}_VERSION_HASH  ${_VERSION_HASH}  PARENT_SCOPE)
    set( ${ROOT_PROJECT_NAME}_DIRTY_BUILD ${_DIRTY_BUILD} PARENT_SCOPE)
    set( ${ROOT_PROJECT_NAME}_LIB_VERSION "${_VERSION_MAJOR}.${_VERSION_MINOR}" PARENT_SCOPE)
    set( ${_SUCESS_CHECK} True PARENT_SCOPE)
    
    execute_process(COMMAND ${GIT_EXECUTABLE}  log -1 --format=%ai 
                    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                    OUTPUT_VARIABLE _GIT_COMMIT_DATE
                    RESULT_VARIABLE _RESULT_VARIABLE
                                    ERROR_QUIET)
    
    string(STRIP "${_GIT_COMMIT_DATE}" _GIT_COMMIT_DATE)
    set (${ROOT_PROJECT_NAME}_COMMIT_DATE "${_GIT_COMMIT_DATE}" PARENT_SCOPE)


  endif()
endfunction(configure_version_information)

########################################################################################################
# 
# Appends a suffix to the project name to make it easier to tell worktree solutions apart
# 
# Will additionally append the MSVC version to the solution if it is of version 14-16
# Creates the following variabels
#
# ${CMAKE_PROJECT_NAME}_SUFFIX        #The value of this variable is appended to the solution name
#                                     #For Cmake Generators who use the project name in the output files
#                                     It is useful for determining which MSVC sln you are loading from 
#                                     the jump list
#
# __PROJECT_SUFFIX_SET                This control variable is set in PARENT_SCOPE to prevent calling 
#                                     of the function twice
#
########################################################################################################
function(generate_project_suffix)
if(MSVC AND NOT __PROJECT_SUFFIX_SET)
  set(__PROJECT_SUFFIX_SET ON PARENT_SCOPE)
  if(${CMAKE_PROJECT_NAME}_PROJECT_SUFFIX)
    project(${CMAKE_PROJECT_NAME}_${${CMAKE_PROJECT_NAME}_PROJECT_SUFFIX})
  endif()
  if(MSVC_VERSION GREATER_EQUAL 1920)
    project(${CMAKE_PROJECT_NAME}_msvc16)
  elseif(MSVC_VERSION GREATER_EQUAL 1910)
    project(${CMAKE_PROJECT_NAME}_msvc15)
  elseif(MSVC_VERSION GREATER_EQUAL 1900)
    project(${CMAKE_PROJECT_NAME}_msvc14)
    project(cmake-test_msvc15)
  endif()
endif()
endfunction()
#######################################################################################################
# 
#  By default cmake setups up multi configuration directories as {lib,bin}/{debug,release}/<product>
#  This just sets it to {debug,release}/{lib,bin}/<product> which is more natural to me.
# 
#  Optional Cache Value OUTPUT_PREFIX allows you add an additional later to this layout
#######################################################################################################
function(setup_unified_output_directory )
  cmake_parse_arguments( "_"  "UNIFIED" "PREFIX"
                         "" ${ARGN} )
if(NOT __UNIFIED_DIR) 
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${_PREFIX}/$<CONFIG>/lib" PARENT_SCOPE)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${_PREFIX}/$<CONFIG>/$<IF:$<PLATFORM_ID:Windows>,bin,lib>" PARENT_SCOPE)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${_PREFIX}/$<CONFIG>/bin" PARENT_SCOPE)
  set(__UNIFIED_DIR ON PARENT_SCOPE)
endif()
endfunction()