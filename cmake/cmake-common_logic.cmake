cmake_minimum_required(VERSION 3.8.0 )
cmake_policy(VERSION 3.8.0)


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
########################################################################################################
# 
# Include Macros
# 
########################################################################################################
function(ENSURE_PATHS_SET PATH_LIST TARGET_PROJECT)
    foreach(INCL ${${PATH_LIST}})
        if((DEFINED ${INCL}) AND (NOT "${${INCL}}" STREQUAL ""))
            list(APPEND INCLUDES ${${INCL}})
        else()
            message(FATAL_ERROR "External include variable " ${INCL} " not defined (Circular includes in headers?)")
        endif()
    endforeach(INCL)
    list(REMOVE_DUPLICATES INCLUDES) 
    foreach(ITEM IN LISTS INCLUDES)
      target_include_directories(${TARGET_PROJECT}
        PRIVATE PUBLIC "${ITEM}"
      )
    endforeach()
endfunction(ENSURE_PATHS_SET)

####
#
#
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
    # message(STATUS "add_source_files( ${var} \"${prefix}\" ${regex} \"${source_group}\")")
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
# Stage Macros
# 
########################################################################################################
function(create_cache_file)
  set(CacheForScript ${CMAKE_BINARY_DIR}/cmake-common_cache.cmake)
  set(OUTPUT_PREFIX ${CMAKE_BINARY_DIR}/outputs)
  file(WRITE ${CacheForScript} "")
  file(APPEND ${CacheForScript} "set(PROJECT_SOURCE_DIR ${PROJECT_SOURCE_DIR})\n")
  file(APPEND ${CacheForScript} "set(CMAKE_BINARY_DIR ${CMAKE_BINARY_DIR})\n")
  file(APPEND ${CacheForScript} "set(${PROJECT_NAME}_THIRD_PARTY ${ARA_${PROJECT_NAME}_EXTERNAL})\n")
  file(APPEND ${CacheForScript} "set(${PROJECT_NAME}_THIRD_PARTY_BIN ${ARA_${PROJECT_NAME}_EXTERNAL}/bin)\n")
  file(APPEND ${CacheForScript} "set(${PROJECT_NAME}_THIRD_PARTY_LIB ${ARA_${PROJECT_NAME}_EXTERNAL}/lib)\n")
  file(APPEND ${CacheForScript} "set(CMAKE_EXECUTABLE_SUFFIX ${CMAKE_EXECUTABLE_SUFFIX})\n")
  file(APPEND ${CacheForScript} "set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${OUTPUT_PREFIX}/lib)\n")
  file(APPEND ${CacheForScript} "set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${OUTPUT_PREFIX}/lib)\n")
  file(APPEND ${CacheForScript} "set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${OUTPUT_PREFIX}/bin)\n")
  foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
        string(TOUPPER _${OUTPUTCONFIG} OUTPUTCONFIG_UPPER)
        file(APPEND ${CacheForScript} "set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY${OUTPUTCONFIG_UPPER} ${OUTPUT_PREFIX}/${OUTPUTCONFIG}/lib)\n")
        file(APPEND ${CacheForScript} "set(CMAKE_LIBRARY_OUTPUT_DIRECTORY${OUTPUTCONFIG_UPPER} ${OUTPUT_PREFIX}/${OUTPUTCONFIG}/lib)\n")
        file(APPEND ${CacheForScript} "set(CMAKE_RUNTIME_OUTPUT_DIRECTORY${OUTPUTCONFIG_UPPER} ${OUTPUT_PREFIX}/${OUTPUTCONFIG}/bin)\n")
  endforeach()
endfunction()

function(create_stage)
  add_custom_target(STAGE 
    ${CMAKE_COMMAND} 
    -DCMAKE_INSTALL_CONFIG_NAME=$<CONFIG> -P ${CMAKE_SOURCE_DIR}/cmake/cmake-common_stage.cmake
    )
  set_target_properties(STAGE
      PROPERTIES
      FOLDER "CMakePredefinedTargets"
      PROJECT_LABEL "STAGE"
  )
endfunction() 
