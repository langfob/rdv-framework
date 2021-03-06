#===============================================================================

#                               GuppyConstants.py

#  History:

#  2013.07.31 - BTL
#  Created by extracting various constants from Guppy.py.

#===============================================================================

import os

#-------------------------------------------------------------------------------

    #  This is the code I used in R, but it looks like python
    #  has a simple way to do this using os.sep.
    #  Because I've used dirSlash all over the place in the existing
    #  code, I'll just set dirSlash to os.sep and not change all of the
    #  code for now.
#unixDirSlash = "/"
#windowsDirSlash = "\\"

    #  May need to make this an IF statement based on determining which
    #  operating system is being used.
#dirSlash = unixDirSlash

dirSlash = os.sep

#-------------------------------------------------------------------------------

            #  Names provided by python for the different operating systems
            #  vary based on the call you use to get the name.
            #  in particular, os.name gives a coarser version that
            #  sys.platform or os.uname().  For example, all unix versions
            #  are called "posix" using os.name, but the others break unix
            #  up into finer categories.  I'll use the values from sys.platform
            #  here.
windowsOSnameInR = "mingw32"
windowsOSnameInPython = "win32"
windowsOSname = windowsOSnameInPython

macOSname = "darwin"

#===============================================================================

