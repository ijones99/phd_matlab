umToPixConv = 1.79;

% Set Psychotoolbox Settings
% Global vars
global screenid
global w
global win



if save_recording
    hidens_startSaving(0,'bs-hpws03')
    pause(.5)
end

for k = 1:numberRepeats

            parapin(6)
            Screen('DrawTexture', window, w(1), [], sourceRect{i}, [], [], [], [], [], [], []);
            Screen(window,'Flip');
            pause(flashInterval)
            parapin(4)
            Screen('DrawTexture', window, w(2), [], sourceRect{i}, [], [], [], [], [], [], []);
            Screen(window,'Flip');
            pause(flashInterval)
            if KbCheck
                break;
            end
        end
        end
        if ~save_recording
                for j=1:numFlashes
            
            Screen('DrawTexture', window, w(1), [], sourceRect{i}, [], [], [], [], [], [], []);
            Screen(window,'Flip');
            pause(flashInterval)
            
            Screen('DrawTexture', window, w(2), [], sourceRect{i}, [], [], [], [], [], [], []);
            Screen(window,'Flip');
            pause(flashInterval)
            if KbCheck
                break;
            end
        end    
            
        end
        
        if KbCheck
            break;
        end
    end
    if KbCheck
        break;
    end
    if save_recording
        parapin(0)
    end
    Screen('DrawTexture', window, w(3), [], sourceRect{i}, [], [], [], [], [], [], []);
    Screen(window,'Flip');


    pause(interRepeatInterval)
end


if save_recording
    pause(waitTimeBetweenPresentations)
    hidens_stopSaving(0,'bs-hpws03')
end