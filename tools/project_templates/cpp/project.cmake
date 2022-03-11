# project custom cmake
#-------------------------------------------------------------------------------------
# The Cmake project system uses macro to customize how project are configured. Wrapping
# the project configuration inside those macros ensure that the code is executed at the
# right moment.
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
#-------------------------------------------------------------------------------------

# project_executable
# define a project_executable macro to override the default add_executable behavior
#-------------------------------------------------------------------------------------
# macro(project_executable)
#     add_executable(${PROJECT_TARGET} ${PROJECT_OS_BUNDLE} ${PROJECT_SOURCE_FILES} ${PROJECT_UI_FILES} ${PROJECT_RESOURCES_FILES})
# endmacro()

# project_configuration
# define a project_configuration macro to configure a project after its target as been setup
#-------------------------------------------------------------------------------------
macro(project_configuration)
	if(MSVC)
		target_link_options(${PROJECT_TARGET} PRIVATE "/SUBSYSTEM:CONSOLE" "/ENTRY:mainCRTStartup")
	endif()
endmacro()