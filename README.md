# dynamometer_calibration

Dependencies:
PsychToolbox & gstreamer-1.0-x86_64-1.11.2 (if psychtoolbox fails
to download you may also need to install Slik-Subversion-1.9.5-x64)

A matlab compatible C compiler (if using R2015b or higher then MinGW64 is
recommended). To see if a matlab compiler is installed type: mex -setup
If an error occurs then you will need to install a compiler.

BHAPI (this api provides the mpdev.dll and mpdev.h files which you need
to call when loading the mpdev library). Make sure you link to these
files when calling the loadlibrary function. See below.

AcqKnowledge 5.0 + USB driver (these are provided with the MP160)

$$ Before this function :
see before the function.m
