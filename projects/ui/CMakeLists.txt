###############################################################################
# Policy adjustments
###############################################################################
cmake_minimum_required(VERSION 3.8.0)
cmake_policy(VERSION 3.8.0)
###############################################################################
# Options
###############################################################################

###############################################################################
# Base Variables
###############################################################################
set(PROJECT_NAME BioGears)
set(PREFIX bio)

set(${PREFIX}_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include" PARENT_SCOPE)
set(${PREFIX}_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include" )
set(${PREFIX}_PRIVATE_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src" PARENT_SCOPE)
set(${PREFIX}_PRIVATE_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src" )
set(${PREFIX}_GENERATED_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}" PARENT_SCOPE)
set(${PREFIX}_GENERATED_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}" )
set(${PREFIX}_UNIT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/unit" PARENT_SCOPE)

###############################################################################
# Requirments
###############################################################################
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
if(WIN32)
  set(Boost_USE_STATIC_LIBS ON) 
endif()
find_package(Threads REQUIRED)

find_package(Boost COMPONENTS system filesystem program_options REQUIRED)
find_package(Qt5Widgets 5.10.0 REQUIRED)
find_package(BioGears REQUIRED)

if (ARA_${PREFIX}_BUILD_STATIC)
  add_definitions("-D${PREFIX}_BUILT_AS_STATIC")
  add_definitions("-DARACORE_BUILT_AS_STATIC")
endif()
###############################################################################
#Code Generation
###############################################################################

###############################################################################
#Sorce and Header Defines
###############################################################################
message(STATUS "")
message(STATUS "Configuring ${PROJECT_NAME}")

#Biogears Core
add_source_files(HDRS ${CMAKE_CURRENT_SOURCE_DIR}/src "*.h"   "Headers\\Private\\")
add_source_files(HDRS ${CMAKE_CURRENT_SOURCE_DIR}/src "*.hpp"   "Headers\\Private\\")
add_source_files(SRCS ${CMAKE_CURRENT_SOURCE_DIR}/src "*.cpp" "Sources\\")
add_source_files(SRCS ${CMAKE_CURRENT_SOURCE_DIR}/src "*.c" "Sources\\")
add_source_files(PUBLIC_HDRS ${CMAKE_CURRENT_SOURCE_DIR}/include "*.h"  "Headers\\Public\\")
add_source_files(PUBLIC_HDRS ${CMAKE_CURRENT_SOURCE_DIR}/include "*.hpp"  "Headers\\Public\\")

set(${PREFIX}_HEADERS ${HDRS} ${PUBLIC_HDRS} ${GEN_HDRS})
set(${PREFIX}_SOURCES ${SRCS} ${GEN_SRCS})

###############################################################################
#Define Logic
###############################################################################
if(WIN32)
  list(APPEND ${PREFIX}_CPPFLAGS_EXPORT )
  list(APPEND ${PREFIX}_CPPFLAGS "-D_SCL_SECURE_NO_WARNINGS" "-D_CRT_SECURE_NO_WARNINGS" /bigobj  $ENV{PARALLEL_COMPILE} )
elseif(CMAKE_COMPILER_IS_GNUCXX)
list(APPEND ${PREFIX}_CPPFLAGS_EXPORT )
  list(APPEND ${PREFIX}_CPPFLAGS  ${CodeSynthesis_CPPFLAGS})
  list(APPEND ${PREFIX}_LDFLAGS "-Wl,--no-as-needed" )
endif()

if (ARA_${PREFIX}_BUILD_STATIC)
  add_definitions("-D${PREFIX}_BUILT_AS_STATIC")
endif()

add_executable(${PROJECT_NAME} ${${PREFIX}_SOURCES} ${${PREFIX}_HEADERS})
set_target_properties(${PROJECT_NAME}
  PROPERTIES
  DEFINE_SYMBOL ${PROJECT_NAME}_EXPORTS
  FOLDER "Binaries"
  OUTPUT_NAME "${PROJECT_NAME}"
  COMPILE_PDB_NAME "${PROJECT_NAME}"
  PROJECT_LABEL "${PROJECT_NAME}"
  DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX}
  CXX_STANDARD 14
  )

###############################################################################
# COMPILATION & LINKAGE MODIFICATIONS
###############################################################################
foreach(MY_ITEM ${${PREFIX}_CPPFLAGS_EXPORT})
    TARGET_COMPILE_OPTIONS(${PROJECT_NAME}
        PUBLIC ${MY_ITEM}
    )
endforeach(MY_ITEM)
foreach(MY_ITEM ${${PREFIX}_CPPFLAGS})
    TARGET_COMPILE_OPTIONS(${PROJECT_NAME}
        PRIVATE ${MY_ITEM}
    )
endforeach(MY_ITEM)

list(APPEND ${PREFIX}_INCLUDES
      ${PREFIX}_INCLUDE_DIR
      ${PREFIX}_PRIVATE_INCLUDE_DIR
      ${PREFIX}_GENERATED_INCLUDE_DIR
      BioGears_INCLUDE_DIRS
      Boost_INCLUDE_DIRS
)
if(ARA_${PROJECT_NAME}_BUILD_JAVATOOLS)
  list(APPEND ${PREFIX}_INCLUDES   Java_JAVA_INCLUDE_DIRS )
endif()
list(REMOVE_DUPLICATES ${PREFIX}_INCLUDES)
ensure_paths_set(${PREFIX}_INCLUDES ${PROJECT_NAME})

foreach( ITEM IN LISTS ${PREFIX}_INCLUDES)
  message(STATUS "  ${${ITEM}}")
endforeach()
set(${PREFIX}_LIBS
      ${CMAKE_THREAD_LIBS_INIT}
      ${CMAKE_DL_LIBS}
      ${BioGears_LIBRARIES}
      ${Boost_LIBRARIES}
      ${CodeSynthesis_LIBRARIES}
      Qt5::Widgets
)
set(${PREFIX}_LIBS ${${PREFIX}_LIBS} PARENT_SCOPE)
target_link_libraries(${PROJECT_NAME}  ${${PREFIX}_LIBS} )

install(DIRECTORY 
    ${CMAKE_CURRENT_SOURCE_DIR}/include/biogears
        DESTINATION include/
        FILE_PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
        )
  
message(STATUS "")
