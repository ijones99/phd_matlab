save_recording = 1;
settingsSaveToDir = '/var/tmp/'
fprintf('Settings will be saved to the following directory: %s \n', settingsSaveToDir );
settingsSaveToDir = input('Enter new directory or [y] to accept>> ','s')
if isempty(settingsSaveToDir) || settingsSaveToDir == 'y'
    settingsSaveToDir = '/var/tmp/'
end
x = input('Press key')

% Set Psychotoolbox Settings

% Global vars
global screenid
global win

Black = 0;
White = 255;
DarkGrayVal = 115/White; 
GrayVal = 163/White;
LightGrayVal = 205/White;

%sin wave vacillates between 115 and 205
GrayValSinBase = 160/White ;
SinWaveAmp = 95/White % +/- this value


%run a series of gratings
%Variables
Angle =  30;
CyclesPerSecond =  1;
Freq = 1/100 ;
GratingSize = 250 ;
InternalRotation = 0 ;
BeepOn = 0  ;
SecondsToRun = 30;%seconds
PresentationLength = 60*2;%round(SecondsToRun/Freq);
Phase = 90;
RepeatsInSameDirection = 1;


for i=0
    for j=1:RepeatsInSameDirection
      
        % start recording data
        if save_recording
            hidens_startSaving(4,'bs-hpws11')
            pause(1)
        end

        driftingsingrating(Angle, CyclesPerSecond, Freq, GratingSize, InternalRotation, PresentationLength, Phase)
        settingsInfo = struct('Angle',Angle, 'CyclesPerSecond', CyclesPerSecond, 'Freq' , Freq, 'GratingSize', GratingSize, 'InternalRotation', InternalRotation, 'SecondsToRun',  SecondsToRun, 'PresentationLength', PresentationLength, 'Phase', Phase, 'TimeStamp', datestr(now))
        settingsFileName = regexprep(settingsInfo.TimeStamp, ':','-'); settingsFileName = strcat(regexprep(settingsFileName, ' ','-'),'.mat');
        save(fullfile(settingsSaveToDir,settingsFileName), 'settingsInfo');
        eval('!chmod g+rwx *.mat')
        eval('!chmod g+rwx *.m')

        % stop recording data
        if save_recording
            pause(1)
            hidens_stopSaving(4,'bs-hpws11')
        end
    end
end



Screen('CloseAll');
