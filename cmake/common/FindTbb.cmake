# Copyright (c) 2017 Steven A Whtie
# This file is MIT licensed.
# See http://opensource.org/licenses/MIT

# Tbb_FOUND
# Tbb_INCLUDE_DIR
# Tbb_LIBRARIES

#################################################################################
# Includes
#################################################################################
find_path(Tbb_INCLUDE_DIR 
  NAMES tbb_stddef.h 
  PATH tbb
)
#################################################################################
# Libraries
#################################################################################
find_library(Tbb_MALLOC_LIBRARY_DEBUG 
  NAMES tbbmalloc_debug tbbmalloc
  PATH_SUFFIXES debug
)
find_library(Tbb_MALLOC_LIBRARY 
  NAMES tbbmalloc
  PATH_SUFFIXES release
)
find_library(Tbb_LIBRARY_DEBUG 
  NAMES tbb_debug tbb
  PATH_SUFFIXES debug
)
find_library(Tbb_LIBRARY 
  NAMES tbb
  PATH_SUFFIXES release
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Tbb
                                REQUIRED_VARS 
                                     Tbb_INCLUDE_DIR
                                     Tbb_MALLOC_LIBRARY_DEBUG
                                     Tbb_MALLOC_LIBRARY
                                     Tbb_LIBRARY_DEBUG
                                     Tbb_LIBRARY
)

if(Tbb_FOUND)
  mark_as_advanced(Tbb_INCLUDE_DIR)
  mark_as_advanced(Tbb_MALLOC_LIBRARY_DEBUG)
  mark_as_advanced(Tbb_MALLOC_LIBRARY)
  mark_as_advanced(Tbb_LIBRARY_DEBUG)
  mark_as_advanced(Tbb_LIBRARY)

  set (Tbb_LIBRARIES  debug ${Tbb_MALLOC_LIBRARY_DEBUG} 
                      optimized ${Tbb_MALLOC_LIBRARY} 
                      debug ${Tbb_LIBRARY_DEBUG} 
                      optimized ${Tbb_LIBRARY} )
  set (Tbb_INCLUDE_DIRS ${Tbb_INCLUDE_DIR})
endif(Tbb_FOUND)
