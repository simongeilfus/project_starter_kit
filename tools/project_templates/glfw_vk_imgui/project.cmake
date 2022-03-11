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
        target_link_options(${PROJECT_TARGET} PRIVATE "/SUBSYSTEM:WINDOWS" "/ENTRY:mainCRTStartup")
    endif()

    # add imgui glfw/gl3 backend
    if( NOT IMGUI_GLFW_VK_BACKEND_FOUND )
        add_library(imgui_glfw_vk_backend STATIC 
            "${THIRD_PARTY_DIR}/imgui/backends/imgui_impl_vulkan.cpp"
            "${THIRD_PARTY_DIR}/imgui/backends/imgui_impl_glfw.cpp"
        )
        target_include_directories(imgui_glfw_vk_backend PUBLIC "${THIRD_PARTY_DIR}/imgui/backends")
        target_include_directories(imgui_glfw_vk_backend PRIVATE "${THIRD_PARTY_DIR}/imgui")
        target_link_libraries(imgui_glfw_vk_backend PRIVATE imgui glfw vulkanhpp ${Vulkan_LIBRARY})
        set_property(TARGET imgui_glfw_vk_backend PROPERTY FOLDER "third_party")
        set(IMGUI_GLFW_VK_BACKEND_FOUND TRUE PARENT_SCOPE)
    endif()
    # link imgui backend with project
    target_link_libraries(${PROJECT_TARGET} PUBLIC imgui_glfw_vk_backend)
endmacro()