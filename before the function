$$ Before this function :
Par.mpLib = 'mpdev'; 
[notfound, warnings] = loadlibrary('C:\Program Files (x86)\BIOPAC Systems, Inc\BIOPAC Hardware API 2.2 Research\x64\mpdev.dll', 'C:\Program Files (x86)\BIOPAC Systems, Inc\BIOPAC Hardware API 2.2 Research\mpdev.h'); %;% mpdev.dll/mpdev.h
% API from biopac
calllib(Par.mpLib,'connectMPDev', 103, 11, 'auto');
calllib(Par.mpLib, 'setSampleRate', 1.0); % SampleRat
calllib(Par.mpLib, 'setAcqChannels', int32([1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0])); %AcqChannels
