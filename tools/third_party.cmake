# project_starter_kit
# https://github.com/simongeilfus/project_starter_kit

# MIT License

# Copyright (c) 2022 Simon Geilfus

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# default common libs
#----------------------------------------------------------------

set(REQUIRES_VULKAN FALSE CACHE BOOL "" FORCE)

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

# csv
# automatically add fast-cpp-csv-parser if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/csv)
    list(APPEND THIRD_PARTY_LIBRARIES csv)
    add_library(csv INTERFACE)
    target_include_directories(csv INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/csv")
endif()

# cxxopts
# automatically add cxxopts if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/cxxopts)
    list(APPEND THIRD_PARTY_LIBRARIES cxxopts)
    add_library(cxxopts INTERFACE)
    target_include_directories(cxxopts INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/cxxopts/include")
endif()

# date
# automatically add date if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/date)
    list(APPEND THIRD_PARTY_LIBRARIES date)
    add_library(date INTERFACE)
    target_include_directories(date INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/date/include")
endif()

# entt
# automatically add entt if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/entt)
    list(APPEND THIRD_PARTY_LIBRARIES entt)
    add_library(entt INTERFACE)
    target_include_directories(entt INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/entt/src")
endif()

# glad
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/glad)
    set(GLAD_SOURCES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/glad")
    add_subdirectory("${GLAD_SOURCES_DIR}/cmake" glad_cmake)
    glad_add_library(glad REPRODUCIBLE API gl:core=3.3)
    list(APPEND THIRD_PARTY_LIBRARIES glad)
    set_property(TARGET glad PROPERTY FOLDER "third_party")
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

# glslang
# automatically add glslang if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/glslang)
    list(APPEND THIRD_PARTY_LIBRARIES glslang)
    set(ENABLE_SPVREMAPPER OFF CACHE BOOL "" FORCE)
    set(ENABLE_GLSLANG_BINARIES OFF CACHE BOOL "" FORCE)
    set(ENABLE_HLSL OFF CACHE BOOL "" FORCE)
    set(ENABLE_OPT OFF CACHE BOOL "" FORCE)
    set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
    set(SKIP_GLSLANG_INSTALL ON CACHE BOOL "" FORCE)

    add_subdirectory(glslang)

    set_property(TARGET glslang PROPERTY FOLDER "third_party")
    set_property(TARGET OGLCompiler PROPERTY FOLDER "third_party")
    set_property(TARGET OSDependent PROPERTY FOLDER "third_party")
    set_property(TARGET SPIRV PROPERTY FOLDER "third_party")
endif()

# hfsm2
# automatically add hfsm2 if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/hfsm2)
    list(APPEND THIRD_PARTY_LIBRARIES hfsm2)
    add_library(hfsm2 INTERFACE)
    target_include_directories(hfsm2 INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/hfsm2/include")
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

# pybind11
# automatically add pybind11 if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/pybind11)
    list(APPEND THIRD_PARTY_LIBRARIES pybind11::headers pybind11::module pybind11::embed)
    add_subdirectory(pybind11)
    add_library(pybind11 IMPORTED INTERFACE)
    include("${CMAKE_CURRENT_SOURCE_DIR}/pybind11/tools/pybind11Common.cmake")
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

# taskflow
# automatically add taskflow if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/taskflow)
    list(APPEND THIRD_PARTY_LIBRARIES taskflow)
    add_library(taskflow INTERFACE)
    target_include_directories(taskflow INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/taskflow/taskflow")
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

# vma
# automatically add vma if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/vma)
    list(APPEND THIRD_PARTY_LIBRARIES vma)
    add_library(vma INTERFACE)
    set(REQUIRES_VULKAN TRUE CACHE BOOL "" FORCE)
    target_include_directories(vma INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/vma/src")
endif()

# vulkanhpp
# automatically add vulkanhpp if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/vulkanhpp)
    list(APPEND THIRD_PARTY_LIBRARIES vulkanhpp)
    add_library(vulkanhpp INTERFACE)
    set(REQUIRES_VULKAN TRUE CACHE BOOL "" FORCE)
    target_include_directories(vulkanhpp INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/vulkanhpp/include)
endif()

# volk
# automatically add volk if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/volk)
    list(APPEND THIRD_PARTY_LIBRARIES volk)
    add_subdirectory(volk)
    # let volk pull vulkan
    set(REQUIRES_VULKAN FALSE CACHE BOOL "" FORCE)
    set_property(TARGET volk PROPERTY FOLDER "third_party")
endif()

# ufbx
# automatically add ufbx if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/ufbx)
    list(APPEND THIRD_PARTY_LIBRARIES ufbx)
    add_library(ufbx STATIC "${CMAKE_CURRENT_SOURCE_DIR}/ufbx/ufbx.c" )
    target_include_directories(ufbx INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/ufbx")
    set_property(TARGET ufbx PROPERTY FOLDER "third_party")
endif()

# vulkan
if(${REQUIRES_VULKAN})
    if (NOT CMAKE_VERSION VERSION_LESS 3.7.0)
        find_package(Vulkan)
    else()
        if (WIN32)
            if (CMAKE_CL_64)
                find_library(VULKAN_LIBRARY NAMES vulkan-1 HINTS "$ENV{VULKAN_SDK}/Lib" "$ENV{VK_SDK_PATH}/Lib")
            else()
                find_library(VULKAN_LIBRARY NAMES vulkan-1 HINTS "$ENV{VULKAN_SDK}/Lib32" "$ENV{VK_SDK_PATH}/Lib32")
            endif()
        else()
            find_library(VULKAN_LIBRARY NAMES vulkan HINTS "$ENV{VULKAN_SDK}/lib")
        endif()
    endif()
endif()