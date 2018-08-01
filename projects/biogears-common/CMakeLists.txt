###############################################################################
# Policy adjustments
###############################################################################

###############################################################################
# Options
###############################################################################
 option(BIOGEARS_COMMON_BUILD_STATIC       "If enabled Biogears biogears_common will be built as a static library"  ON)
###############################################################################
# Base Variables
###############################################################################
set(BIO_COMMON_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include" )
set(BIO_COMMON_PRIVATE_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src" )
set(BIO_COMMON_GENERATED_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}" )

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

set(COMMON_HEADERS ${HDRS} ${PUBLIC_HDRS} ${GEN_HDRS})
set(COMMON_SOURCES ${SRCS} ${GEN_SRCS})

###############################################################################
#Define Logic
###############################################################################
if (BIOGEARS_COMMON_BUILD_STATIC)
  list(APPEND COMMON_CPPFLAGS_PUBLIC "-DBIOGEARS_COMMON_BUILD_STATIC")
endif()
if(WIN32)
  list(APPEND COMMON_CPPFLAGS_PUBLIC )
  list(APPEND COMMON_CPPFLAGS_PRIVATE "-D_CRT_SECURE_NO_WARNINGS" $ENV{PBIOLLEL_COMPILE} ${CodeSynthesis_CPPFLAGS})
endif()

if(BIOGEARS_COMMON_BUILD_STATIC)
  add_library(biogears_common STATIC ${COMMON_SOURCES} ${COMMON_HEADERS})
else()
  add_library(biogears_common SHARED ${COMMON_SOURCES} ${COMMON_HEADERS})
endif()
add_library(Biogears::common ALIAS biogears_common)

target_compile_definitions(biogears_common PRIVATE ${COMMON_CPPFLAGS_PRIVATE} PUBLIC ${COMMON_CPPFLAGS_PUBLIC} )


set_target_properties(biogears_common
    PROPERTIES
    DEFINE_SYMBOL COMMON_EXPORTS
    FOLDER "Libraries"
    OUTPUT_NAME biogears_common
    COMPILE_PDB_NAME biogears_common
    PUBLIC_HEADER "${PUBLIC_HDRS}"
    DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX}
    CXX_STANDARD 14
    )

if(CMAKE_COMPILER_IS_GNUCXX AND DEFINED COMMON_LDFLAGS)
    set_target_properties(biogears_common PROPERTIES LINK_FLAGS ${COMMON_LDFLAGS})
endif()

###############################################################################
# COMPILATION & LINKAGE MODIFICATIONS
###############################################################################
target_include_directories(biogears_common
  PRIVATE   ${BIO_COMMON_INCLUDE_DIR} 
            ${BIO_COMMON_PRIVATE_INCLUDE_DIR} 
            ${BIO_COMMON_GENERATED_INCLUDE_DIR}
  INTERFACE  $<BUILD_INTERFACE:${BIO_COMMON_INCLUDE_DIR}>
             $<BUILD_INTERFACE:${BIO_COMMON_GENERATED_INCLUDE_DIR}>
             $<INSTALL_INTERFACE:include>
)


set(COMMON_LIBS
      ${CMAKE_THREAD_LIBS_INIT}
      ${CMAKE_DL_LIBS}
)
target_link_libraries(biogears_common  ${COMMON_LIBS} )

 install(TARGETS biogears_common EXPORT biogears
     RUNTIME DESTINATION bin
     LIBRARY DESTINATION bin
     ARCHIVE DESTINATION lib
     PUBLIC_HEADER DESTINATION include
  )

set(PDB_NAME "biogears_common.pdb")
if(NOT BIOGEARS_COMMON_BUILD_STATIC)
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
