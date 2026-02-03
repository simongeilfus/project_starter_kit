cmake_minimum_required( VERSION 3.10 FATAL_ERROR )
include(../tools/add_project.cmake)

# copy the parent list of projects so this scope can append to it
set(PROJECTS ${PROJECTS})

# Function to check if a directory is a project
# A project has source files in its root or src subdirectory
function(is_project DIR_PATH RESULT)
    set(${RESULT} FALSE PARENT_SCOPE)
    
    # Check for CMakeLists.txt (custom project)
    if(EXISTS "${DIR_PATH}/CMakeLists.txt")
        set(${RESULT} TRUE PARENT_SCOPE)
        return()
    endif()
    
    # Check for project.cmake
    if(EXISTS "${DIR_PATH}/project.cmake")
        set(${RESULT} TRUE PARENT_SCOPE)
        return()
    endif()
    
    # Check for source files in root
    file(GLOB ROOT_CPP_FILES "${DIR_PATH}/*.cpp")
    if(ROOT_CPP_FILES)
        set(${RESULT} TRUE PARENT_SCOPE)
        return()
    endif()
    
    # Check for source files in src subdirectory
    file(GLOB SRC_CPP_FILES "${DIR_PATH}/src/*.cpp")
    if(SRC_CPP_FILES)
        set(${RESULT} TRUE PARENT_SCOPE)
        return()
    endif()
endfunction()

# Process all directories
file(GLOB CHILDREN RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/*")

foreach(CHILD ${CHILDREN})
    set(CHILD_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${CHILD}")
    
    if(IS_DIRECTORY "${CHILD_PATH}" AND NOT ${CHILD} MATCHES ".git")
        
        # Check if this directory is a project
        is_project("${CHILD_PATH}" IS_PROJ)
        
        if(IS_PROJ)
            # It's a direct project at root level
            message( "   - ${CHILD}" )
            add_project(${CHILD} "projects")
            list(APPEND PROJECTS ${CHILD})
            
        else()
            # It might be a folder containing projects
            # Check if it has any subdirectories that are projects
            set(HAS_PROJECT_CHILDREN FALSE)
            file(GLOB SUB_CHILDREN RELATIVE ${CHILD_PATH} "${CHILD_PATH}/*")
            
            foreach(SUB_CHILD ${SUB_CHILDREN})
                set(SUB_CHILD_PATH "${CHILD_PATH}/${SUB_CHILD}")
                if(IS_DIRECTORY "${SUB_CHILD_PATH}")
                    is_project("${SUB_CHILD_PATH}" IS_SUB_PROJ)
                    if(IS_SUB_PROJ)
                        set(HAS_PROJECT_CHILDREN TRUE)
                        break()
                    endif()
                endif()
            endforeach()
            
            # If this folder contains projects, process them
            if(HAS_PROJECT_CHILDREN)
                message( "   + ${CHILD}/" )
                
                foreach(SUB_CHILD ${SUB_CHILDREN})
                    set(SUB_CHILD_PATH "${CHILD_PATH}/${SUB_CHILD}")
                    if(IS_DIRECTORY "${SUB_CHILD_PATH}")
                        is_project("${SUB_CHILD_PATH}" IS_SUB_PROJ)
                        if(IS_SUB_PROJ)
                            message( "      - ${SUB_CHILD}" )
                            
                            # Save and modify CMAKE_CURRENT_SOURCE_DIR for add_project to work correctly
                            set(SAVED_CMAKE_CURRENT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
                            set(CMAKE_CURRENT_SOURCE_DIR "${CHILD_PATH}")
                            
                            # Add the project with folder hierarchy in VS
                            add_project(${SUB_CHILD} "projects/${CHILD}")
                            
                            # Restore the original source dir
                            set(CMAKE_CURRENT_SOURCE_DIR ${SAVED_CMAKE_CURRENT_SOURCE_DIR})
                            
                            list(APPEND PROJECTS ${CHILD}/${SUB_CHILD})
                        endif()
                    endif()
                endforeach()
            endif()
        endif()
    endif()
endforeach(CHILD)

# update the parent list of projects
set(PROJECTS ${PROJECTS} PARENT_SCOPE )