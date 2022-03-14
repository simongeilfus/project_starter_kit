# PROJECT CUSTOM CMAKE
#-------------------------------------------------------------------------------------
#
# This file will be included after the project's add_executable call but before any other
# configuration is done. This allows to set any properties or options specific to the project.
# Variables such as THIRD_PARTY_LIBRARIES are local to the project and can easily be overriden.
#
# If more granularity is needed it is also possible to create a CMakeLists.txt to be used instead.
#
# The following project specific variables are available
# 
#       ${PROJECT_DIR}
#       ${PROJECT_OUTPUT_DIR}
#       ${PROJECT_TARGET} 
#       ${PROJECT_OS_BUNDLE} 
#       ${PROJECT_SOURCE_FILES} 
#       ${PROJECT_UI_FILES} 
#       ${PROJECT_RESOURCES_FILES}
#
#-------------------------------------------------------------------------------------

target_link_options(${PROJECT_TARGET} PRIVATE "/SUBSYSTEM:WINDOWS" "/ENTRY:mainCRTStartup")