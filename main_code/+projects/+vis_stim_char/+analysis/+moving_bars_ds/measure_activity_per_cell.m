function paramOut = measure_activity_per_cell(dataOut, dataOutRF)
% paramOut = COMPUTE_PARAMS(selClus, dataOut, dataOutRF)
% dataOutRF is from marching square over grid.
script_load_data

dirNameProf = '../analysed_data/profiles/';

% load stim params
stimFrameInfo = file.load_single_var('settings/',...
    'stimFrameInfo_Moving_Bars_ON_OFF.mat');

offsetsUnique = unique(stimFrameInfo.offset );
rgbsUnique = unique(stimFrameInfo.rgb);
lengthsUnique = unique(stimFrameInfo.length);
widthsUnique = unique(stimFrameInfo.width);
speedsUnique = unique(stimFrameInfo.speed);
anglesUnique = unique(stimFrameInfo.angle);

onOffBias = [];
paramOut = [];

anglesOnScreen = psychtoolbox.angle_transfer_function(anglesUnique); % angles as seen on screen
[Y, idxOnScrAngle] = sort(anglesOnScreen); % idxOnScrAngle is index for responses to angles

for i=1:length(dataOut.clus_num)
    % load data
    %     filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
    %     load(fullfile(dirNameProf, filenameProf))
    
    % select location of either on or off cells.
    if dataOutRF.total_spikes_ON(i) > dataOutRF.total_spikes_OFF(i)
        onOffBias(i) = 2;
        rfCtrLocRel = dataOutRF.ON.RF_ctr_xy(i,:);
    else
        onOffBias(i) = 1;
        rfCtrLocRel = dataOutRF.OFF.RF_ctr_xy(i,:);
    end
    
    % note that "true" angle is inputted, but is converted to the on-screen
    % "angle," as seen.
    closestOffset  = projects.vis_stim_char.ds.find_offset_positions_closest_to_point(...
        anglesUnique, offsetsUnique, rfCtrLocRel);
    
    for iOffset = 1:size(closestOffset,1)
        %         (iOffset, iRgb, iLength, iWidth, iSpeed, iAngle)
        % ON
        selRGB = 1;
        selSpeed = 1;
        responseSel_spk_count_slow_on(iOffset) = squeeze(dataOut.meanSpikeCnt{i}(...
            closestOffset(iOffset,3), selRGB, :, :, selSpeed,idxOnScrAngle(iOffset) ));
        selSpeed = 2;
        responseSel_spk_count_fast_on(iOffset) = squeeze(dataOut.meanSpikeCnt{i}(...
            closestOffset(iOffset,3), selRGB, :, :, selSpeed,idxOnScrAngle(iOffset) ));
        
        % OFF
        selRGB = 2;
        selSpeed = 1;
        responseSel_spk_count_slow_off(iOffset) = squeeze(dataOut.meanSpikeCnt{i}(...
            closestOffset(iOffset,3), selRGB, :, :, selSpeed,idxOnScrAngle(iOffset) ));
        selSpeed = 2;
        responseSel_spk_count_fast_off(iOffset) = squeeze(dataOut.meanSpikeCnt{i}(...
            closestOffset(iOffset,3), selRGB, :, :, selSpeed,idxOnScrAngle(iOffset) ));
 
    end
    
    
    [Y, I] = sort(responseSel_spk_count_slow_on,'descend'); 
    paramOut.mean_ds_spk_cnt_slow_on(i) = mean(Y(1:5));
    
    
    [Y, I] = sort(responseSel_spk_count_slow_off,'descend'); 
    paramOut.mean_ds_spk_cnt_slow_off(i) = mean(Y(1:5));
    
    
    [Y, I] = sort(responseSel_spk_count_fast_on,'descend'); 
    paramOut.mean_ds_spk_cnt_fast_on(i) = mean(Y(1:5));
    
    
    [Y, I] = sort(responseSel_spk_count_fast_off,'descend'); 
    paramOut.mean_ds_spk_cnt_fast_off(i) = mean(Y(1:5));

    
    %     plot_polar_for_ds(anglesUnique([1:end]),responseSel_fr_fast_on([1:end]),'line_style','r'), hold on
    %     plot_polar_for_ds(anglesUnique([1:end ]),responseSel_fr_fast_off([1:end]),'line_style','k'), hold off
    %     maxON = round(max(responseSel_fr_fast_on));
    %     maxOFF = round(max(responseSel_fr_fast_off));
    %     title([num2str(maxON) ,' ',num2str(maxOFF) ])
    %
    %     shg
    %     pause(1);
    
    %     plot_polar_for_ds(anglesUnique, responseSel), pause(0.5)
    progress_info(i,length(dataOut.clus_num));
end

paramOut.clus_num = dataOut.clus_num;
paramOut.date = dataOut.date;


dirName =  '../analysed_data/moving_bar_ds';
mkdir(dirName)
save(fullfile('../analysed_data/moving_bar_ds/param_DSIndex.mat'), 'paramOut');
fprintf('paramOut saved.\n')
