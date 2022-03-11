# QT 6 Example Configuration
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
# 
#-------------------------------------------------------------------------------------

# project_executable
# define a project_executable macro to override the default add_executable behavior
#-------------------------------------------------------------------------------------
macro(project_executable)
    set(CMAKE_AUTOMOC ON)
    set(CMAKE_AUTORCC ON)
    set(CMAKE_AUTOUIC ON)
    set(QT_DIR "D:/Qt/6.2.3/msvc2019_64/")
    set(CMAKE_PREFIX_PATH ${QT_DIR})

    find_package(Qt6 COMPONENTS Core Widgets Gui REQUIRED)

    set_property(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" PROPERTY Qt6Core_VERSION_MAJOR "${Qt6Core_VERSION_MAJOR}")
    set_property(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" PROPERTY Qt6Core_VERSION_MINOR "${Qt6Core_VERSION_MAJOR}")

    add_executable(${PROJECT_TARGET} ${PROJECT_OS_BUNDLE} ${PROJECT_SOURCE_FILES} ${PROJECT_UI_FILES} ${PROJECT_RESOURCES_FILES})
endmacro()

# project_configuration
# define a project_configuration macro to configure a project after its target as been setup
#-------------------------------------------------------------------------------------
macro(project_configuration)
    # set the executable type
    target_link_options(${PROJECT_TARGET} PRIVATE "/SUBSYSTEM:WINDOWS" "/ENTRY:mainCRTStartup")
    # link qt libraries
    target_link_libraries(${PROJECT_TARGET} PRIVATE Qt6::Core Qt6::Widgets Qt6::Gui)
    # copy qt dlls
    add_custom_command(TARGET ${PROJECT_TARGET} POST_BUILD 
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:Qt6::Core> $<TARGET_FILE:Qt6::Widgets> $<TARGET_FILE:Qt6::Gui>
            $<TARGET_FILE_DIR:${PROJECT_TARGET}>
    )
    # copy qt platform dlls
    add_custom_command(TARGET ${PROJECT_TARGET} POST_BUILD 
        COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${PROJECT_TARGET}>/platforms/
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${QT_DIR}/plugins/platforms/qwindows$<$<CONFIG:Debug>:d>.dll"
            $<TARGET_FILE_DIR:${PROJECT_TARGET}>/platforms
    )
endmacro()