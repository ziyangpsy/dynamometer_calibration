function [Res, Par] = Calibrate_dynamometers(Res, Par)

% This function runs the full calibration sequence for the dynamometer

% Written by Yang yzypsy2001@gmail.com
% Special thanks to Will Turner for his help

%% Zero the handle
DrawFormattedText(Par.scrID, Par.Disp.relaxText{1}, 'center', Par.y0-50, Par.textColor);
DrawFormattedText(Par.scrID, Par.Disp.relaxText{2}, 'center', Par.y0+50, Par.textColor);% Draw zeroing text
Screen('Flip', Par.scrID); % Flip the text

dynoBuffer(1:Par.Dyno.numValuesToRead) = double(0); % Initialize buffer big enough for one sample
nRead = 0;
nTotalRead = 0;
nSamples = round((Par.Dyno.zeroTimeToWait * 1000) / Par.Dyno.numValuesToRead); % Calculate number of samples possible given the zeroing time
nDataPoints = nSamples * Par.Dyno.numValuesToRead; % Calculate total number of data there will be, given the number of samples
recordBuffer = nan(nDataPoints, 1); % Create buffer of nan big enough to store all data samples
calllib(Par.mpLib, 'startMPAcqDaemon'); % Start acquisition thread
calllib(Par.mpLib, 'startAcquisition'); % Start acquiring data
tStartZero = GetSecs; % Record time zeroing started

while nTotalRead < nDataPoints % if there is remaining data to record
    [z, dynoBuffer, nRead] = calllib(Par.mpLib, 'receiveMPData', dynoBuffer, Par.Dyno.numValuesToRead, nRead); % Read MP160 data
    recordBuffer((nTotalRead + 1):(nTotalRead + nRead), :) = dynoBuffer(1:nRead)'; % Store data
    nTotalRead = nTotalRead + nRead; % Track total data read
end

tFinishZero = GetSecs; % Record time zeroing finished
Res.Dyno.zeroTime = tFinishZero - tStartZero; % Calculate time taken zeroing
Res.Dyno.zeroingData = recordBuffer; % Store zeroing data
Res.Dyno.baseline = nanmean(recordBuffer); % Calculate baseline (mean of zeroing data)
calllib(Par.mpLib, 'stopAcquisition'); % Stop acquisition

clear tFinishZero tStartZero % Clear variables

%% Calibration
calibBuffer = cell(3, 1); % Store the data from each calibration trial
maxContractBuffer = zeros(3, 1); % Where max force from each calibration trial is stored

for calibTrials = 1:3 % Three calibrations for a single handle
    
    clear dynoBuffer nRead nTotalRead nSamples nDataPoints % Clear dynamometer related variables
    
    % Present calibration instructions
    if calibTrials == 1
        
        DrawFormattedText(Par.scrID, Par.Disp.calibrationInstructions{1}, 'center', Par.y0-50, Par.textColor);
        DrawFormattedText(Par.scrID, Par.Disp.calibrationInstructions{2}, 'center', Par.y0, Par.textColor);
        DrawFormattedText(Par.scrID, Par.Disp.calibrationInstructions{3}, 'center', Par.y0+50, Par.textColor);
        
        Screen('Flip', Par.scrID);
        WaitSecs(5);
        
    elseif calibTrials == 2
        
        DrawFormattedText(Par.scrID, Par.Disp.calibrationInstructions2{1}, 'center', Par.y0-50, Par.textColor);
        DrawFormattedText(Par.scrID, Par.Disp.calibrationInstructions2{2}, 'center', Par.y0, Par.textColor);
        DrawFormattedText(Par.scrID, Par.Disp.calibrationInstructions2{3}, 'center', Par.y0+50, Par.textColor);
        Screen('Flip', Par.scrID);
        WaitSecs(5);
        
    elseif calibTrials == 3
        
        DrawFormattedText(Par.scrID, Par.Disp.calibrationInstructions3{1}, 'center', Par.y0-50, Par.textColor);
        DrawFormattedText(Par.scrID, Par.Disp.calibrationInstructions3{2}, 'center', Par.y0, Par.textColor);
        DrawFormattedText(Par.scrID, Par.Disp.calibrationInstructions3{3}, 'center', Par.y0+50, Par.textColor);
        Screen('Flip', Par.scrID);
        WaitSecs(5);
        
    end
    
    DrawFormattedText(Par.scrID, Par.Disp.perpareText, 'center', Par.y0, Par.textColor);
    Screen('Flip', Par.scrID);
    WaitSecs(1.5);
    
    % Set up/reset calibration variables
    dynoBuffer(1:Par.Dyno.numValuesToRead) = double(0); % Initialize buffer
    nRead = 0;
    nTotalRead = 0;
    nSamples = round((Par.Dyno.calibTimeToWait * 1000) / Par.Dyno.numValuesToRead); % Number of samples possible
    nDataPoints = nSamples * Par.Dyno.numValuesToRead; % Total data points
    recordBuffer = nan(nDataPoints, 1);
    
    calllib(Par.mpLib, 'startMPAcqDaemon'); % Start acquisition thread
    calllib(Par.mpLib, 'startAcquisition'); % Start acquiring data
    tStartCal = GetSecs; % Log when calibration starts
    
    while (GetSecs < tStartCal + Par.Dyno.calibTimeToWait)
        if nTotalRead < nDataPoints % if there is remaining data to record
            [z, dynoBuffer, nRead] = calllib(Par.mpLib, 'receiveMPData', dynoBuffer, Par.Dyno.numValuesToRead, nRead); % Read MP160 data
            recordBuffer((nTotalRead + 1):(nTotalRead + nRead), :) = dynoBuffer(1:nRead)'; % Store data
            nTotalRead = nTotalRead + nRead; % Track total data read
            
            if nTotalRead > Par.Dyno.numValuesToRead / 2
                meanForce = mean(recordBuffer((nTotalRead - Par.Dyno.numValuesToRead / 2):nTotalRead)); % Average force over last sample
                meanForceNorm = meanForce - Res.Dyno.baseline; % Normalize mean force
                % meanForceNorm = 0.5 for test
                % Draw the force bar in the center of the screen
                Screen('FrameRect', Par.scrID, Par.barFrameColor, [Par.x0-50, Par.y0-225, Par.x0+50, Par.y0+225], 4);  % Draw bar outline
                Screen('FillRect', Par.scrID, Par.barColor, [Par.x0-50, Par.y0+200-max(0, meanForceNorm)*Par.Dyno.scaleFactor, Par.x0+50, Par.y0+225]); % Draw actual response bar
                DrawFormattedText(Par.scrID, '尽全力挤压握力器!', 'center', Par.y0+260, Par.textColor); % Prompt user to squeeze handle
                Screen('Flip', Par.scrID); % Update screen
            end
        end
    end
    
    tFinishCal = GetSecs; % Log time calibration trial finished
    Res.Dyno.calibTime(calibTrials, 1) = tFinishCal - tStartCal; % Calculate calibration trial duration
    calibBuffer{calibTrials} = recordBuffer; % Store calibration trial data
    maxContractBuffer(calibTrials) = max(recordBuffer); % Record max force for each trial
    calllib(Par.mpLib, 'stopAcquisition'); % Stop acquisition
    
end

Res.Dyno.calibData = calibBuffer; % Store calibration data
maxVolContract = max(maxContractBuffer) - Res.Dyno.baseline; % Calculate maximal voluntary contraction
Res.Dyno.maxVolContract = maxVolContract; % Store max voluntary contraction

end
