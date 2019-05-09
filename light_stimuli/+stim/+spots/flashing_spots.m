function flashing_spots(window,Settings)
HideCursor
n=1;
try
for iRepeats = 1:Settings.DOT_STIM_REPEATS
    for iDotBrightness = Settings.DOT_BRIGHTNESS_VAL
        for i = 1:length(Settings.PRESENTATION_ORDER)

            clear tempFrame
            tempFrame = uint8(Settings.varDotStimMtx(:,:,Settings.PRESENTATION_ORDER(i)));
            tempFrame = (tempFrame*Settings.MID_GRAY_VAL);
            tempFrame(1,1)
            middleInd = find(tempFrame==0);
            tempFrame(middleInd) = iDotBrightness;
            w = Screen(window, 'MakeTexture',  Settings.BLACK_VAL+tempFrame);
            Screen(window, 'DrawTexture', w    );
            parapin(6);
            Screen(window,'Flip');
            parapin(4);
            pause(Settings.DOT_DOT_SHOW_TIME)
            transScrMtx = ones(Settings.SURR_DIMS);%set # pixels along edge or...
            transitionScreen = Screen(window, ...
                'MakeTexture',  Settings.BLACK_VAL+Settings.MID_GRAY_VAL...
                *uint8(transScrMtx ));
            % blank screen in between dot presentations
            Screen(window, 'DrawTexture', transitionScreen    );
            parapin(6);
            Screen(window,'Flip');
            parapin(4);

            if(KbCheck)
                break;
            end;
            %pause for amount specified minus the intrinsic rate
            pause(Settings.DOT_INTER_SUB_SESSION_WAIT);
            Screen('Close',w);
            n = 1+n;
        end
    end
end
catch 
    
end
transitionScreen = Screen(window, ...
    'MakeTexture',  Settings.BLACK_VAL+double(double(Settings.MID_GRAY_DECI)...
    *transScrMtx*double(Settings.WHITE_VAL )));

Screen(window, 'DrawTexture', transitionScreen    );
Screen(window,'Flip');
pause(0.5)


end





