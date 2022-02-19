## project_starter_kit



*This repository contains the basic structure and set of tools I use to quickly setup a c++ project on Windows. It favours prototyping and fast iteration. Spending less time in visual studio project settings and more time on writing code. It's not perfect but it makes my life easier and I like it; maybe you will too.* 



**CMake 3.6** is required to build the project and **Python** to easily add new subprojects.

CMake generates a single solution with everything in it; a list of projects, third party libraries and if needed a common shared library. A system of project template is used to facilitate the addition of new subprojects and favours working with small prototype/test projects inside the same solution. You can easily duplicate projects and move things around without the fear of breaking the solution. It allows to easily add third party libraries and experiments sometimes with just a console application, maybe a small glfw prototype or a more complete cinder app. 

Here's an example of setup after copying the content of the boilerplate inside a new repository and editing the name of the project in *config.cmake*.

```bash
setup glfw imgui
create glfw NewProject 
configure
```

This will add submodules for glfw and imgui, create a glfw project named *NewProject* and generate a visual studio solution inside the build folder. But what if you need to quickly build a small command line tool. The following will add a new project to the solution using another template for raw cpp. No need to change solution or create a separate project.

```bash
create cpp ConsoleApp
configure
```

Let's say that at that point you want to build a larger or more complex app; you could use cinder but not sure whether you want it as a submodule yet and want to just clone it for now.

```bash
setup clone cinder
create cinder GlfwTestApp
configure
```

You get the idea.



#### Basic Configuration

The main `CMakeLists.txt` depends on `config.cmake` to define the name of the project. You'll find there also a few other variables to customize the project setup.

```cmake
# project name
set(PROJECT project_starter_kit) # change the name of your project here
```

The `setup` scripts makes cloning and adding submodule easier for a few of the libraries I tend to use often but the script can be customized to support more libraries. It currently supports cinder, glfw, imgui, nlohmann-json, live++ and imgui_utils. By default it will add those as submodule but the you can easily mix `clone` and `submodule` by adding those to your `setup` command.

```bash
setup cinder clone live++ submodule imgui_utils json
```

This will will add cinder, imgui_utils and json as submodule but clone live++.



#### Project templates

Running `create template project_name` will create a new project inside the `projects` folder. There's a templates to choose from that live inside `tools/project_templates` folder and are meant to be customized. You can also add new template by editing `create_project.py`.

`create` currently supports the following templates: `cinder`,`cpp` and `glfw`. 

It can also accept a few optional arguments such as:

* `--pch` to generate precompiled header along with the project sources
* `--cmake` to add a custom cmake config file for that project only
* `--folders` to generate a include/src folder structure instead of having the .cpp files live at the root of the project

Manually creating a new folder and adding sources to it will work too; meaning you can also easily duplicate a project by just copying its folder. Projects inside the `projects` folder can be a single `.cpp` file or they can follow the usual `/include`,`/src` ,`/assets` structure. If a `pch.h` is detected it will automatically be added to the project configuration. A `project.cmake` file can be added to the root of a project if it needs custom cmake specific to the project

CMake will check for the existence of an assets folder and assets and shaders will be added to the project in their respective folders. As cmake doesn't build inside the projects folders an `ASSETS_DIR_PATH` definition will be added to the project preprocessor (and could for instance be used with a `addAssetDirectory( ASSETS_DIR_PATH )`).



#### Common library

If an `include` and a `src` folder are detected at the root of the repository a common library will be added to the solution. This can be useful to share a common set of tools, a common base app class, etc... among the different projects. The library includes will be added and its binaries will be linked to all projects.



#### Third party libraries

The `configure` build scripts will try to automatically add recognized folders inside `third_party`. It currently supports the same list of libraries as `setup` but if needed extra libraries can be added to the empty section at the end of `third_party/CMakeLists.txt`.  When doing so it is important to append the name of library to the `THIRD_PARTY_LIBRARIES` list if you want it to be linked to your projects.

```cmake
# custom third party libraries
#----------------------------------------------------------------
# my custom lib
list(APPEND THIRD_PARTY_LIBRARIES custom_lib)# allows linking in other projects
add_subdirectory(custom_lib)

#----------------------------------------------------------------
```

You can also use the local `project.cmake` to customize how libraries are added to specific projects but not others.



#### Live++

Live++ can easily be added to both the repository and the solution by doing the following:

```bash
setup live++
configure live++
```

You can later on decide to re-generate the solution without it by simply calling `configure` without the argument:

```bash
configure
```
