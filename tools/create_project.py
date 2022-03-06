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

import os, sys, shutil, glob, argparse, subprocess

# search for available templates
templates = []
template_directory = os.fsencode( "tools/project_templates/" )
    
for path in os.listdir( template_directory ):
    if os.path.isdir( os.path.join( template_directory, path ) ) :
        templates.append( os.fsdecode( path ) )

# script arguments
parser = argparse.ArgumentParser()
parser.add_argument( 'template', choices=templates, help='specifies the template to be used to generate the project' )
parser.add_argument( 'project_name', help='specifies the name of the project' )
parser.add_argument( '--pch', action='store_true', help='specifies whether the project needs to be generated with pch files' )
parser.add_argument( '--cmake', action='store_true', help='specifies whether the project needs a custom cmake config file' )
parser.add_argument( '--folders', action='store_true', help='specifies whether the project wants sources to be created inside subfolders instead of at the project root' )
parser.add_argument( '--configure', action='store_true', help='specifies whether solution need to be generated after creating the project' )
parser.add_argument( '--configure++', dest='configureplusplus', action='store_true', help='specifies whether solution need to be generated after creating the project' )
args = parser.parse_args()

# make sure the project doesn't exist
project_name = args.project_name
project_dir = os.path.join( "projects", project_name )
if os.path.exists( project_dir ):
    print( "Project %s already exists" % project_name )
    exit()

# create folder
os.makedirs( project_dir )

# copy template files
def copy_files(src_dir, target_dir, extension):
    files = glob.iglob( os.path.join( src_dir, extension ) )
    for src in files:
        if os.path.isfile( src ):
            shutil.copy2( src, target_dir )

template_dir = "tools/project_templates/" + args.template

project_src_dir = project_dir
project_include_dir = project_dir

if args.folders:
  project_include_dir = os.path.join( project_dir, "include" )
  project_src_dir = os.path.join( project_dir, "src" )
  os.makedirs( project_include_dir )
  os.makedirs( project_src_dir )
  
copy_files( template_dir, project_dir, '*.cmake')
copy_files( template_dir, project_include_dir, '*.h')
copy_files( template_dir, project_src_dir, '*.cpp')

# optional cmake config file
if args.cmake and not os.path.isfile( os.path.join( template_dir, "project.cmake" ) ) :
  shutil.copy2( "tools/project_templates/project.cmake", project_dir )
  
# optional pch
if args.pch :
  shutil.copy2( "tools/project_templates/pch.h", project_dir )
  shutil.copy2( "tools/project_templates/pch.cpp", project_dir )

# rename main file
project_source_path = os.path.join( project_src_dir, project_name + ".cpp" );
os.rename( os.path.join( project_src_dir, "template.cpp" ), project_source_path )

# and replace content
with open( project_source_path, 'r' ) as file :
  project_file = file.read()

# Replace the target string
project_file = project_file.replace( 'TEMPLATE', project_name )

# Write the file out again
with open( project_source_path, 'w' ) as file:
  file.write( project_file )

print( "New %s project created at %s" % ( args.template, project_dir ) )
  
if args.configureplusplus :
  os.system( 'configure.bat live++' )
if args.configure :
  os.system( 'configure.bat' )