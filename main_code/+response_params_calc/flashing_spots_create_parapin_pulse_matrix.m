load settings/stimParams_Flashing_Spots
stimFrameInfo = {};
stepCounter=0;
stimFrameInfo = {};
for iRepeats = 1:Settings.DOT_STIM_REPEATS
    for iDotBrightness = Settings.DOT_BRIGHTNESS_VAL
        for i = 1:length(Settings.PRESENTATION_ORDER)
                stepCounter = stepCounter+1;
              
                stimFrameInfo.rep(stepCounter) = iRepeat;
                
                
                stimFrameInfo.rgb(stepCounter) = iDotBrightness;
                
                stimFrameInfo.dotDiam(stepCounter) = Settings.DOT_DIAMETERS(Settings.PRESENTATION_ORDER(i));
                
        end
    end
end


save('stimFrameInfo_spots', 'stimFrameInfo')



