
    load settings/stimParams_Moving_Bars_2Reps.mat
    transMatrix = double(Settings.MID_GRAY_VAL)*double(ones(Settings.SURR_DIMS, ...
        Settings.SURR_DIMS  ));
    stimFrameInfo={};
    stepCounter = 0;
    for iOffset = 1:length(Settings.OFFSET_UM)
        for iRep = 1:Settings.STIM_REPETITIONS
            configNum = 1%Settings.STIM_REPETITIONS(iRep);
            
            barLengthPx = Settings.BAR_LENGTH(configNum)/Settings.UM_TO_PIX_CONV;
            barWidthPx = Settings.BAR_WIDTH(configNum)/Settings.UM_TO_PIX_CONV;
            currDirections = Settings.DIRECTIONS(configNum,:);
            movingBarSpeedPx = Settings.SPEED(configNum)/Settings.UM_TO_PIX_CONV;
            rgbBrightness = Settings.RGB(configNum,:);
            for iBrightness = rgbBrightness
                for iLength = barLengthPx
                    for iVel = movingBarSpeedPx
                        for iAngle = currDirections
                            
                            offsetPx = Settings.OFFSET_UM(iOffset)/Settings.UM_TO_PIX_CONV;
                            if math.isfactorof(iAngle,90)
                                inputAngle = iAngle;
                            else
                                inputAngle = iAngle+90;
                            end
                            stepCounter = stepCounter+1;
                            stimFrameInfo.rep(stepCounter) = iRep;
                            stimFrameInfo.rgb(stepCounter) = iBrightness;
                            stimFrameInfo.length(stepCounter) = round(iLength*Settings.UM_TO_PIX_CONV);
                            stimFrameInfo.vel(stepCounter) = round(iVel*Settings.UM_TO_PIX_CONV);
                            stimFrameInfo.angle(stepCounter) = iAngle;
                            stimFrameInfo.offset(stepCounter) = Settings.OFFSET_UM(iOffset);
                        end
                    end
                end
            end
        end
    end
    %%
    save('settings/stimFrameInfo_movingBar_2Reps.mat', 'stimFrameInfo')
