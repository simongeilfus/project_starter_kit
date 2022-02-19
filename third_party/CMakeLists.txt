cmake_minimum_required (VERSION 3.6)

# third party libraries cmake project
project(third_party)
# copy the parent list of libraries so this scope can append to it
set(THIRD_PARTY_LIBRARIES ${THIRD_PARTY_LIBRARIES})

# default common libs
#----------------------------------------------------------------

# cinder
# automatically add cinder if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/cinder)
    list(APPEND THIRD_PARTY_LIBRARIES cinder )
    add_subdirectory(cinder)
    set_property(TARGET cinder PROPERTY FOLDER "third_party")
    set(IMGUI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/cinder/include/imgui)
    set(GLM_DIR ${CMAKE_CURRENT_SOURCE_DIR}/cinder/include)
endif()

# glfw
# automatically add glfw if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/glfw)
    list(APPEND THIRD_PARTY_LIBRARIES glfw )
    set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)
    set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
    set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
    set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
    add_subdirectory(glfw)
    set_property(TARGET glfw PROPERTY FOLDER "third_party")
    set_property(TARGET update_mappings PROPERTY FOLDER "third_party")
endif()

# json
# automatically add json if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/json)
    list(APPEND THIRD_PARTY_LIBRARIES json)
    add_library(json INTERFACE)
    set(JSON_DIR ${CMAKE_CURRENT_SOURCE_DIR}/json/include)
    target_include_directories(json INTERFACE "${JSON_DIR}")
endif()

# liveplusplus
# add liveplusplus if the option was set and the folder exists
if(MSVC AND ENABLE_LPP AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/liveplusplus)
    list(APPEND THIRD_PARTY_LIBRARIES liveplusplus)
    add_subdirectory(liveplusplus)
    set_property(TARGET liveplusplus PROPERTY FOLDER "third_party")
endif()

# imgui
# automatically add imgui if the folder exists
# TODO: should check for potential conflicts with cinder/imgui
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/imgui)
    list(APPEND THIRD_PARTY_LIBRARIES imgui)
    set(IMGUI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/imgui)
    set(IMGUI_FILES
        "${IMGUI_DIR}/imgui.cpp"
        "${IMGUI_DIR}/imgui_demo.cpp"
        "${IMGUI_DIR}/imgui_draw.cpp"
        "${IMGUI_DIR}/imgui_widgets.cpp"
        "${IMGUI_DIR}/imconfig.h"
        "${IMGUI_DIR}/imgui.h"
        "${IMGUI_DIR}/imgui_internal.h"
        "${IMGUI_DIR}/imstb_rectpack.h"
        "${IMGUI_DIR}/imstb_textedit.h"
        "${IMGUI_DIR}/imstb_truetype.h")
    add_library(imgui STATIC ${IMGUI_FILES})
    target_include_directories(imgui PUBLIC ${IMGUI_DIR})
    set_property(TARGET imgui PROPERTY FOLDER "third_party")
endif()

# imgui_utils
# automatically add imgui_utils if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/imgui_utils)
    add_subdirectory(imgui_utils)
    list(APPEND THIRD_PARTY_LIBRARIES imgui_utils)
    set_property(TARGET imgui_utils PROPERTY FOLDER "third_party")
endif()

# custom third party libraries
#----------------------------------------------------------------



#----------------------------------------------------------------

# update the parent list of third party libraries
set(THIRD_PARTY_LIBRARIES ${THIRD_PARTY_LIBRARIES} PARENT_SCOPE )