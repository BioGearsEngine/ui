###############################################################################
# Policy adjustments
###############################################################################

###############################################################################
# Options
###############################################################################

###############################################################################
# Base Variables
###############################################################################
set(PROJECT_NAME BioGearsUI)
set(PREFIX bio)

set(${PREFIX}_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include" )
set(${PREFIX}_PRIVATE_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src" )
set(${PREFIX}_GENERATED_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}" )
set(${PREFIX}_UNIT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/unit" PARENT_SCOPE)

###############################################################################
# Requirments
###############################################################################
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)

find_package(Threads REQUIRED)
find_package(Qt5Widgets 5.10.0 CONFIG REQUIRED)
find_package(Qt5Charts 5.10.0 CONFIG REQUIRED)
find_package(BioGears REQUIRED)

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
add_source_files(SRCS ${CMAKE_CURRENT_SOURCE_DIR}/src "*.cpp" "Sources\\")
add_source_files(PUBLIC_HDRS ${CMAKE_CURRENT_SOURCE_DIR}/include "*.h"  "Headers\\Public\\")

set(${PREFIX}_HEADERS ${HDRS} ${PUBLIC_HDRS} ${GEN_HDRS})
set(${PREFIX}_SOURCES ${SRCS} ${GEN_SRCS})

###############################################################################
#Define Logic
###############################################################################
add_executable(${PROJECT_NAME} ${${PREFIX}_SOURCES} ${${PREFIX}_HEADERS})
set_target_properties(${PROJECT_NAME}
  PROPERTIES
  DEFINE_SYMBOL ${PROJECT_NAME}_EXPORTS
  FOLDER "Binaries"
  OUTPUT_NAME "BioGears"
  COMPILE_PDB_NAME "${PROJECT_NAME}"
  PROJECT_LABEL "${PROJECT_NAME}"
  DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX}
  CXX_STANDARD 14
  )

if(WIN32)
  target_compile_definitions(${PROJECT_NAME} PRIVATE "_SCL_SECURE_NO_WARNINGS" "_CRT_SECURE_NO_WARNINGS" "bigobj"  ENV{PARALLEL_COMPILE} )
elseif(CMAKE_COMPILER_IS_GNUCXX)

endif()

###############################################################################
# COMPILATION & LINKAGE MODIFICATIONS
###############################################################################
#target_compile_definitions(lib${PROJECT_NAME} PUBLIC ${${PREFIX}_CPPFLAGS_INTERFACE})
#target_compile_definitions(lib${PROJECT_NAME} PRIVATE ${${PREFIX}_CPPFLAGS})

target_include_directories(${PROJECT_NAME}
    PRIVATE  ${${PREFIX}_INCLUDE_DIR} ${${PREFIX}_PRIVATE_INCLUDE_DIR} ${${PREFIX}_GENERATED_INCLUDE_DIR}
    INTERFACE $<BUILD_INTERFACE:${${PREFIX}_GENERATED_INCLUDE_DIR}> 
              $<BUILD_INTERFACE:${${PREFIX}_INCLUDE_DIR}>
              $<INSTALL_INTERFACE:include>
)

set(${PREFIX}_LIBS
      Threads::Threads
      Boost::filesystem
      Qt5::Widgets
	  Qt5::Charts
      Biogears::libbiogears
)
target_link_libraries(${PROJECT_NAME}  ${${PREFIX}_LIBS} )

install(TARGETS ${PROJECT_NAME} EXPORT BiogearsUI
   RUNTIME DESTINATION bin
   LIBRARY DESTINATION ${LIBRARY_INSTALL_DIR}
   ARCHIVE DESTINATION lib
)

if(NOT ARA_${PREFIX}_BUILD_STATIC)
  if(WIN32)
    install(FILES $<TARGET_PDB_FILE:${PROJECT_NAME}> DESTINATION bin OPTIONAL)
  endif()
else()
   if(WIN32)
      foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
          string(TOUPPER _${OUTPUTCONFIG} OUTPUTCONFIG_UPPER)
          install(FILES "${CMAKE_PDB_OUTPUT_DIRECTORY${OUTPUTCONFIG_UPPER}}/*.pdb" DESTINATION lib CONFIGURATIONS ${OUTPUTCONFIG} OPTIONAL)
      endforeach(OUTPUTCONFIG)
   endif()
endif()
 

message(STATUS "")
