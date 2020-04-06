###############################################################################
# Step 1: Some packages need to be configured globally to ensure they find the 
#         right library all others should be called in the respective projects
#         to promote some independence
###############################################################################

if(WIN32)
  set(LIBRARY_INSTALL_DIR bin)
else()
  set(LIBRARY_INSTALL_DIR lib)
endif()

set(CMAKE_STATIC_LIBRARY_PREFIX "lib")
set(CMAKE_STATIC_LIBRARY_SUFFIX "_st${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(CMAKE_SHARED_LIBRARY_PREFIX "lib")

setup_unified_output_directory()
###############################################################################
# Step 2: Project Includes are generally order dependent.  So manually maintain
#         this list
###############################################################################
#option (Boost_USE_STATIC_LIBS "Toggle this option to allow static libraries" OFF)
#if(WIN32)
#  if(NOT DEFINED Boost_USE_MULTITHREADED)
#    set(Boost_USE_MULTITHREADED      ON)
#  endif()
#  if (Boost_USE_STATIC_LIBS AND NOT DEFINED Boost_USE_STATIC_RUNTIME)
#    set(Boost_USE_STATIC_RUNTIME    ON)
#  else()
#    set(Boost_USE_STATIC_RUNTIME    OFF)
#  endif()
#  set(BOOST_ALL_NO_LIB ON)
#endif()
#find_package(Boost COMPONENTS system filesystem program_options REQUIRED)

add_subdirectory(ui)

find_package(Git QUIET)
if(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
# Update submodules as needed
    option(BUILD_Biogears "Build Biogears using provided submodule" ON)
    if(BUILD_Biogears AND NOT Biogears_SUBMODULE_PULLED )
        message(STATUS "Updating Biogears Submodule")
        execute_process(
                        COMMAND ${CMAKE_COMMAND} -E echo ${GIT_EXECUTABLE} submodule init extern/biogears
                        COMMAND ${GIT_EXECUTABLE} submodule init extern/biogears
                        COMMAND ${CMAKE_COMMAND} -E echo ${GIT_EXECUTABLE} submodule update --progress --init extern/biogears/
                        COMMAND ${GIT_EXECUTABLE} submodule update --progress --init :/extern/biogears/
                        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
                        RESULT_VARIABLE GIT_SUBMOD_RESULT
                        ERROR_VARIABLE GIT_ERROR
                        OUTPUT_VARIABLE GIT_LOG
                       )
        if(NOT GIT_SUBMOD_RESULT EQUAL "0")
            message(FATAL_ERROR "Git operation failed with ${GIT_ERROR}, please checkout submodules")
       else ()
            set (Biogears_SUBMODULE_PULLED "The Cmake Build Machine has Initialized the Build System" CACHE BOOL ON)
        endif()
    endif()
endif()

if(NOT EXISTS "${PROJECT_SOURCE_DIR}/extern/biogears/CMakeLists.txt")
    message(FATAL_ERROR "The submodules were not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
endif()


set(Biogears_BUILD_CIRCUIT_PROFILER CACHE BOOL OFF)
set(Biogears_BUILD_CIRCUIT_TESTS   CACHE BOOL  OFF)
set(Biogears_BUILD_CMD_TOOLS   CACHE BOOL OFF)
set(Biogears_BUILD_DOCUMENTATION  CACHE BOOL OFF)
set(Biogears_BUILD_HOWTOS         CACHE BOOL OFF)
set(Biogears_BUILD_TEST           CACHE BOOL OFF)
set(Biogears_BUILD_TEST_DRIVER    CACHE BOOL OFF)
set(Biogears_BUILD_SCENARIO_DRIVER CACHE BOOL OFF)
set(Biogears_RUNTIME_DIR ${PROJECT_BINARY_DIR}/runtime)
if(BUILD_Biogears AND GIT_FOUND)
	add_subdirectory(${PROJECT_SOURCE_DIR}/extern/biogears libbiogears)
else()
  find_package(Biogears QUIET)
  if(NOT Biogears_FOUND)
    message(FATAL_ERROR "Unable to find Biogears. Biogears must match the requested revision for this code base.  
                         Eitehr turn on BUILD_Biogears or provide it using CMAKE_PREFIX_PATH")
  endif()
endif()


