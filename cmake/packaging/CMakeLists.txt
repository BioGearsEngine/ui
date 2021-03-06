cmake_policy(SET CMP0087 NEW)

include(InstallRequiredSystemLibraries)
set(CPACK_PACKAGE_NAME "BioGears Explorer")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "BioGears User Interface")
set(CPACK_PACKAGE_VENDOR "Applied Resaerch Associates")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.txt")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE.txt")
set(CPACK_PACKAGE_HOMEPAGE_URL "http://biogearsengine.com")
set(CPACK_PACKAGE_ICON "${CMAKE_CURRENT_SOURCE_DIR}/biogearslogo_XoQ_icon.ico")
set(VERSION_NUMBER "${${ROOT_PROJECT_NAME}_VERSION_MAJOR}.${${ROOT_PROJECT_NAME}_VERSION_MINOR}.${${ROOT_PROJECT_NAME}_VERSION_PATCH}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "BioGears/${VERSION_NUMBER}")
set(CPACK_PACKAGE_VERSION_MAJOR ${${ROOT_PROJECT_NAME}_VERSION_MAJOR} )      
set(CPACK_PACKAGE_VERSION_MINOR ${${ROOT_PROJECT_NAME}_VERSION_MINOR} )
set(CPACK_PACKAGE_VERSION_PATCH ${${ROOT_PROJECT_NAME}_VERSION_PATCH} )
set(CPACK_PACKAGE_VERSION_TWEAK ${${ROOT_PROJECT_NAME}_VERSION_TWEAK} )


if(WIN32 AND NOT UNIX)
  # There is a bug in NSI that does not handle full UNIX paths properly.
  # Make sure there is at least one set of four backlashes.
  
  set(CPACK_PACKAGE_ICON "${CMAKE_CURRENT_SOURCE_DIR}\\\\BioGearsLogo.bmp")
  set(CPACK_NSIS_INSTALLED_ICON_NAME "${CMAKE_CURRENT_SOURCE_DIR}/biogearslogo_XoQ_icon.ico")
  set(CPACK_NSIS_DISPLAY_NAME "BioGears Explorer")
  set(CPACK_NSIS_HELP_LINK "http:\\\\\\\\www.biogearsengine.com")
  set(CPACK_NSIS_URL_INFO_ABOUT "http:\\\\\\\\www.biogearsengine.com")
  set(CPACK_NSIS_CONTACT "admin@biogearsengine.com")
  set(CPACK_NSIS_MODIFY_PATH ON)
  set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)

  set(CPACK_WIX_UPGRADE_GUID "5b30e5cf-134b-4e38-9883-111f3c6d7faf")
  set(CPACK_WIX_PRODUCT_ICON "${CMAKE_CURRENT_SOURCE_DIR}/biogearslogo_XoQ_icon.ico")
  set(CPACK_WIX_PROGRAM_MENU_FOLDER "BioGears")
  set(CPACK_WIX_UI_BANNER "${CMAKE_CURRENT_SOURCE_DIR}/WIX_UI_BANNER.png")
  set(CPACK_WIX_UI_DIALOG "${CMAKE_CURRENT_SOURCE_DIR}/WIX_UI_DIALOG.png")
  set(CPACK_WIX_PROPERTY_ARPCOMMENTS "Graphical interface for using BioGears ${${ROOT_PROJECT_NAME}_VERSION_TAG}")
  set(CPACK_WIX_PROPERTY_ARPHELPLINK  "https://biogearsengine.com")
  set(ARPURLINFOABOUT  "https://biogearsengine.com")

  get_filename_component(Qt5_ROOT_DIR "${Qt5_DIR}/../../../" ABSOLUTE  )
  
  install(CODE "
    include(BundleUtilities)

    string(TOUPPER \${CMAKE_INSTALL_CONFIG_NAME} CONFIG)
    if( NOT UNIX )
      set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY \${CMAKE_ARCHIVE_OUTPUT_DIRECTORY_\${CONFIG}} )
      set( CMAKE_LIBRARY_OUTPUT_DIRECTORY \${CMAKE_LIBRARY_OUTPUT_DIRECTORY_\${CONFIG}} )
      set( CMAKE_RUNTIME_OUTPUT_DIRECTORY \${CMAKE_RUNTIME_OUTPUT_DIRECTORY_\${CONFIG}} )
    endif()
    

    set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH})

    foreach(_dir IN LISTS CMAKE_PREFIX_PATH)
      list(APPEND THIRD_PARTY  \"\${_dir}\")
      list(APPEND THIRD_PARTY_LIB \"\${_dir}/lib\")
      list(APPEND THIRD_PARTY_BIN \"\${_dir}/bin\")
    endforeach()

    message(\" Generating Bundle for \${CMAKE_INSTALL_PREFIX}/bin/BioGearsUI.exe\")
    fixup_bundle(\${CMAKE_INSTALL_PREFIX}/bin/$<TARGET_FILE_NAME:BioGearsUI>
                    \"\"
                \"\${THIRD_PARTY_LIB};\${THIRD_PARTY_BIN}\"
    )
    if(WIN32)
        message(\" Running windeployqt for \${CMAKE_INSTALL_PREFIX}/bin/BioGearsUI.exe\")
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E env \"${Qt5_ROOT_DIR}/bin/windeployqt\" --no-compiler-runtime --list mapping \"\${CMAKE_INSTALL_PREFIX}/bin/$<TARGET_FILE_NAME:BioGearsUI>\"
            WORKING_DIRECTORY  \"\${CMAKE_INSTALL_PREFIX}/bin/\"
            OUTPUT_VARIABLE _output
            ERROR_VARIABLE  _error
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if(_output)
          message(\"windeployqt OUTPUT : \${_output}\")
        endif()
        if( _error )
          message(\"windeployqt ERROR : \${_error}\")
        endif()
    endif()

  ")

  install(DIRECTORY 
    ${PROJECT_SOURCE_DIR}/extern/biogears/share/xsd 
    DESTINATION runtime/${VERSION_NUMBER}
    FILE_PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
    )

  install(DIRECTORY 
      ${PROJECT_SOURCE_DIR}/extern/biogears/share/data/
      DESTINATION runtime/${VERSION_NUMBER}
      FILE_PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
      FILES_MATCHING 
      PATTERN "*.xml"
      PATTERN "*.config"
      PATTERN "*.csv"
      )
  install(DIRECTORY 
      ${PROJECT_SOURCE_DIR}/extern/biogears/share/Scenarios
      DESTINATION runtime/${VERSION_NUMBER}
      FILE_PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
      FILES_MATCHING 
      PATTERN "*.xml"
      )

  install(DIRECTORY 
      ${Qt5_ROOT_DIR}/plugins/
      DESTINATION bin/
      FILE_PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
      FILES_MATCHING 
      PATTERN "*.dll"
      )   
install(DIRECTORY 
    ${Qt5_ROOT_DIR}/qml/Qt 
    ${Qt5_ROOT_DIR}/qml/QtCanvas3D
    ${Qt5_ROOT_DIR}/qml/QtCharts 
    ${Qt5_ROOT_DIR}/qml/QtDataVisualization
    ${Qt5_ROOT_DIR}/qml/QtGraphicalEffects
    ${Qt5_ROOT_DIR}/qml/QtQuick 
    ${Qt5_ROOT_DIR}/qml/QtQuick.2 
    ${Qt5_ROOT_DIR}/qml/QtQMl 
    DESTINATION bin/
    FILE_PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
    )  
#  install(DIRECTORY 
#      ${Qt5_ROOT_DIR}/translations
#      DESTINATION bin/
#      FILE_PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
#      FILES_MATCHING 
#      PATTERN "*.qm"
#      )   

else()
  set(CPACK_STRIP_FILES "")
  set(CPACK_SOURCE_STRIP_FILES "")
endif()
set(CPACK_PACKAGE_EXECUTABLES "BioGearsUI" "BioGears Explorer")

include(CPack)
