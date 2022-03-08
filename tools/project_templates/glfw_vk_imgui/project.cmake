# project custom cmake
#
# use target commands to not pollute other projects
# ex. target_compile_definitions( ${PROJECT_NAME} PRIVATE SOMETHING=1 )
#----------------------------------------------------------------
if(MSVC)
    set_target_properties( ${PROJECT_NAME} PROPERTIES LINK_FLAGS "/SUBSYSTEM:windows /ENTRY:mainCRTStartup" )
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
target_link_libraries(${PROJECT_NAME} PUBLIC imgui_glfw_vk_backend)