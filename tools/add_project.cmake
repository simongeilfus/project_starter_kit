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

function(add_project PROJECT_TARGET DEST_FOLDER_NAME)
    
    # collect project folders and sources
    set(PROJECT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_TARGET})
    set(PROJECT_OUTPUT_DIR ${CMAKE_BINARY_DIR}/${DEST_FOLDER_NAME}/${PROJECT_TARGET})
    file(GLOB_RECURSE PROJECT_SOURCE_FILES ${PROJECT_DIR}/*.cpp ${PROJECT_DIR}/*.h)
    file(GLOB_RECURSE PROJECT_RESOURCES_FILES ${PROJECT_DIR}/*.qrc)
    file(GLOB_RECURSE PROJECT_UI_FILES ${PROJECT_DIR}/*.ui)
    
    # find the right OS_BUNDLE type
    if( ${OS_BUNDLE} MATCHES AUTO )
        if( WIN32 )
            set(PROJECT_OS_BUNDLE WIN32)
        elseif( APPLE )
            set(PROJECT_OS_BUNDLE MACOSX_BUNDLE)
        endif()
    else()
        set(PROJECT_OS_BUNDLE ${OS_BUNDLE})
    endif()

    # include project.cmake if any
    if(EXISTS ${PROJECT_DIR}/project.cmake)
        include(${PROJECT_DIR}/project.cmake)
    endif()

    # add executable
    if( COMMAND project_executable )
        # if project.cmake defines project_executable, let the project setup the executable
        project_executable()
    else()
        #otherwise use the default add_executable
        add_executable(${PROJECT_TARGET} ${PROJECT_OS_BUNDLE} ${PROJECT_SOURCE_FILES} ${PROJECT_UI_FILES} ${PROJECT_RESOURCES_FILES})
    endif()

    # let project.cmake run its project configuration if any
    if( COMMAND project_configuration )
        project_configuration()
    endif()
    
    # set output folder
    set_target_properties( ${PROJECT_TARGET} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${PROJECT_OUTPUT_DIR}" )
    
    # setup compile settings
    if(EXISTS "${PROJECT_DIR}/include")
        target_include_directories(${PROJECT_TARGET} PUBLIC "${PROJECT_DIR}/include")
    else()
        target_include_directories(${PROJECT_TARGET} PUBLIC "${PROJECT_DIR}")
    endif()
    target_compile_features(${PROJECT_TARGET} PUBLIC ${CXX_STANDARD})

    # link common and third_party libs
    target_link_libraries(${PROJECT_TARGET} PUBLIC ${THIRD_PARTY_LIBRARIES})

    # if necessary add build step to copy assets folder and add it to the project
    if(EXISTS ${PROJECT_DIR}/assets)
        set(ASSETS_DIR ${PROJECT_DIR}/assets)
	    file(GLOB ASSETS "${ASSETS_DIR}/*")
        target_sources(${PROJECT_TARGET} PUBLIC ${ASSETS})

        foreach(ASSET ${ASSETS})
            if(${ASSET} MATCHES ".hlsl|.fxh|.vsh|.psh|.fsh|.dsh|.hsh|.gsh|.ash|.msh|.csh|.glsl|.vert|.frag|.geom|.dom|.hull|.amp|.mesh|.task|.tese|.tesc|.comp|.rgen|.rint|.rmiss|.rahit|.rchit|.rcall" )
                source_group("Shader Files" FILES ${ASSET})
                set_property(SOURCE ${ASSET} PROPERTY VS_SETTINGS "ExcludedFromBuild=true")
            else()
                source_group("Asset Files" FILES ${ASSET})
            endif()
        endforeach()

        # file(TO_NATIVE_PATH ${PROJECT_OUTPUT_DIR}/assets ASSETS_DIR_SYM_LINK)
        file(TO_NATIVE_PATH ${ASSETS_DIR} ASSETS_DIR_PATH)
        string(REPLACE "\\" "\\\\" ASSETS_DIR_PATH "${ASSETS_DIR_PATH}")
        target_compile_definitions(${PROJECT_TARGET} PUBLIC ASSETS_DIR="${ASSETS_DIR_PATH}")
        # add_custom_command(TARGET ${PROJECT_TARGET} POST_BUILD
        #             COMMAND if NOT EXIST \"${ASSETS_DIR_SYM_LINK}\" ( mklink /d \"${ASSETS_DIR_SYM_LINK}\" ${ASSETS_DIR_PATH} )
        # )
    endif()
    
    # if there's a precompiled header add the necessary project settings
    file(GLOB_RECURSE PCH_HEADER_PATH "${PROJECT_DIR}/*pch.h")
    if(EXISTS ${PCH_HEADER_PATH})
        file(GLOB_RECURSE PCH_SRC_PATH "${PROJECT_DIR}/*pch.cpp")
        set_source_files_properties("${PCH_SRC_PATH}" PROPERTIES COMPILE_FLAGS /Yc"${PCH_HEADER_PATH}")
        target_compile_options(${PROJECT_TARGET} PUBLIC /Yu"${PCH_HEADER_PATH}")
        target_compile_options(${PROJECT_TARGET} PUBLIC /FI"${PCH_HEADER_PATH}")
    endif()

    # move to the "DEST_FOLDER_NAME" folder
    set_property(TARGET ${PROJECT_TARGET} PROPERTY FOLDER ${DEST_FOLDER_NAME})
    
    # match folder structure of source files
    foreach(source IN ITEMS ${PROJECT_SOURCE_FILES})
        if (IS_ABSOLUTE "${source}")
            file(RELATIVE_PATH source_rel "${PROJECT_DIR}" "${source}")
        else()
            set(source_rel "${source}")
        endif()
        get_filename_component(source_path "${source_rel}" PATH)
        string(REPLACE "/" "\\" source_path_msvc "${source_path}")
        # if source is not at the root of the project folder
        if( NOT ${source_path} STREQUAL ${PROJECT_DIR} )    
            string(REPLACE "src" "Source Files" source_path_msvc "${source_path_msvc}")
            string(REPLACE "include" "Header Files" source_path_msvc "${source_path_msvc}")
            source_group("${source_path_msvc}" FILES "${source}")
        else()
            # default folders
        endif()
    endforeach()

endfunction(add_project)