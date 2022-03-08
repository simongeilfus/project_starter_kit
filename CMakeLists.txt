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

cmake_minimum_required (VERSION 3.6)
set_property(GLOBAL PROPERTY USE_FOLDERS On)

#----------------------------------------------------------------

# include project configuration
include(options.cmake)
if(NOT PROJECT)
    message(FATAL_ERROR "Project name undefined. Please update config.cmake")
endif()

message(STATUS "Generating project solution for: ${PROJECT}")

# set the project name
project(${PROJECT})

# change runtime library
if(MSVC)
    add_compile_options($<$<CONFIG:Release>:/MT> # Runtime library: Multi-threaded
                    $<$<CONFIG:RelWithDebInfo>:/MT> # Runtime library: Multi-threaded                           
                    $<$<CONFIG:Debug>:/MTd> # Runtime library: Multi-threaded Debug
                    )
endif()
                    
# third party libraries
set(THIRD_PARTY_LIBRARIES "" )
add_subdirectory(${THIRD_PARTY_DIRECTORY})

if(THIRD_PARTY_LIBRARIES)
    message(STATUS "Configuring third party libraries:")
    foreach(lib ${THIRD_PARTY_LIBRARIES})
        message( "   - " ${lib} )
    endforeach()
endif()

# setup the project's common library
file(GLOB_RECURSE SOURCES 
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/include/*.h"
)
if( SOURCES )
    message(STATUS "Adding common library: ${PROJECT}.lib")
    # library sources and includes
    set(INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
    add_library(${PROJECT} STATIC ${SOURCES})
    target_include_directories(${PROJECT} PUBLIC "${INCLUDE_DIR}")
    # specify the C++ standard
    target_compile_features(${PROJECT} PRIVATE ${CXX_STANDARD})
    # link third party libraries
    target_link_libraries(${PROJECT} PRIVATE ${THIRD_PARTY_LIBRARIES})    
    # move libs into folders
    set_property(TARGET ${PROJECT} PROPERTY FOLDER "${PROJECT}")
    # match directory structure
    if(MSVC)
        foreach(source ${SOURCES})
            get_filename_component(source_path "${source}" PATH)
            string(REPLACE "/" "\\" source_path_msvc "${source_path}")
            file(RELATIVE_PATH source_path_msvc_rel "${CMAKE_CURRENT_SOURCE_DIR}" "${source_path_msvc}")
            source_group("${source_path_msvc_rel}" FILES "${source}")
        endforeach()
    endif()
    # append common lib to the third_party_libraries list so sub-projects can link with it
    list(APPEND THIRD_PARTY_LIBRARIES ${PROJECT} )
endif()

# add projects
set(PROJECTS "" )
add_subdirectory(${PROJECTS_DIRECTORY})

# project startup
if(MSVC)
    if(NOT STARTUP_PROJECT_NAME AND PROJECTS)
        list(GET PROJECTS 0 STARTUP_PROJECT_NAME)
    endif()
    # set startup project in visual studio
    if(STARTUP_PROJECT_NAME)
        message( STATUS "Setting startup project: ${STARTUP_PROJECT_NAME}")
        set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${STARTUP_PROJECT_NAME})
    endif()
endif()