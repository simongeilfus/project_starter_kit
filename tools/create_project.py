import os, sys, shutil, glob, argparse

# script arguments
parser = argparse.ArgumentParser()
parser.add_argument( 'template', choices=['cinder', 'glfw', 'cpp'], help='specifies the template to be used to generate the project' )
parser.add_argument( 'project_name', help='specifies the name of the project' )
parser.add_argument( '--pch', action='store_true', help='specifies whether the project needs to be generated with pch files' )
parser.add_argument( '--cmake', action='store_true', help='specifies whether the project needs a custom cmake config file' )
parser.add_argument( '--folders', action='store_true', help='specifies whether the project wants sources to be created inside subfolders instead of at the project root' )
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
if args.pch :
  template_dir += "_pch"

project_src_dir = project_dir
project_include_dir = project_dir

if args.folders:
  project_include_dir = os.path.join( project_dir, "include" )
  project_src_dir = os.path.join( project_dir, "src" )
  os.makedirs( project_include_dir )
  os.makedirs( project_src_dir )
  
copy_files( template_dir, project_include_dir, '*.h')
copy_files( template_dir, project_src_dir, '*.cpp')

# add necessary cmake config 
if args.template == 'cpp':
  shutil.copy2( "tools/project_templates/project.cmake", project_dir )
  with open( os.path.join( project_dir, "project.cmake" ), "a") as cmakeFile:
    cmakeFile.write( 
      'if(MSVC)\n'
      '\tset_target_properties( ${PROJECT_NAME} PROPERTIES LINK_FLAGS "/SUBSYSTEM:console /ENTRY:mainCRTStartup" )\n'
      'endif()'
      )
elif args.template == 'glfw':
  shutil.copy2( "tools/project_templates/project.cmake", project_dir )
  with open( os.path.join( project_dir, "project.cmake" ), "a") as cmakeFile:
    cmakeFile.write( 
      'if(MSVC)\n'
      '\tset_target_properties( ${PROJECT_NAME} PROPERTIES LINK_FLAGS "/SUBSYSTEM:windows /ENTRY:mainCRTStartup" )\n'
      'endif()'
      )
# or an optional cmake config file
elif args.cmake:
  shutil.copy2( "tools/project_templates/project.cmake", project_dir )

# rename main file
project_source_path = os.path.join( project_src_dir, project_name + ".cpp" );
os.rename( os.path.join( project_src_dir, "TemplateApp.cpp" ), project_source_path )

# and replace content
with open( project_source_path, 'r' ) as file :
  project_file = file.read()

# Replace the target string
project_file = project_file.replace( 'TemplateApp', project_name )

# Write the file out again
with open( project_source_path, 'w' ) as file:
  file.write( project_file )

print( "New %s project created at %s" % ( args.template, project_dir ) )