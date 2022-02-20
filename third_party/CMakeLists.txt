cmake_minimum_required (VERSION 3.6)

# third party libraries cmake project
project(third_party)
# copy the parent list of libraries so this scope can append to it
set(THIRD_PARTY_LIBRARIES ${THIRD_PARTY_LIBRARIES})

# default common libs
#----------------------------------------------------------------

# cereal
# automatically add cereal if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/cereal)
    list(APPEND THIRD_PARTY_LIBRARIES cereal)
    add_library(cereal INTERFACE)
    target_include_directories(cereal INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/cereal/include")
endif()

# cinder
# automatically add cinder if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/cinder)
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/imgui)
        set(CINDER_IMGUI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/imgui)
    endif()
    list(APPEND THIRD_PARTY_LIBRARIES cinder )
    add_subdirectory(cinder)
    set_property(TARGET cinder PROPERTY FOLDER "third_party")
    set(IMGUI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/cinder/include/imgui)
    set(GLM_DIR ${CMAKE_CURRENT_SOURCE_DIR}/cinder/include)
endif()

# date
# automatically add date if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/date)
    list(APPEND THIRD_PARTY_LIBRARIES date)
    add_library(date INTERFACE)
    target_include_directories(date INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/date/include")
endif()

# flags
# automatically add flags if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/flags)
    list(APPEND THIRD_PARTY_LIBRARIES flags)
    add_library(flags INTERFACE)
    target_include_directories(flags INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/flags/include")
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

# glm
# automatically add glm if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/glm)
    list(APPEND THIRD_PARTY_LIBRARIES glm)
    add_library(glm INTERFACE)
    target_include_directories(glm INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/glm")
    set(GLM_DIR "${CMAKE_CURRENT_SOURCE_DIR}/glm")
endif()

# imgui
# automatically add imgui if the folder exists
# TODO: should check for potential conflicts with cinder/imgui
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/imgui)
    if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/cinder)
        list(APPEND THIRD_PARTY_LIBRARIES imgui)
        set(IMGUI_DIR "${CMAKE_CURRENT_SOURCE_DIR}/imgui")
        set(IMGUI_FILES
            "${IMGUI_DIR}/imgui.cpp"
            "${IMGUI_DIR}/imgui_demo.cpp"
            "${IMGUI_DIR}/imgui_draw.cpp"
            "${IMGUI_DIR}/imgui_tables.cpp"
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
    else()
        list(APPEND THIRD_PARTY_LIBRARIES imgui)
        add_library(imgui INTERFACE)
        set(IMGUI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/imgui)
        target_include_directories(imgui INTERFACE "${IMGUI_DIR}")
    endif()
endif()

# imgui_utils
# automatically add imgui_utils if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/imgui_utils)
    add_subdirectory(imgui_utils)
    list(APPEND THIRD_PARTY_LIBRARIES imgui_utils)
    set_property(TARGET imgui_utils PROPERTY FOLDER "third_party")
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

# sokol
# automatically add sokol if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/sokol)
    list(APPEND THIRD_PARTY_LIBRARIES sokol)
    add_library(sokol INTERFACE)
    target_include_directories(sokol INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/sokol")
    target_include_directories(sokol INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/sokol/util")
endif()

# stb
# automatically add stb if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/stb)
    list(APPEND THIRD_PARTY_LIBRARIES stb)
    add_library(stb INTERFACE)
    target_include_directories(stb INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/stb")
endif()

# tinyexr
# automatically add tinyexr if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/tinyexr)
    list(APPEND THIRD_PARTY_LIBRARIES tinyexr)
    set(TINYEXR_BUILD_SAMPLE OFF CACHE BOOL "" FORCE)
    add_subdirectory(tinyexr)
    set_property(TARGET tinyexr PROPERTY FOLDER "third_party")
    set_property(TARGET miniz PROPERTY FOLDER "third_party")
endif()

# tinyobj
# automatically add tinyobj if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/tinyobj)
    list(APPEND THIRD_PARTY_LIBRARIES tinyobj)
    add_library(tinyobj STATIC "${CMAKE_CURRENT_SOURCE_DIR}/tinyobj/tiny_obj_loader.cc" )
    target_include_directories(tinyobj INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/tinyobj")
    set_property(TARGET tinyobj PROPERTY FOLDER "third_party")
endif()

# ufbx
# automatically add ufbx if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/ufbx)
    list(APPEND THIRD_PARTY_LIBRARIES ufbx)
    add_library(ufbx STATIC "${CMAKE_CURRENT_SOURCE_DIR}/ufbx/ufbx.c" )
    target_include_directories(ufbx INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/ufbx")
    set_property(TARGET ufbx PROPERTY FOLDER "third_party")
endif()

# custom third party libraries
#----------------------------------------------------------------



#----------------------------------------------------------------

# update the parent list of third party libraries
set(THIRD_PARTY_LIBRARIES ${THIRD_PARTY_LIBRARIES} PARENT_SCOPE )