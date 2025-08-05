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
Par.mpLib = 'mpdev'; 
[notfound, warnings] = loadlibrary('C:\Program Files (x86)\BIOPAC Systems, Inc\BIOPAC Hardware API 2.2 Research\x64\mpdev.dll', 'C:\Program Files (x86)\BIOPAC Systems, Inc\BIOPAC Hardware API 2.2 Research\mpdev.h'); %;% mpdev.dll/mpdev.h
% API from biopac
calllib(Par.mpLib,'connectMPDev', 103, 11, 'auto');
calllib(Par.mpLib, 'setSampleRate', 1.0); % SampleRat
calllib(Par.mpLib, 'setAcqChannels', int32([1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0])); %AcqChannels
