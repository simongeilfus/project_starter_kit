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

cmake_minimum_required (VERSION 3.6)

# third party libraries cmake project
project(third_party)
# copy the parent list of libraries so this scope can append to it
set(THIRD_PARTY_LIBRARIES ${THIRD_PARTY_LIBRARIES})

# configure existing third party libraries
include(../tools/third_party.cmake)

# Custom third party libraries
#-----------------------------------------------------------------------------
#
# when adding other libraries to this file the THIRD_PARTY_LIBRARIES
# can be appended to to facilitate linking to sub projects
#
#       list(APPEND THIRD_PARTY_LIBRARIES NAME_OF_THE_LIBRARY)
#
# if the library contains sources it might be cleaner to move them in
# the same folder as the other third party libraries by doing the following
#
#       set_property(TARGET NAME_OF_THE_LIBRARY PROPERTY FOLDER "third_party")
#
# see tools/third_party.cmake for more details
#-----------------------------------------------------------------------------

# update the parent list of third party libraries
set(THIRD_PARTY_LIBRARIES ${THIRD_PARTY_LIBRARIES} PARENT_SCOPE )