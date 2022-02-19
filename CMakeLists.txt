cmake_minimum_required (VERSION 3.6)
set_property(GLOBAL PROPERTY USE_FOLDERS On)

#----------------------------------------------------------------

# include project configuration
include(config.cmake)
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
    message(STATUS "Adding third party libraries:")
    foreach(lib ${THIRD_PARTY_LIBRARIES})
        message( "   - " ${lib} )
    endforeach()
endif(THIRD_PARTY_LIBRARIES)

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
    target_compile_features(${PROJECT} PRIVATE cxx_std_17)
    # link third party libraries
    target_link_libraries(${PROJECT} PRIVATE ${THIRD_PARTY_LIBRARIES})    
    # move libs into folders
    set_property(TARGET ${PROJECT} PROPERTY FOLDER "${PROJECT}")
    # match directory structure
    foreach(source ${SOURCES})
        get_filename_component(source_path "${source}" PATH)
        string(REPLACE "/" "\\" source_path_msvc "${source_path}")
        file(RELATIVE_PATH source_path_msvc_rel "${CMAKE_CURRENT_SOURCE_DIR}" "${source_path_msvc}")
        source_group("${source_path_msvc_rel}" FILES "${source}")
    endforeach()
    # append common lib to the third_party_libraries list so sub-projects can link with it
    list(APPEND THIRD_PARTY_LIBRARIES ${PROJECT} )
endif( SOURCES )

# add projects
add_subdirectory(${PROJECTS_DIRECTORY})

if(MSVC)
    # set startup project in visual studio
    if(STARTUP_PROJECT_NAME)
        message( STATUS "Setting startup project: ${STARTUP_PROJECT_NAME}")
        set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${STARTUP_PROJECT_NAME})
    endif(STARTUP_PROJECT_NAME)
endif()