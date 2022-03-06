cmake_minimum_required (VERSION 3.6)

include(../tools/add_project.cmake)

# copy the parent list of projects so this scope can append to it
set(PROJECTS ${PROJECTS})

# add all projects in the list
file(GLOB CHILDREN RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/*")
message(STATUS "Configuring projects: " ${CHILD})
foreach(CHILD ${CHILDREN})
    if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${CHILD}" AND NOT ${CHILD} MATCHES ".git")
        message( "   - ${CHILD}" )
        add_project(${CHILD} "projects")
        list(APPEND PROJECTS ${CHILD})
    endif()
endforeach(CHILD)

# update the parent list of projects
set(PROJECTS ${PROJECTS} PARENT_SCOPE )