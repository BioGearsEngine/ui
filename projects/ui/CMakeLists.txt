###############################################################################
# Policy adjustments
###############################################################################
cmake_policy(SET CMP0087 NEW)
###############################################################################
# Options
###############################################################################

###############################################################################
# Base Variables
###############################################################################
set(PROJECT_NAME BioGearsUI)
set(PREFIX bio)

set(${PREFIX}_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include" )
set(${PREFIX}_PRIVATE_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cpp" )
set(${PREFIX}_GENERATED_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}" )
set(${PREFIX}_UNIT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/unit" PARENT_SCOPE)

option(BUILD_FOR_INSTLLATION "Turns on instllation features like local runtime directories" OFF)
###############################################################################
# Requirments
###############################################################################
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)

find_package(Threads REQUIRED)
find_package(Qt5 COMPONENTS Core Widgets Charts Quick QuickControls2 REQUIRED)

###############################################################################
#Code Generation
###############################################################################
configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/cpp/version.cpp.in  ${CMAKE_CURRENT_BINARY_DIR}/cpp/version.cpp NEWLINE_STYLE LF)
###############################################################################
#Sorce and Header Defines
###############################################################################
message(STATUS "")
message(STATUS "Configuring ${PROJECT_NAME}")

#Biogears Core
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
add_source_files(${PREFIX}_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/cpp "*.h"   "Headers\\Private\\")
add_source_files(${PREFIX}_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/cpp "*.cpp" "Sources\\")
add_source_files(RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/qml "*.qrc"  "Resources\\")
add_source_files(RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/qml "*.qml"  "Resources\\")
add_source_files(${PREFIX}_SOURCES ${CMAKE_CURRENT_BINARY_DIR}/cpp/ "version.cpp" "Sources\\")

###############################################################################
#Define Logic
###############################################################################
CMAKE_POLICY(SET CMP0020 NEW)
add_executable(${PROJECT_NAME} ${${PREFIX}_SOURCES} ${${PREFIX}_HEADERS} ${RESOURCES} )

set_target_properties(${PROJECT_NAME}
  PROPERTIES
  DEFINE_SYMBOL ${PROJECT_NAME}_EXPORTS
  FOLDER "Binaries"
  OUTPUT_NAME "BioGearsUI"
  COMPILE_PDB_NAME "${PROJECT_NAME}"
  PROJECT_LABEL "${PROJECT_NAME}"
  DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX}
  AUTOMOC ON
  CXX_STANDARD 14
  VS_DEBUGGER_WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/runtime
  CPACK_START_MENU_SHORTCUTS "Biogears UI"
  )
  if(BUILD_FOR_INSTLLATION)
    target_compile_definitions(${PROJECT_NAME} PRIVATE BIOGEARS_EXPLORER_RELEASE_BUNDLE)
  endif()
if(WIN32)
  target_sources(${PROJECT_NAME}  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/BiogearsUI.rc)
  set_property(TARGET ${PROJECT_NAME} PROPERTY WIN32_EXECUTABLE $<$<CONFIG:Release>:true>) 
  target_compile_definitions(${PROJECT_NAME} PRIVATE _SCL_SECURE_NO_WARNINGS _CRT_SECURE_NO_WARNINGS bigobj)
  target_compile_options(${PROJECT_NAME} PRIVATE $<$<PLATFORM_ID:Windows>:/bigobj>  PRIVATE $<$<PLATFORM_ID:Windows>:/MP>)
elseif(CMAKE_COMPILER_IS_GNUCXX)
endif()

###############################################################################
# COMPILATION & LINKAGE MODIFICATIONS
###############################################################################

target_include_directories(${PROJECT_NAME}
    PRIVATE  ${${PREFIX}_INCLUDE_DIR} 
             ${${PREFIX}_PRIVATE_INCLUDE_DIR} 
             ${${PREFIX}_GENERATED_INCLUDE_DIR}
    INTERFACE $<BUILD_INTERFACE:${${PREFIX}_GENERATED_INCLUDE_DIR}> 
              $<BUILD_INTERFACE:${${PREFIX}_INCLUDE_DIR}>
              $<INSTALL_INTERFACE:include>
)

set(${PREFIX}_LIBS
    Threads::Threads
    Qt5::Core
    Qt5::Widgets
    Qt5::Charts
    Qt5::Quick
    Qt5::QuickControls2

    Biogears::libbiogears
)
target_link_libraries(${PROJECT_NAME}  ${${PREFIX}_LIBS} )

install(TARGETS ${PROJECT_NAME}
   RUNTIME DESTINATION bin
   LIBRARY DESTINATION ${LIBRARY_INSTALL_DIR}
   ARCHIVE DESTINATION lib
)


set_property(INSTALL "$<TARGET_FILE_NAME:${PROJECT_NAME}>"
  PROPERTY CPACK_START_MENU_SHORTCUTS "BioGears Commnad Line"
)

if(NOT ${PREFIX}_BUILD_STATIC)
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
 
add_custom_command(
    OUTPUT  ${PROJECT_BINARY_DIR}/runtime 
    COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_BINARY_DIR}/runtime
)

#stage_biogears_schema(DESTINATION ${PROJECT_BINARY_DIR}/runtime)
#stage_biogears_data  (DESTINATION ${PROJECT_BINARY_DIR}/runtime)



  set(CacheForScript ${CMAKE_BINARY_DIR}/stage_$<CONFIG>_script.cmake )
  
  file(GENERATE OUTPUT  ${CacheForScript} 
    CONTENT "
    include(BundleUtilities)
  
    set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH})

    foreach(_dir IN LISTS CMAKE_PREFIX_PATH)
      list(APPEND THIRD_PARTY  \${_dir})
      list(APPEND THIRD_PARTY_LIB \${_dir}/lib)
      list(APPEND THIRD_PARTY_BIN \${_dir}/bin)
    endforeach()

    fixup_bundle(
        $<TARGET_FILE:${PROJECT_NAME}>
        \"\"
        \"${THIRD_PARTY_LIB};${THIRD_PARTY_BIN}\"
    )
    "
  )

add_custom_target(gather_runtime_dependencies 
  ${CMAKE_COMMAND} 
  -DCMAKE_INSTALL_CONFIG_NAME=$<CONFIG> -P ${CMAKE_BINARY_DIR}/stage_$<CONFIG>_script.cmake
  )
set_target_properties(gather_runtime_dependencies
    PROPERTIES
    FOLDER ""
    PROJECT_LABEL "gather_runtime_dependencies"
)
#add_dependencies(gather_runtime_dependencies stage_biogears_schema stage_biogears_data)
####
####
message(STATUS "")
