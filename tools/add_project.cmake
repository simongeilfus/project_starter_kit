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
    set(PROJECT_OUTPUT_DIR ${CMAKE_BINARY_DIR}/bin/${DEST_FOLDER_NAME}/${PROJECT_TARGET})
    file(GLOB_RECURSE PROJECT_SOURCE_FILES ${PROJECT_DIR}/*.cpp ${PROJECT_DIR}/*.h)
    file(GLOB_RECURSE PROJECT_RESOURCES_FILES ${PROJECT_DIR}/*.qrc)
    file(GLOB_RECURSE PROJECT_UI_FILES ${PROJECT_DIR}/*.ui)
    # Windows resource files (e.g. resources/Resources.rc with `1 ICON "app.ico"` for the app icon)
    if(WIN32)
        file(GLOB PROJECT_RC_FILES ${PROJECT_DIR}/resources/*.rc)
        file(GLOB PROJECT_ICO_FILES ${PROJECT_DIR}/resources/*.ico)
    endif()

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

    # custom CMakeLists.txt project
    if(EXISTS ${PROJECT_DIR}/CMakeLists.txt)
        add_subdirectory(${PROJECT_DIR})
    # regular project
    else()
        # add the default add_executable
        add_executable(${PROJECT_TARGET} ${PROJECT_OS_BUNDLE} ${PROJECT_SOURCE_FILES} ${PROJECT_UI_FILES} ${PROJECT_RESOURCES_FILES} ${PROJECT_RC_FILES} ${PROJECT_ICO_FILES})

        # group .rc/.ico under "Resource Files" and exclude .ico from build (referenced by .rc)
        foreach(RC ${PROJECT_RC_FILES})
            source_group("Resource Files" FILES ${RC})
        endforeach()
        foreach(ICO ${PROJECT_ICO_FILES})
            source_group("Resource Files" FILES ${ICO})
            set_property(SOURCE ${ICO} PROPERTY VS_SETTINGS "ExcludedFromBuild=true")
        endforeach()

        # include project.cmake if any
        if(EXISTS ${PROJECT_DIR}/project.cmake)
            include(${PROJECT_DIR}/project.cmake)
        endif()
        
        # setup compile settings
        if(EXISTS "${PROJECT_DIR}/include")
            target_include_directories(${PROJECT_TARGET} PUBLIC "${PROJECT_DIR}/include")
        else()
            target_include_directories(${PROJECT_TARGET} PUBLIC "${PROJECT_DIR}")
        endif()
        target_compile_features(${PROJECT_TARGET} PUBLIC ${CXX_STANDARD})

        # link common and third_party libs
        if( ENABLE_LXX_CONFIGS )
            target_link_libraries(${PROJECT_TARGET} PUBLIC
                ${THIRD_PARTY_LIBRARIES}
                $<$<OR:$<CONFIG:DebugLxx>,$<CONFIG:ReleaseLxx>>:liveplusplus>
            )
            target_compile_definitions(${PROJECT_TARGET} PUBLIC
                $<$<OR:$<CONFIG:DebugLxx>,$<CONFIG:ReleaseLxx>>:LPP_ENABLED>
                $<$<OR:$<CONFIG:DebugLxx>,$<CONFIG:ReleaseLxx>>:LPP_PATH=\"${CMAKE_CURRENT_SOURCE_DIR}/third_party/LivePP\">
            )
            target_link_libraries(${PROJECT_TARGET} PUBLIC
                $<$<OR:$<CONFIG:DebugLxx>,$<CONFIG:ReleaseLxx>>:Shlwapi>
                $<$<OR:$<CONFIG:DebugLxx>,$<CONFIG:ReleaseLxx>>:Opengl32>
            )
        else()
            target_link_libraries(${PROJECT_TARGET} PUBLIC ${THIRD_PARTY_LIBRARIES})
        endif()

        # Add post-build steps to copy registered runtime DLLs
        foreach(DLL_ENTRY ${THIRD_PARTY_RUNTIME_DLLS})
            string(REPLACE "|" ";" DLL_PARTS "${DLL_ENTRY}")
            list(GET DLL_PARTS 0 DLL_SOURCE)
            list(LENGTH DLL_PARTS PARTS_COUNT)
            if(PARTS_COUNT GREATER 1)
                list(GET DLL_PARTS 1 DLL_SUBDIR)
            else()
                set(DLL_SUBDIR "")
            endif()

            # Determine destination directory
            if(DLL_SUBDIR STREQUAL "")
                set(DLL_DEST "$<TARGET_FILE_DIR:${PROJECT_TARGET}>")
            else()
                set(DLL_DEST "$<TARGET_FILE_DIR:${PROJECT_TARGET}>/${DLL_SUBDIR}")
            endif()

            # Check if source is a directory or file
            if(DLL_SOURCE MATCHES "\\$<")
                # Contains generator expression - assume it's a file
                add_custom_command(TARGET ${PROJECT_TARGET} POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    "${DLL_SOURCE}"
                    "${DLL_DEST}"
                    COMMENT "Copying runtime DLL"
                )
            else()
                # Check if it's a directory
                if(IS_DIRECTORY "${DLL_SOURCE}")
                    add_custom_command(TARGET ${PROJECT_TARGET} POST_BUILD
                        COMMAND ${CMAKE_COMMAND} -E copy_directory
                        "${DLL_SOURCE}"
                        "${DLL_DEST}"
                        COMMENT "Copying runtime DLLs"
                    )
                else()
                    # It's a file path
                    add_custom_command(TARGET ${PROJECT_TARGET} POST_BUILD
                        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                        "${DLL_SOURCE}"
                        "${DLL_DEST}"
                        COMMENT "Copying runtime DLL"
                    )
                endif()
            endif()
        endforeach()

        # if necessary add build step to copy assets folder and add it to the project
        if(EXISTS ${PROJECT_DIR}/assets AND IS_DIRECTORY ${PROJECT_DIR}/assets)
            set(ASSETS_DIR ${PROJECT_DIR}/assets)
            file(GLOB ASSETS "${ASSETS_DIR}/*")
            target_sources(${PROJECT_TARGET} PUBLIC ${ASSETS})

            foreach(ASSET ${ASSETS})
                if(${ASSET} MATCHES "\\.(hlsl|fxh|vsh|psh|fsh|dsh|hsh|gsh|ash|msh|csh|glsl|vert|frag|geom|dom|hull|amp|mesh|task|tese|tesc|comp|rgen|rint|rmiss|rahit|rchit|rcall)$" )
                    source_group("Shader Files" FILES ${ASSET})
                    set_property(SOURCE ${ASSET} PROPERTY VS_SETTINGS "ExcludedFromBuild=true")
                else()
                    source_group("Asset Files" FILES ${ASSET})
                    set_property(SOURCE ${ASSET} PROPERTY VS_SETTINGS "ExcludedFromBuild=true")
                endif()
            endforeach()
            
            get_filename_component( ASSETS_DEST_PATH "${PROJECT_OUTPUT_DIR}/assets" ABSOLUTE )
            file( TO_NATIVE_PATH "${ASSETS_DEST_PATH}" link )
            file( TO_NATIVE_PATH "${ASSETS_DIR}" target )

            # Only (re)create the junction if it isn't already there — running mklink
            # every reconfigure pollutes the log with "Junction created for ..." even
            # in --log-level=ERROR mode. If the source path changes, clean the build dir.
            if( NOT EXISTS "${ASSETS_DEST_PATH}" OR NOT IS_SYMLINK "${ASSETS_DEST_PATH}" )
                # plain directory (not a junction): remove first so mklink can replace it
                if( EXISTS "${ASSETS_DEST_PATH}" )
                    file( REMOVE_RECURSE "${ASSETS_DEST_PATH}" )
                endif()

                file( MAKE_DIRECTORY "${PROJECT_OUTPUT_DIR}" )

                execute_process(
                    COMMAND cmd.exe /c mklink /J ${link} ${target}
                    RESULT_VARIABLE resultCode
                    OUTPUT_QUIET
                    ERROR_VARIABLE errorMessage
                )

                if( NOT resultCode EQUAL 0 )
                    message( WARNING "Failed to symlink '${ASSETS_DIR}' to '${ASSETS_DEST_PATH}': ${errorMessage}" )
                endif()
            endif()
            
            # file(TO_NATIVE_PATH ${PROJECT_OUTPUT_DIR}/assets ASSETS_DIR_SYM_LINK)
            #file(TO_NATIVE_PATH ${ASSETS_DIR} ASSETS_DIR_PATH)
            #string(REPLACE "\\" "\\\\" ASSETS_DIR_PATH "${ASSETS_DIR_PATH}")
            #target_compile_definitions(${PROJECT_TARGET} PUBLIC ASSETS_DIR="${ASSETS_DIR_PATH}")
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
    endif()
        
    # set output folders
    set_target_properties(${PROJECT_TARGET} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${PROJECT_OUTPUT_DIR}"
        PDB_OUTPUT_DIRECTORY "${PROJECT_OUTPUT_DIR}"
    )

    # move to the "DEST_FOLDER_NAME" folder
    set_property(TARGET ${PROJECT_TARGET} PROPERTY FOLDER ${DEST_FOLDER_NAME})
    
    # Get all sources including those propagated from INTERFACE libraries
    get_target_property(ALL_SOURCES ${PROJECT_TARGET} SOURCES)

    # Separate project sources from third-party sources
    set(THIRD_PARTY_SOURCES "")
    foreach(src ${ALL_SOURCES})
        # If source is NOT from project directory, it's from third-party
        if(NOT src MATCHES "^${PROJECT_DIR}")
            list(APPEND THIRD_PARTY_SOURCES ${src})
        endif()
    endforeach()

    # match folder structure of source files
    foreach(source IN ITEMS ${PROJECT_SOURCE_FILES})
        if (IS_ABSOLUTE "${source}")
            file(RELATIVE_PATH source_rel "${PROJECT_DIR}" "${source}")
        else()
            set(source_rel "${source}")
        endif()
        get_filename_component(source_path "${source_rel}" PATH)
        get_filename_component(source_ext "${source}" EXT)

        # Determine if header or source file
        set(is_header FALSE)
        if(source_ext MATCHES "\\.(h|hpp|hxx|inl)$")
            set(is_header TRUE)
        endif()

        # Build the Visual Studio folder path
        if(NOT source_path STREQUAL "")
            # Remove src/ or include/ prefix and preserve subdirectory structure
            string(REGEX REPLACE "^src[/\\]?" "" source_path_clean "${source_path}")
            string(REGEX REPLACE "^include[/\\]?" "" source_path_clean "${source_path_clean}")

            # Convert to backslashes for VS
            string(REPLACE "/" "\\" source_path_msvc "${source_path_clean}")

            # Prepend Header Files or Source Files
            if(is_header)
                if(source_path_msvc STREQUAL "")
                    set(group_path "Header Files")
                else()
                    set(group_path "Header Files\\${source_path_msvc}")
                endif()
            else()
                if(source_path_msvc STREQUAL "")
                    set(group_path "Source Files")
                else()
                    set(group_path "Source Files\\${source_path_msvc}")
                endif()
            endif()

            source_group("${group_path}" FILES "${source}")
        endif()
    endforeach()
endfunction(add_project)