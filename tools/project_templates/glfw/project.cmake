# project custom cmake
#
# use target commands to not pollute other projects
# ex. target_compile_definitions( ${PROJECT_NAME} PRIVATE SOMETHING=1 )
#----------------------------------------------------------------
if(MSVC)
    set_target_properties( ${PROJECT_NAME} PROPERTIES LINK_FLAGS "/SUBSYSTEM:windows /ENTRY:mainCRTStartup" )
endif()
