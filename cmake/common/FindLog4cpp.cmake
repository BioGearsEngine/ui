#.rst:
# FindLog4cpp
# --------
#
# Find Log4cpp
#
# Find the native Log4cpp headers and libraries.
#
# ::
#
#   Log4cpp_INCLUDE_DIRS   - where to find Log4cpp/Log4cpp.h, etc.
#   Log4cpp_LIBRARIES      - List of libraries when using Log4cpp.
#   Log4cpp_FOUND          - True if Log4cpp found.
#   Log4cpp_VERSION_STRING - the version of Log4cpp found (since CMake 2.8.8)


# Look for the header file.
find_path(Log4cpp_INCLUDE_DIR 
      NAMES log4cpp/Category.hh
      PATH_SUFFIXES
       log4cpp
       include/log4cpp
       DOC "Log4cpp Include Path"
)
# Look for the library (sorted from most current/relevant entry to least).
find_library(Log4cpp_LIBRARY_RELEASE NAMES
    log4cpp
    liblog4cpp

  PATH_SUFFIX  release
  DOC "Log4cpp Release Library. Prefered over DLL"
)
# Look for the library (sorted from most current/relevant entry to least).
find_library(Log4cpp_LIBRARY_DEBUG NAMES
    log4cpp_d
    liblog4cpp_d
    log4cpp
    liblog4cpp
.a
  PATH_SUFFIX  debug
  DOC "Log4cpp Debug Library. Prefered over DLL"
)


# handle the QUIETLY and REQUIRED arguments and set Log4cpp_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(Log4cpp
                                  REQUIRED_VARS Log4cpp_LIBRARY_DEBUG 
                                                Log4cpp_LIBRARY_RELEASE 
                                                Log4cpp_INCLUDE_DIR
                                  )

if(Log4cpp_FOUND)
  set(Log4cpp_LIBRARIES optimized ${Log4cpp_LIBRARY_RELEASE} debug ${Log4cpp_LIBRARY_DEBUG})
  
  set(Log4cpp_INCLUDE_DIRS ${Log4cpp_INCLUDE_DIR})
  mark_as_advanced(Log4cpp_LIBRARY_DEBUG)
  mark_as_advanced(Log4cpp_LIBRARY_RELEASE)
  mark_as_advanced(Log4cpp_INCLUDE_DIR)
endif()
