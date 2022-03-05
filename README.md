# project_starter_kit



**This repository is an attempt at unifying the build scripts and tools I often use to setup a c++ project on Windows.**  

*It is a collection of python and cmake scripts that I have found useful or use often. The common idea behind those script is to make iterative prototyping fast and effort less. Spending less time in visual studio project settings and more time writing code.* 

*It is also an ongoing project and might still contain some rough edges but it has made my life easier so far.* 



### Requirements

**CMake 3.6** is required to build the project and **Python** to easily add new subprojects.

### Introduction

CMake is used to generate a single solution with everything in it; a list of projects, third party libraries and if needed a common shared library. A system of project template is used to facilitate the addition of new subprojects and favours working with small prototype/test projects inside the same solution. You can easily duplicate projects and move things around without the fear of breaking the solution. It allows to easily add third party libraries and experiments sometimes with just a console application, maybe a small glfw prototype or move to a more complete cinder app. 

Here's an example of setup after copying the content of the boilerplate inside a new repository.

```bash
setup glfw imgui
create glfw NewProject 
configure
```

This will add submodules for glfw and imgui, create a glfw project named *NewProject* and generate a visual studio solution inside the build folder. 

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

`setup` takes two kind of arguments, the names of libraries to add to the project and whether the script has to add them as clones or submodules. You can change mode as many time as you want but it will starts and defaults to submodules.

````bash
setup glfw imgui stb
````

This will setup glfw, imgui and stb as submodules inside the `third_party` folder.

The `setup` scripts makes cloning and adding submodule easier for a few of the libraries I tend to use often but the content of `third_party.txt` can be customized to support more libraries. By default it will add those as submodule but you can easily mix `clone` and `submodule` by adding those to your `setup` command.

```bash
setup glfw imgui clone liveplusplus submodule imgui_utils json
```

This will will add glfw, imgui, imgui_utils and json as submodule but clone liveplusplus.

### CREATE script

`create` is used to quickly generate new projects to be added to the solution. Running `create template project_name` will create a new project inside the `projects` folder. There's a few templates to choose from that live inside `tools/project_templates` folder and are meant to be customized. You can also add new template by editing `create_project.py`.

`create` currently supports the following templates: `cinder`,`cpp`, `glfw` and `sokol`. 

It can also accept a few optional arguments such as:

* `--pch` specifies whether the project needs to be generated with pch files

* `--cmake` specifies whether the project needs a custom cmake config file

* `--folders` specifies whether the project wants sources to be created inside subfolders instead of at the project root

* `--configure` specifies whether solution need to be generated after creating the project

* `--configure++` specifies whether solution need to be generated after creating the project



Manually creating a new folder and adding sources to it will work too; meaning you can also easily duplicate a project by just copying its folder. Projects inside the `projects` folder can be a single `.cpp` file or they can follow the usual `/include`,`/src` ,`/assets` structure. If a `pch.h` is detected it will automatically be added to the project configuration. A `project.cmake` file can be added to the root of a project if it needs custom cmake specific to the project.

### CONFIGURE script

`configure` is a simple batch script that generates the solution files using CMake. You can use `configure live++` to enable Live++ in the solution.

The main `CMakeLists.txt` will include a few variables from `options.cmake` . You'll find there a few options like the name of the generated solution/project.

```cmake
# project name
set(PROJECT project_starter_kit) # change the name of your project here
```

### Assets

CMake will check for the existence of an assets folder. Assets and shaders will be added to the project in their respective folders. As cmake doesn't build inside the projects folders an `ASSETS_DIR_PATH` definition will be added to the project preprocessor (and could for instance be used with a `addAssetDirectory( ASSETS_DIR_PATH )`).

### Common library

If an `include` and a `src` folder are detected at the root of the repository a common library will be added to the solution. This can be useful to share a common set of tools, a common base app class, etc... among the different projects. The library includes will be added and its binaries will be linked to all projects.

### Third party libraries

The `configure` build scripts will try to automatically add recognized folders inside `third_party`. It currently supports the same list of libraries as `setup` but if needed extra libraries can be added to the empty section at the end of `third_party/CMakeLists.txt`.  When doing so it is important to append the name of library to the `THIRD_PARTY_LIBRARIES` list if you want it to be linked to your projects.

```cmake
# custom third party libraries
#----------------------------------------------------------------
# my custom lib
list(APPEND THIRD_PARTY_LIBRARIES custom_lib) # allows linking in other projects
add_subdirectory(custom_lib)
```

You can also use the local `project.cmake` to customize how libraries are added to specific projects but not others.

### Live++

Live++ can easily be added to both the repository and the solution by doing the following:

```bash
setup liveplusplus
configure live++
```

You can later on decide to re-generate the solution without it by simply calling `configure` without the argument:

```bash
configure
```
