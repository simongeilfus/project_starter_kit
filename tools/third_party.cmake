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

# Runtime DLL registration system
#----------------------------------------------------------------
# Global list to track runtime DLLs that need to be copied to project output directories
set(THIRD_PARTY_RUNTIME_DLLS "" CACHE INTERNAL "List of runtime DLLs to copy")

# Function to register a runtime DLL for automatic copying
# Usage: register_runtime_dll(SOURCE_PATH DEST_SUBDIR)
#   SOURCE_PATH: Path to DLL file or directory containing DLLs (supports generator expressions)
#   DEST_SUBDIR: Optional subdirectory in output dir (e.g., "D3D12" for D3D12/file.dll)
function(register_runtime_dll SOURCE_PATH)
    set(DEST_SUBDIR "")
    if(ARGC GREATER 1)
        set(DEST_SUBDIR "${ARGV1}")
    endif()

    list(APPEND THIRD_PARTY_RUNTIME_DLLS "${SOURCE_PATH}|${DEST_SUBDIR}")
    set(THIRD_PARTY_RUNTIME_DLLS "${THIRD_PARTY_RUNTIME_DLLS}" CACHE INTERNAL "List of runtime DLLs to copy")
endfunction()

# CUDA Utilities
include(${CMAKE_CURRENT_SOURCE_DIR}/../tools/cuda.cmake)

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
        set(CINDER_DISABLE_IMGUI TRUE CACHE BOOL "Disable Cinder ImGui integration" FORCE)
    else()
        set(IMGUI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/cinder/include/imgui)
    endif()
    list(APPEND THIRD_PARTY_LIBRARIES cinder )
    add_subdirectory(cinder)
    set_target_properties(cinder PROPERTIES INTERFACE_COMPILE_OPTIONS "")
    target_compile_features(cinder PRIVATE cxx_std_17)
    set(GLM_DIR ${CMAKE_CURRENT_SOURCE_DIR}/cinder/include)
    set_property(TARGET cinder PROPERTY FOLDER "third_party")
endif()

# rive
# automatically add rive if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime)
    list(APPEND THIRD_PARTY_LIBRARIES rive-runtime )
    add_library(rive-runtime STATIC)
    target_include_directories(rive-runtime PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/include")
    target_include_directories(rive-runtime PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/include")
    set_property(TARGET rive-runtime PROPERTY FOLDER "third_party")
    
    # Add all .hpp files in renderer and renderer/gl directories
    file(GLOB RIVE_RENDERER_HEADERS
        "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/include/*.hpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/include/gl/*.hpp"
    )

    # Add all .cpp files in renderer and renderer/gl directories
    file(GLOB RIVE_RENDERER_SOURCES
        "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/src/*.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/src/gl/*.cpp"
    )

    # Remove load_gles_extensions.cpp from the sources
    list(REMOVE_ITEM RIVE_RENDERER_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/src/gl/load_gles_extensions.cpp")

    # Add all .cpp files in utils directory
    file(GLOB RIVE_UTILS_SOURCES
        "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/utils/*.cpp"
    )

    # Add the headers and sources to the target
    target_sources(rive-runtime PRIVATE ${RIVE_RENDERER_HEADERS} ${RIVE_RENDERER_SOURCES} ${RIVE_UTILS_SOURCES})

    # Set C++ standard to C++20
    target_compile_features(rive-runtime PUBLIC ${CXX_STANDARD})
    
    # Suppress warning C4267, C4996, and C4244 for rive-runtime
    target_compile_options(rive-runtime PRIVATE /wd4267 /wd4996 /wd4244)

    # Define RIVE_DESKTOP_GL preprocessor macro
    target_compile_definitions(rive-runtime PUBLIC RIVE_DESKTOP_GL)

    # Define other preprocessor macros
    target_compile_definitions(rive-runtime PUBLIC RIVE_DECODERS)
    target_compile_definitions(rive-runtime PUBLIC WITH_RIVE_TOOLS)
    target_compile_definitions(rive-runtime PUBLIC WITH_RIVE_TEXT)
    target_compile_definitions(rive-runtime PUBLIC WITH_RIVE_LAYOUT)

    # Add the decoder include directory
    target_include_directories(rive-runtime PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/decoders/include")
    
    # Add cinder's include directory so <glad/glad.h> can be found
    target_include_directories(rive-runtime PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/cinder/include")

    # Organize headers into folders
    source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/include" PREFIX "Header Files" FILES ${RIVE_RENDERER_HEADERS})
    source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/src" PREFIX "Source Files" FILES ${RIVE_RENDERER_SOURCES})
    source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/utils" PREFIX "Source Files/Utils" FILES ${RIVE_UTILS_SOURCES})

    # Add glad_custom header and source files
    target_sources(rive-runtime PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/../include/glad_custom/glad_custom.h"
        "${CMAKE_CURRENT_SOURCE_DIR}/../src/glad_custom/glad_custom.c"
    )

    # Add custom glad and KHR include directory
    target_include_directories(rive-runtime PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/../include/glad_custom")

    # Add shaders include directories
    target_include_directories(rive-runtime PRIVATE 
        "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/src/"
        "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/release/include"
    )
    
    # Check if the out folder exists, if not, call build_rive.bat
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/release/rive.lib" OR
        NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/debug/rive.lib")
        message(WARNING "Rive libraries not found. Attempting to build Rive libraries...")
        execute_process(COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/../tools/rive/build_rive.bat"
                        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../tools/rive"
                        RESULT_VARIABLE result)
        if(NOT result EQUAL 0)
            message(FATAL_ERROR "Failed to build Rive libraries.")
        endif()
    endif()

    # Link additional libraries
    target_link_libraries(rive-runtime PUBLIC
        $<$<OR:$<CONFIG:Debug>,$<CONFIG:DebugLxx>>:
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/debug/rive.lib
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/debug/rive_decoders.lib
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/debug/rive_sheenbidi.lib
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/debug/rive_harfbuzz.lib
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/debug/rive_yoga.lib
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/debug/libjpeg.lib
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/debug/libpng.lib
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/debug/libwebp.lib
        >
        $<$<OR:$<CONFIG:Release>,$<CONFIG:ReleaseLxx>>:
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/release/rive.lib
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/release/rive_decoders.lib
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/release/rive_sheenbidi.lib
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/release/rive_harfbuzz.lib
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/release/rive_yoga.lib
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/release/libjpeg.lib
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/release/libpng.lib
            ${CMAKE_CURRENT_SOURCE_DIR}/rive-runtime/renderer/out/release/libwebp.lib
        >
    )
endif()

# stereolabs_zed
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/stereolabs_zed")
    list(APPEND THIRD_PARTY_LIBRARIES stereolabs_zed)
    file(GLOB STEREOLABS_ZED_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/stereolabs_zed/src/*.cpp")
    add_library(stereolabs_zed STATIC ${STEREOLABS_ZED_SOURCES})
    set_target_properties(stereolabs_zed PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/third_party/stereolabs_zed/$<CONFIG>"
    )  

    if(NOT DEFINED CUDA_INCLUDE_DIR OR NOT DEFINED CUDA_LIB_DIR OR NOT DEFINED CUDA_VERSION)
        find_highest_cuda_version(CUDA_INCLUDE_DIR CUDA_LIB_DIR CUDA_VERSION "12.0" "12.9")
    endif()
    if(NOT CUDA_INCLUDE_DIR OR NOT CUDA_LIB_DIR)
        message(FATAL_ERROR "No supported CUDA include/lib directory found!")
    else()
        message(STATUS "CUDA include: ${CUDA_INCLUDE_DIR}")
        message(STATUS "CUDA lib: ${CUDA_LIB_DIR}")
    endif()

    target_include_directories(stereolabs_zed PUBLIC
        "${CMAKE_CURRENT_SOURCE_DIR}/stereolabs_zed/include"
        "C:/Program Files (x86)/ZED SDK/include"
        "${CUDA_INCLUDE_DIR}"
    )
    target_link_directories(stereolabs_zed PUBLIC
        "C:/Program Files (x86)/ZED SDK/lib"
        "${CUDA_LIB_DIR}"
    )
    target_link_libraries(stereolabs_zed PUBLIC sl_zed64.lib cudart.lib cuda.lib)
    if(TARGET cinder)
        target_link_libraries(stereolabs_zed PUBLIC cinder)
    else()
        message(WARNING "Cinder target not found - stereolabs_zed may not work properly")
    endif()
    target_compile_features(stereolabs_zed PRIVATE ${CXX_STANDARD})

    set_property(TARGET stereolabs_zed PROPERTY FOLDER "third_party")
endif()

# libRvVideo
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/libRvVideo)
    list(APPEND THIRD_PARTY_LIBRARIES libRvVideo)
    add_library(libRvVideo INTERFACE)
    target_include_directories(libRvVideo INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/libRvVideo/include")
    if(ENABLE_LXX_CONFIGS)
        target_link_directories(libRvVideo INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/libRvVideo/lib/msw/$<IF:$<EQUAL:${CMAKE_SIZEOF_VOID_P},8>,x64,x86>/$<IF:$<OR:$<CONFIG:Debug>,$<CONFIG:DebugLxx>>,Debug,Release>/${CMAKE_VS_PLATFORM_TOOLSET}")
    else()
        target_link_directories(libRvVideo INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/libRvVideo/lib/msw/$<IF:$<EQUAL:${CMAKE_SIZEOF_VOID_P},8>,x64,x86>/$<IF:$<CONFIG:Debug>,Debug,Release>/${CMAKE_VS_PLATFORM_TOOLSET}")
    endif()
    target_link_libraries(libRvVideo INTERFACE RvVideo.lib)

    # Register FFmpeg DLLs for automatic copying
    register_runtime_dll("${CMAKE_CURRENT_SOURCE_DIR}/libRvVideo/FFmpeg/lib/msw/x64")
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

# DirectXShaderCompiler
# automatically add DirectXShaderCompiler if the folder exists
# if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/DirectXShaderCompiler)
#     set(ENABLE_SPIRV_CODEGEN ON CACHE BOOL "" FORCE)
#     set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "")
#     set(LLVM_APPEND_VC_REV ON CACHE BOOL "")
#     set(LLVM_DEFAULT_TARGET_TRIPLE "dxil-ms-dx" CACHE STRING "")
#     set(LLVM_ENABLE_EH ON CACHE BOOL "")
#     set(LLVM_ENABLE_RTTI ON CACHE BOOL "")
#     set(LLVM_INCLUDE_DOCS OFF CACHE BOOL "")
#     set(LLVM_INCLUDE_EXAMPLES OFF CACHE BOOL "")
#     set(LLVM_OPTIMIZED_TABLEGEN OFF CACHE BOOL "")
#     set(LLVM_TARGETS_TO_BUILD "None" CACHE STRING "")
#     set(LIBCLANG_BUILD_STATIC ON CACHE BOOL "")
#     set(CLANG_BUILD_EXAMPLES OFF CACHE BOOL "")
#     set(CLANG_CL OFF CACHE BOOL "")
#     set(CLANG_ENABLE_ARCMT OFF CACHE BOOL "")
#     set(CLANG_ENABLE_STATIC_ANALYZER OFF CACHE BOOL "")
#     set(HLSL_INCLUDE_TESTS OFF CACHE BOOL "")
#     set(ENABLE_SPIRV_CODEGEN ON CACHE BOOL "")
#     set(SPIRV_BUILD_TESTS OFF CACHE BOOL "")
#     set(LLVM_ENABLE_TERMINFO OFF CACHE BOOL "")
#     list(APPEND THIRD_PARTY_LIBRARIES DirectXShaderCompiler)
#     add_subdirectory(DirectXShaderCompiler)
#     set_property(TARGET DirectXShaderCompiler PROPERTY FOLDER "third_party")
# endif()

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
    if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/cinder OR CINDER_DISABLE_IMGUI)
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
            "${IMGUI_DIR}/misc/cpp/imgui_stdlib.h"
            "${IMGUI_DIR}/misc/cpp/imgui_stdlib.cpp"
            "${IMGUI_DIR}/imstb_rectpack.h"
            "${IMGUI_DIR}/imstb_textedit.h"
            "${IMGUI_DIR}/imstb_truetype.h")
        add_library(imgui STATIC ${IMGUI_FILES})
        target_include_directories(imgui PUBLIC ${IMGUI_DIR} "${IMGUI_DIR}/misc/cpp")
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/cinder)
            target_link_libraries(imgui PRIVATE cinder)
        endif()
        set_property(TARGET imgui PROPERTY FOLDER "third_party")
    else()
        list(APPEND THIRD_PARTY_LIBRARIES imgui)
        add_library(imgui INTERFACE)
        set(IMGUI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/imgui)
        target_include_directories(imgui INTERFACE "${IMGUI_DIR}")
    endif()
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
if(MSVC AND ( ENABLE_LXX OR ENABLE_LXX_CONFIGS ) AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/liveplusplus)
    if(ENABLE_LXX)
        list(APPEND THIRD_PARTY_LIBRARIES liveplusplus)
    endif()
    add_subdirectory(liveplusplus)
    set_property(TARGET liveplusplus PROPERTY FOLDER "third_party")
endif()


# imgui_utils
# automatically add imgui_utils if the folder exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/imgui_utils)
    add_subdirectory(imgui_utils)
    list(APPEND THIRD_PARTY_LIBRARIES imgui_utils)
    set_property(TARGET imgui_utils PROPERTY FOLDER "third_party")
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
    if(NOT CMAKE_VERSION VERSION_LESS 3.7.0)
        find_package(Vulkan)
    endif()

	if(NOT Vulkan_FOUND)
        find_library(VULKAN_LIBRARY NAMES vulkan-1 HINTS "$ENV{VULKAN_SDK}/Lib" "$ENV{VK_SDK_PATH}/Lib")
        if(Vulkan_LIBRARY)
            set(Vulkan_FOUND ON)
            message("Using bundled Vulkan library version")
        endif()
    endif()

	if(Vulkan_FOUND)
        list(APPEND THIRD_PARTY_LIBRARIES ${Vulkan_LIBRARY})
    endif()
endif()

# Generic third-party library detection
# automatically add any remaining folders that contain include and/or src directories

# List of libraries to ignore during auto-detection
set(IGNORED_LIBRARIES
    "liveplusplus"
    "pybind11"
)

# file(GLOB POTENTIAL_LIBRARIES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/*)

# foreach(LIBRARY_DIR ${POTENTIAL_LIBRARIES})
#     # Skip if it's not a directory
#     if(NOT IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${LIBRARY_DIR})
#         continue()
#     endif()
    
#     # Skip if already processed by explicit checks above
#     if(${LIBRARY_DIR} IN_LIST THIRD_PARTY_LIBRARIES)
#         continue()
#     endif()
    
#     # Skip if in the ignored libraries list
#     if(${LIBRARY_DIR} IN_LIST IGNORED_LIBRARIES)
#         continue()
#     endif()
    
#     # Skip common non-library directories
#     if(${LIBRARY_DIR} MATCHES "^(build|cmake|docs?|examples?|tests?|samples?|tools?|scripts?)$")
#         continue()
#     endif()
    
#     # Check if the directory has its own CMakeLists.txt
#     if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${LIBRARY_DIR}/CMakeLists.txt)
#         message(STATUS "Auto-detected third-party library with CMake: ${LIBRARY_DIR}")
#         add_subdirectory(${LIBRARY_DIR})
#         list(APPEND THIRD_PARTY_LIBRARIES ${LIBRARY_DIR})
#         # Override folder property to ensure it goes into third_party folder
#         set_property(TARGET ${LIBRARY_DIR} PROPERTY FOLDER "third_party")
#         continue()
#     endif()
    
#     # Check if the directory contains include and/or src subdirectories
#     set(HAS_INCLUDE FALSE)
#     set(HAS_SRC FALSE)
    
#     if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${LIBRARY_DIR}/include)
#         set(HAS_INCLUDE TRUE)
#     endif()
    
#     if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${LIBRARY_DIR}/src)
#         set(HAS_SRC TRUE)
#     endif()
    
#     # Add library if it has include or src directories
#     if(HAS_INCLUDE OR HAS_SRC)
#         message(STATUS "Auto-detected third-party library: ${LIBRARY_DIR}")
        
#         if(HAS_SRC)
#             # Create a static library with source files
#             file(GLOB_RECURSE LIBRARY_SOURCES 
#                 "${CMAKE_CURRENT_SOURCE_DIR}/${LIBRARY_DIR}/src/*.cpp"
#                 "${CMAKE_CURRENT_SOURCE_DIR}/${LIBRARY_DIR}/src/*.c"
#                 "${CMAKE_CURRENT_SOURCE_DIR}/${LIBRARY_DIR}/src/*.cc"
#                 "${CMAKE_CURRENT_SOURCE_DIR}/${LIBRARY_DIR}/src/*.cxx"
#             )
            
#             if(LIBRARY_SOURCES)
#                 add_library(${LIBRARY_DIR} STATIC ${LIBRARY_SOURCES})
                
#                 # Add include directories
#                 if(HAS_INCLUDE)
#                     target_include_directories(${LIBRARY_DIR} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/${LIBRARY_DIR}/include")
#                 endif()
                
#                 # Also include src directory for internal headers
#                 target_include_directories(${LIBRARY_DIR} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/${LIBRARY_DIR}/src")
                
#                 set_property(TARGET ${LIBRARY_DIR} PROPERTY FOLDER "third_party")
#             else()
#                 # No source files found, create interface library
#                 add_library(${LIBRARY_DIR} INTERFACE)
#                 if(HAS_INCLUDE)
#                     target_include_directories(${LIBRARY_DIR} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/${LIBRARY_DIR}/include")
#                 endif()
#             endif()
#         else()
#             # Only include directory, create interface library
#             add_library(${LIBRARY_DIR} INTERFACE)
#             target_include_directories(${LIBRARY_DIR} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/${LIBRARY_DIR}/include")
#         endif()
        
#         # Set folder property for IDE organization (works for both STATIC and INTERFACE libraries)
#         set_property(TARGET ${LIBRARY_DIR} PROPERTY FOLDER "third_party")
        
#         list(APPEND THIRD_PARTY_LIBRARIES ${LIBRARY_DIR})
#     endif()
# endforeach()