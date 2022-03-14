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

# add imgui glfw/gl3 backend
if( NOT IMGUI_GLFW_GL3_BACKEND_FOUND )
    add_library(imgui_glfw_gl3_backend STATIC 
        "${THIRD_PARTY_DIR}/imgui/backends/imgui_impl_opengl3.cpp"
        "${THIRD_PARTY_DIR}/imgui/backends/imgui_impl_glfw.cpp"
    )
    target_include_directories(imgui_glfw_gl3_backend PUBLIC "${THIRD_PARTY_DIR}/imgui/backends")
    target_include_directories(imgui_glfw_gl3_backend PRIVATE "${THIRD_PARTY_DIR}/imgui")
    target_link_libraries(imgui_glfw_gl3_backend PRIVATE imgui glfw)
    set_property(TARGET imgui_glfw_gl3_backend PROPERTY FOLDER "third_party")
    set(IMGUI_GLFW_GL3_BACKEND_FOUND TRUE PARENT_SCOPE)
endif()

# link imgui backend with project
target_link_libraries(${PROJECT_TARGET} PUBLIC imgui_glfw_gl3_backend)