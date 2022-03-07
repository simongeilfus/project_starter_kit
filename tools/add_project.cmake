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

function(add_project PROJECT_NAME DEST_FOLDER_NAME)
    # grab sources and add executable
    set(DIR ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME})
    set(OUTPUT_DIR ${CMAKE_BINARY_DIR}/${DEST_FOLDER_NAME}/${PROJECT_NAME})
    file(GLOB_RECURSE SOURCES ${DIR}/*.cpp ${DIR}/*.h)    
    add_executable(${PROJECT_NAME} MACOSX_BUNDLE WIN32 ${SOURCES})
    
    # set output folder
    set_target_properties( ${PROJECT_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${OUTPUT_DIR}" )
    
    # setup compile settings
    if(EXISTS "${DIR}/include")
        target_include_directories(${PROJECT_NAME} PUBLIC "${DIR}/include")
    else()
        target_include_directories(${PROJECT_NAME} PUBLIC "${DIR}")
    endif()
    target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_17)

    # check for extra dependencies
    if(EXISTS ${DIR}/project.cmake)
        include(${DIR}/project.cmake)
        if(DEFINED EXTRA_DEPENDENCIES)
            target_link_libraries(${PROJECT_NAME} PUBLIC ${EXTRA_DEPENDENCIES})
        endif()
    endif()

    # link common and third_party libs
    target_link_libraries(${PROJECT_NAME} PUBLIC ${THIRD_PARTY_LIBRARIES})

    # if necessary add build step to copy assets folder and add it to the project
    if(EXISTS ${DIR}/assets)
        set(ASSETS_DIR ${DIR}/assets)
	    file(GLOB ASSETS "${ASSETS_DIR}/*")
        target_sources(${PROJECT_NAME} PUBLIC ${ASSETS})

        foreach(ASSET ${ASSETS})
            if(${ASSET} MATCHES ".hlsl|.fxh|.vsh|.psh|.fsh|.dsh|.hsh|.gsh|.ash|.msh|.csh|.glsl|.vert|.frag|.geom|.dom|.hull|.amp|.mesh|.task|.tese|.tesc|.comp|.rgen|.rint|.rmiss|.rahit|.rchit|.rcall" )
                source_group("Shader Files" FILES ${ASSET})
                set_property(SOURCE ${ASSET} PROPERTY VS_SETTINGS "ExcludedFromBuild=true")
            else()
                source_group("Asset Files" FILES ${ASSET})
            endif()
        endforeach()

        # file(TO_NATIVE_PATH ${OUTPUT_DIR}/assets ASSETS_DIR_SYM_LINK)
        file(TO_NATIVE_PATH ${ASSETS_DIR} ASSETS_DIR_PATH)
        string(REPLACE "\\" "\\\\" ASSETS_DIR_PATH "${ASSETS_DIR_PATH}")
        target_compile_definitions(${PROJECT_NAME} PUBLIC ASSETS_DIR="${ASSETS_DIR_PATH}")
        # add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        #             COMMAND if NOT EXIST \"${ASSETS_DIR_SYM_LINK}\" ( mklink /d \"${ASSETS_DIR_SYM_LINK}\" ${ASSETS_DIR_PATH} )
        # )
    endif()
    
    # if there's a precompiled header add the necessary project settings
    file(GLOB_RECURSE PCH_HEADER_PATH "${DIR}/*pch.h")
    if(EXISTS ${PCH_HEADER_PATH})
        file(GLOB_RECURSE PCH_SRC_PATH "${DIR}/*pch.cpp")
        set_source_files_properties("${PCH_SRC_PATH}" PROPERTIES COMPILE_FLAGS /Yc"${PCH_HEADER_PATH}")
        target_compile_options(${PROJECT_NAME} PUBLIC /Yu"${PCH_HEADER_PATH}")
        target_compile_options(${PROJECT_NAME} PUBLIC /FI"${PCH_HEADER_PATH}")
    endif()

    # move to the "DEST_FOLDER_NAME" folder
    set_property(TARGET ${PROJECT_NAME} PROPERTY FOLDER ${DEST_FOLDER_NAME})
    
    # match folder structure of source files
    foreach(source IN ITEMS ${SOURCES})
        if (IS_ABSOLUTE "${source}")
            file(RELATIVE_PATH source_rel "${DIR}" "${source}")
        else()
            set(source_rel "${source}")
        endif()
        get_filename_component(source_path "${source_rel}" PATH)
        string(REPLACE "/" "\\" source_path_msvc "${source_path}")
        # if source is not at the root of the project folder
        if( NOT ${source_path} STREQUAL ${DIR} )    
            string(REPLACE "src" "Source Files" source_path_msvc "${source_path_msvc}")
            string(REPLACE "include" "Header Files" source_path_msvc "${source_path_msvc}")
            source_group("${source_path_msvc}" FILES "${source}")
        else()
            # default folders
        endif()
    endforeach()

endfunction(add_project)