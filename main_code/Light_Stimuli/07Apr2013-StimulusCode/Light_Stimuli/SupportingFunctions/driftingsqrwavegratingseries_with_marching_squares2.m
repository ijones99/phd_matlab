function driftingsqrwavegratingseries_with_marching_squares2
%%
% This program produces grating stimuli in multiple (8) directions at varying spatial speeds and spatial
% frequencies. When run, the program will turn gray (without red LED), then beep twice. When
% the space bar is pressed, it will exit out of the current for loop. At the end, the screen will remain gray until
% the space bar is pressed. The program will not respond to other keyboard
% inputs.
%% Runtime  

umToPixConv = 1.79;

% Set Psychotoolbox Settings
% Global vars
global screenid
global win

% -------------------  Experimental Sequence Variables -------------------
% Notes on data recording

% Each file contains all directions and repetitions for a given speed &
% spat frequency.

% Parapin changes for every repeat: 8 x 3 = 24 times for each file

save_recording = 1;
%repeats
iSpeed = [100 300 600];
% iSpeed = [100];
iSpatFreq = [1/300];
% iSpatFreq = [1/300];
iDirections = [0:3 ];
gratingSize = 360 ;
secondsToRun = 2  ;%seconds
repeatsInSameDirection = 1;
waitTimeBetweenPresentations = 1; %seconds
waitTimeBetweenRuns = 0.5;
black = 0;
white = 255;
darkGrayVal = 115;
grayVal = 163;
lightGrayVal = 205;
angleIncrement = 90;
runTime = length(iSpeed) * length(iSpatFreq) * length(iDirections) * ((repeatsInSameDirection+waitTimeBetweenPresentations )  * secondsToRun + waitTimeBetweenRuns)/60;
fprintf('Runtime of %2.2f minutes.\n', runTime);
fileRunTime = length(iDirections) * ((repeatsInSameDirection + waitTimeBetweenPresentations)* secondsToRun + waitTimeBetweenRuns)/60;
fprintf('Runtime of %2.2f minutes for each file.\n', fileRunTime);

%%
parapin(0)

% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL;

% Choose screen with maximum id - the secondary display on a dual-display
screenid = max(Screen('Screens'));

win = Screen('OpenWindow', screenid, [0 grayVal grayVal 0]);
beep
pause(.3)
beep
pause(.3)
HideCursor
KbWait;



for spatialGratingMovementSpeedUmPerSec = iSpeed

    for spatFreq = iSpatFreq
        %run a series of gratings
        spatialGratingMovementSpeedPixPerSec = spatialGratingMovementSpeedUmPerSec/umToPixConv;
        cyclesPerSecond = spatialGratingMovementSpeedPixPerSec*spatFreq;

        internalRotation = 90 ;
        beepOn = 0  ;

        presentationLength = round(secondsToRun*60);
%         presentationLength = (1/spatFreq)/spatialGratingMovementSpeedPixPerSec*1.5*60
        phase = 90;

        m=zeros(gratingSize,gratingSize, 3);
        m(:,:,2)=ones(gratingSize);
        m(:,:,3)=m(:,:,2);
        w = Screen(win, 'MakeTexture', grayVal*m);
        parapin(0)
        if save_recording
            hidens_startSaving(0,'bs-hpws03')
            pause(.2)
        end
        for i=iDirections % 0 to 7 for 8 directions


            for j=1:repeatsInSameDirection
                angle =  i*angleIncrement;
                % start recording data
                
                
                parapin(6)
%                 driftingsingrating2(angle, cyclesPerSecond, spatFreq, gratingSize, internalRotation, beepOn, presentationLength, phase)
                test_drift_pattern_basic(angle,cyclesPerSecond, spatFreq, 0, gratingSize)
                parapin(4)
                Screen('DrawTexture', win, w);
                Screen(win,'Flip');
                
                pause(waitTimeBetweenPresentations)

                %                 settingsInfo = struct('Angle',angle, 'CyclesPerSecond', cyclesPerSecond, 'spatFreq' , spatFreq, 'GratingSize', gratingSize, 'InternalRotation', internalRotation, 'SecondsToRun',  secondsToRun, 'PresentationLength', presentationLength, 'Phase', phase, 'TimeStamp', datestr(now))
                %                 settingsFileName = regexprep(settingsInfo.TimeStamp, ':','-'); settingsFileName = strcat(regexprep(settingsFileName, ' ','-'),'.mat');
                %                 save(fullfile(settingsSaveToDir,settingsFileName), 'settingsInfo');
%                 eval('!chmod g+rwx *.mat')
%                 eval('!chmod g+rwx *.m')

                % stop recording data

            end
            pause(waitTimeBetweenRuns)

        end
        pause(waitTimeBetweenRuns);
        marching_bar_new([100 ],1,0)
        
        
        
        parapin(0)
        if save_recording
            pause(.2)
            hidens_stopSaving(0,'bs-hpws03')
        end
        parapin(0)
    end
end % end the speed variations


pause(.3)
beep
pause(.3)
KbWait
Screen('CloseAll');

end
