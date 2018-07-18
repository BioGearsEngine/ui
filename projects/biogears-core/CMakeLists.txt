###############################################################################
# Policy adjustments
###############################################################################

###############################################################################
# Options
###############################################################################
 option(BIOGEARS_CORE_BUILD_STATIC       "If enabled Biogears biogears_core will be built as a static library"  ON)
###############################################################################
# Base Variables
###############################################################################
set(BIO_CORE_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include" )
set(BIO_CORE_PRIVATE_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src" )
set(BIO_CORE_GENERATED_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}" )

###############################################################################
# Requirmentstn
###############################################################################
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
find_package(Threads REQUIRED)

###############################################################################
#Code Generation
###############################################################################

###############################################################################
#Sorce and Header Defines
###############################################################################
message(STATUS "")
message(STATUS "Configuring Kaleidoscope")

add_source_files(HDRS ${CMAKE_CURRENT_SOURCE_DIR}/src "*.h"   "Headers\\Private\\")
add_source_files(HDRS ${CMAKE_CURRENT_SOURCE_DIR}/src "*.hpp"   "Headers\\Private\\")
add_source_files(SRCS ${CMAKE_CURRENT_SOURCE_DIR}/src "*.cpp" "Sources\\")
add_source_files(SRCS ${CMAKE_CURRENT_SOURCE_DIR}/src "*.c" "Sources\\")
add_source_files(PUBLIC_HDRS ${CMAKE_CURRENT_SOURCE_DIR}/include "*.h"  "Headers\\Public\\")
add_source_files(PUBLIC_HDRS ${CMAKE_CURRENT_SOURCE_DIR}/include "*.hpp"  "Headers\\Public\\")

set(CORE_HEADERS ${HDRS} ${PUBLIC_HDRS} ${GEN_HDRS})
set(CORE_SOURCES ${SRCS} ${GEN_SRCS})

###############################################################################
#Define Logic
###############################################################################
if (BIOGEARS_CORE_BUILD_STATIC)
  list(APPEND CORE_CPPFLAGS_PUBLIC "-DBIOGEARS_CORE_BUILD_STATIC")
endif()
if(WIN32)
  list(APPEND CORE_CPPFLAGS_PUBLIC )
  list(APPEND CORE_CPPFLAGS_PRIVATE "-D_CRT_SECURE_NO_WARNINGS" $ENV{PBIOLLEL_COMPILE} ${CodeSynthesis_CPPFLAGS})
endif()

if(BIOGEARS_CORE_BUILD_STATIC)
  add_library(biogears_core STATIC ${CORE_SOURCES} ${CORE_HEADERS})
else()
  add_library(biogears_core SHARED ${CORE_SOURCES} ${CORE_HEADERS})
endif()
add_library(Biogears::core ALIAS biogears_core)

target_compile_definitions(biogears_core PRIVATE ${CORE_CPPFLAGS_PRIVATE} PUBLIC ${CORE_CPPFLAGS_PUBLIC} )


set_target_properties(biogears_core
    PROPERTIES
    DEFINE_SYMBOL CORE_EXPORTS
    FOLDER "Libraries"
    OUTPUT_NAME biogears_core
    COMPILE_PDB_NAME biogears_core
    PUBLIC_HEADER "${PUBLIC_HDRS}"
    DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX}
    CXX_STANDARD 14
    )

if(CMAKE_COMPILER_IS_GNUCXX)
    set_target_properties(biogears_core PROPERTIES LINK_FLAGS ${CORE_LDFLAGS})
endif()

###############################################################################
# COMPILATION & LINKAGE MODIFICATIONS
###############################################################################
target_include_directories(biogears_core
  PRIVATE   ${BIO_CORE_INCLUDE_DIR} 
            ${BIO_CORE_PRIVATE_INCLUDE_DIR} 
            ${BIO_CORE_GENERATED_INCLUDE_DIR}
  INTERFACE  $<BUILD_INTERFACE:${BIO_CORE_INCLUDE_DIR}>
             $<BUILD_INTERFACE:${BIO_CORE_GENERATED_INCLUDE_DIR}>
             $<INSTALL_INTERFACE:include>
)


set(CORE_LIBS
      ${CMAKE_THREAD_LIBS_INIT}
      ${CMAKE_DL_LIBS}
)
target_link_libraries(biogears_core  ${CORE_LIBS} )

 install(TARGETS biogears_core EXPORT biogears
     RUNTIME DESTINATION bin
     LIBRARY DESTINATION bin
     ARCHIVE DESTINATION lib
     PUBLIC_HEADER DESTINATION include
  )

set(PDB_NAME "biogears_core.pdb")
if(NOT BIOGEARS_CORE_BUILD_STATIC)
  if(WIN32)
    install(FILES $<TARGET_PDB_FILE:Biogears::core> DESTINATION bin OPTIONAL)
  endif()
else()
   if(WIN32)
      foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
          string(TOUPPER _${OUTPUTCONFIG} OUTPUTCONFIG_UPPER)
          install(FILES "${CMAKE_LIBRARY_OUTPUT_DIRECTORY${OUTPUTCONFIG_UPPER}}/${PDB_NAME}" DESTINATION lib CONFIGURATIONS ${OUTPUTCONFIG} OPTIONAL)
      endforeach(OUTPUTCONFIG)
   endif()
endif()

message(STATUS "")
