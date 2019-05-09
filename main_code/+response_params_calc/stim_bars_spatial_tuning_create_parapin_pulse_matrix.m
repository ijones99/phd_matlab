
load settings/stimParams_Moving_Bars_v4_for_size_tuning.mat
transMatrix = double(Settings.MID_GRAY_VAL)*double(ones(Settings.SURR_DIMS, ...
    Settings.SURR_DIMS  ));
stimFrameInfo={};
stepCounter = 0;
for iRep = 1:Settings.STIM_REPETITIONS
    for iOffset = 1:length(Settings.OFFSET_UM)
        offsetPx = Settings.OFFSET_UM(iOffset)/Settings.UM_TO_PIX_CONV;
        
        for iBrightness = 1:length(Settings.RGB)
            rgbBrightness = Settings.RGB(iBrightness);
            
            for iBarLength = 1:length(Settings.BAR_LENGTH)
                barLengthPx = Settings.BAR_LENGTH(iBarLength)/Settings.UM_TO_PIX_CONV;
                
                for iBarWidth = 1:length(Settings.BAR_WIDTH)
                    barWidthPx = Settings.BAR_WIDTH(iBarWidth)/Settings.UM_TO_PIX_CONV;
                    
                    for iVel = 1:length(Settings.SPEED)
                        movingBarSpeedPx = Settings.SPEED(iVel)/Settings.UM_TO_PIX_CONV;
                        
                        for iAngle = 1:length(Settings.DIRECTIONS)
                            currDirection = Settings.DIRECTIONS(iAngle);
                            
                            if math.isfactorof(currDirection,90)
                                inputAngle = currDirection;
                            else
                                inputAngle = currDirection+90;
                            end
                            stepCounter = stepCounter+1;
                            stimFrameInfo.rep(stepCounter) = iRep;
                            stimFrameInfo.offset(stepCounter) = Settings.OFFSET_UM(iOffset);
                            stimFrameInfo.rgb(stepCounter) = Settings.RGB(iBrightness);
                            stimFrameInfo.length(stepCounter) = Settings.BAR_LENGTH(iBarLength);
                            stimFrameInfo.width(stepCounter) = Settings.BAR_WIDTH(iBarWidth);
                            stimFrameInfo.vel(stepCounter) = Settings.SPEED(iVel);
                            stimFrameInfo.angle(stepCounter) = currDirection;
                            
                        end
                    end
                end
            end
        end
    end
end
%
save('settings/stimFrameInfo_v4_for_size_tuning.mat', 'stimFrameInfo')
