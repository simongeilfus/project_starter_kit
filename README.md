# project_starter_kit



**This repository is an attempt at unifying the build scripts and tools I often use to setup a c++ project on Windows.**  

*This is a collection of python and cmake scripts that I have found useful or use often. The common idea behind those scripts is to make iterative prototyping fast and effortless. Spending less time in visual studio project settings and more time writing code.* 

*It is also an ongoing project and might still contain some rough edges but it has made my life easier so far.* 



### Requirements

**CMake 3.6** is required to build the project and **Python** to easily add new subprojects. If not already installed the easiest to get them is to run `setup cmake python`.

### Introduction

CMake is used to generate a single solution with everything in it; a list of projects, third party libraries and if needed a common shared library. A system of project template is used to facilitate the addition of new subprojects and favours working with small prototype/test projects inside the same solution. You can easily duplicate projects and move things around without the fear of breaking the solution. It allows to easily add third party libraries and experiments sometimes with just a console application, maybe a small glfw prototype or move to a more complete cinder app. 

Here's an example of setup after copying the content of the boilerplate inside a new repository.

```bash
setup glfw glad imgui
create glfw NewProject 
configure
```

This will add submodules for glfw, glad and imgui, create a glfw project named *NewProject* and generate a visual studio solution inside the build folder. 

The following will add a new project to the solution using another template for raw cpp. No need to change solution or create a separate project.

```bash
create cpp ConsoleApp
configure
```

Let's say that at that point you want to build a larger or more complex app; you could use cinder but not sure whether you want it as a submodule yet and want to just clone it for now.

```bash
setup clone cinder
create cinder CinderTestApp
configure
```

You get the idea.

### SETUP script

`setup` takes two kind of arguments, the names of libraries or tools to add to the project and whether the script has to add them as clones or submodules. You can change mode as many time as you want but it will start and default to submodules. `setup` can also be used to download and install `cmake`, `python` or `vulkan`.

````bash
setup cmake glfw imgui stb
````

This will download and instand cmake, and setup glfw, imgui and stb as submodules inside the `third_party` folder.

The `setup` scripts makes cloning and adding submodule easier for a few of the libraries I tend to use often but the content of `third_party.txt` can be customized to support more libraries. It currently supports [cereal](https://github.com/USCiLab/cereal), [cinder](https://github.com/cinder/Cinder), [csv](https://github.com/ben-strasser/fast-cpp-csv-parser), [cxxopts](https://github.com/jarro2783/cxxopts), [date](https://github.com/HowardHinnant/date), [entt](https://github.com/skypjack/entt), [glad](https://github.com/Dav1dde/glad), [glfw](https://github.com/glfw/glfw), [glm](https://github.com/g-truc/glm), [glslang](https://github.com/KhronosGroup/glslang), [hfsm2](https://github.com/andrew-gresyk/HFSM2), [imgui](https://github.com/ocornut/ImGui), [imgui_utils](https://github.com/simongeilfus/imgui_utils), [json](https://github.com/nlohmann/json), [liveplusplus](https://github.com/simongeilfus/liveplusplus), [pybind11](https://github.com/pybind/pybind11), [sokol](https://github.com/floooh/sokol), [stb](https://github.com/nothings/stb), [taskflow](https://github.com/taskflow/taskflow), [tinyexr](https://github.com/syoyo/tinyexr), [tinyobj](https://github.com/tinyobjloader/tinyobjloader), [ufbx](https://github.com/bqqbarbhg/ufbx), [vma](https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator), [volk](https://github.com/zeux/volk), and [vulkanhpp](https://github.com/KhronosGroup/Vulkan-Headers). By default it will add those as submodule but you can easily mix `clone` and `submodule` by adding those to your `setup` command.

```bash
setup glfw imgui clone liveplusplus submodule imgui_utils json
```

This will will add glfw, imgui, imgui_utils and json as submodule but clone liveplusplus.

An easy way to get a vulkan project up would be to run the following, which would download and install the latest vulkan sdk and add glfw, volk and vma as submodule.

```bash
setup vulkan glfw volk vma
```



### CREATE script

`create` is used to quickly generate new projects to be added to the solution. Running `create template project_name` will create a new project inside the `projects` folder. There's a few templates to choose from that live inside `tools/project_templates` folder and are meant to be customized.

`create` currently supports the following templates: `cinder`,`cpp`, `glfw` and `sokol`. 

It can also accept a few optional arguments such as:

* `--pch` specifies whether the project needs to be generated with pch files

* `--cmake` specifies whether the project needs a custom cmake config file

* `--folders` specifies whether the project wants sources to be created inside subfolders instead of at the project root

* `--configure` specifies whether solution need to be generated after creating the project

* `--configure++` specifies whether solution need to be generated after creating the project

##### Manually creating or duplicating projects

Manually creating a new folder and adding sources to it will work too; meaning you can also easily duplicate a project by just copying its folder. Projects inside the `projects` folder can be a single `.cpp` file or they can follow the usual `/include`,`/src` ,`/assets` structure. If a `pch.h` is detected it will automatically be added to the project configuration. A `project.cmake` file can be added to the root of a project if it needs custom cmake specific to the project.

##### Custom template

 You can also easily add new template by adding a new folder inside `tools/project_templates` containing at least a `template.cpp`. The template process doesn't do much apart from copying the content of the folder and renaming the `template.cpp` to the name of your project. It will also look for a `TEMPLATE` string inside that file and replace it with the name of the project as well.

### CONFIGURE script

`configure` calls the main CMakeLists.txt and generates a visual studio solution with the projects presents in the *projects* folder, a shared library if any and any third party libraries recognized inside the *third_party* folder. The solution file will be generated inside the `build` folder. You can use `configure live++` to enable Live++ in the solution.

The main `CMakeLists.txt` will include a few variables from `options.cmake` . You'll find there a few options like the name of the generated solution/project which you might want to customize if your project isn't named *project_starter_kit*.

```cmake
# project name
set(PROJECT project_starter_kit) # change the name of your project here
```

##### Common library

If an `include` and a `src` folder are detected at the root of the repository a common library will be added to the solution. This can be useful to share a common set of tools, a common base app class, etc... among the different projects. The library includes will be added and its binaries will be linked to all projects.

##### assets

CMake will check for the existence of an assets folder. Assets and shaders will be added to the project in their respective folders. As cmake doesn't build inside the projects folders an `ASSETS_DIR_PATH` definition will be added to the project preprocessor (and could for instance be used with a `addAssetDirectory( ASSETS_DIR_PATH )`).

##### project.cmake

As mentioned before, adding a `project.cmake` allows to customize the configuration of a specific project. The most basic customization is to override the default `THIRD_PARTY_LIBRARIES` to link to only a selection of the shared libraries.

```cmake
set(THIRD_PARTY_LIBRARIES glfw glm)
```

If the project requires a more custom configuration a couple of macros can be defined to override the system's default behavior.  

**`macro(project_configuration)`** can be defined to execute a configuration after the project's target has been created. You can use `${PROJECT_TARGET}` as the target name to set any target property, libraries, include directories, etc... specific to that project. 

```cmake
macro(project_configuration)
    # set the executable type
    target_link_options(${PROJECT_TARGET} PRIVATE "/SUBSYSTEM:WINDOWS" "/ENTRY:mainCRTStartup")
endmacro()
```

**`macro(project_executable)`** can be defined to be used in place of the default `add_executable` for more complex situations where things need to be setup before and after adding the executable.

```cmake
macro(project_executable)
    set(CMAKE_AUTOMOC ON)
    set(CMAKE_AUTORCC ON)
    set(CMAKE_AUTOUIC ON)
    set(CMAKE_PREFIX_PATH "D:/Qt/6.2.3/msvc2019_64/")

    find_package(Qt6 COMPONENTS Core Widgets Gui REQUIRED)
    
    add_executable(${PROJECT_TARGET} ${PROJECT_OS_BUNDLE} ${PROJECT_SOURCE_FILES} ${PROJECT_UI_FILES} ${PROJECT_RESOURCES_FILES})
endmacro()  
```

The following variables are accessible for each project: `${PROJECT_DIR}`, `${PROJECT_OUTPUT_DIR}`, 
`${PROJECT_TARGET}`, `${PROJECT_OS_BUNDLE}`, `${PROJECT_SOURCE_FILES}`, `${PROJECT_UI_FILES}`, `${PROJECT_RESOURCES_FILES}`.

##### Third party libraries

The `configure` build scripts will try to automatically add recognized folders inside the `third_party` folder. It currently supports the same list of libraries included in `third_party.txt`. Other third party libraries can be added to the empty section at the end of `third_party/CMakeLists.txt`.  When adding a new third party library it is important to append the name of the library to the `THIRD_PARTY_LIBRARIES` list if you want it to be linked to your projects.

```cmake
# custom third party libraries
#----------------------------------------------------------------
# my custom lib
list(APPEND THIRD_PARTY_LIBRARIES custom_lib) # allows linking in other projects
add_subdirectory(custom_lib)
```

##### Live++

Live++ can easily be added to both the repository and the solution by doing the following:

```bash
setup liveplusplus
configure live++
```

You can later on decide to re-generate the solution without it by simply calling `configure` without the argument:

```bash
configure
```
