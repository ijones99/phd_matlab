function dataOut = process_data(selClus)

script_load_data
idxStim = barsLengthTestRIdx;

dirNameProf = '../analysed_data/profiles/';

% load idx info
load idxFinalSel

% load stim params
stimFrameInfo = file.load_single_var('settings/',...
    'stimFrameInfo_Moving_Bars_Length_Test.mat');


offsetsUnique = unique(stimFrameInfo.offset );
rgbsUnique = unique(stimFrameInfo.rgb);
lengthsUnique = unique(stimFrameInfo.length);
widthsUnique = unique(stimFrameInfo.width);
speedsUnique = unique(stimFrameInfo.speed);
anglesUnique = unique(stimFrameInfo.angle);

% get stim onset timestamps
allStimChsIdx = 1:2:length(stimChangeTs{idxStim});

dataOut.meanSpikeCnt = {};
dataOut.stdSpikeCnt = {};
dataOut.meanFR = {};
dataOut.stdFR = {};
dataOut.rawMeanSpikeCnt = {};
meanBLFR = [];

onOffBias = [];

dirName =  '../analysed_data/length_test';
load(fullfile(dirName, 'dataOut.mat'));

for i=1:length(selClus)
    filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
    load(fullfile(dirNameProf, filenameProf))
    for iOffset = 1:length(offsetsUnique)
        for iRgb = 1:length(rgbsUnique)
            for iLength = 1:length(lengthsUnique)
                for iWidth = 1:length(widthsUnique)
                    for iSpeed = 1:length(speedsUnique)
                        for iAngle = 1:length(anglesUnique)
                            % get spiketimes
                            stCurr = neurM(idxStim).ts;
                            
                            [idxSel varIdx ] = params.vis_stim.get_param_indices(stimFrameInfo,'rgb',rgbsUnique(iRgb),...
                                'offset',offsetsUnique(iOffset), 'length',lengthsUnique(iLength), 'speed',speedsUnique(iSpeed),...
                                'angle',anglesUnique(iAngle));
                            
                            % create idx raster for data access
                            idxRaster = [allStimChsIdx(varIdx(idxSel))' allStimChsIdx(varIdx(idxSel))'+2];
                            
                            % create idx raster for baseline
                            baselineTime = 0.9;
                            [spikeTrain spikeTrainSeg spikeTrainBL spikeTrainBLSeg] = spiketrains.get_raster_series(stCurr/2e4, ...
                                stimChangeTs{idxStim}/2e4, idxRaster,'baseline_sec',baselineTime );
                            
                            
                            dataOut.rawMeanSpikeCnt{i}(iOffset, iRgb, iLength, iWidth, iSpeed, iAngle) = ...
                                max(cellfun(@length,spikeTrain));
                            %                 maxSpikeFR(end+1) = max(spikeFR);
                        end
                        
                    end
                end
            end
            
        end
    end
    
    progress_info(i,length(selClus));
end

% add cluster and date info
dataOut.clus_num = idxFinalSel.keep;
dataOut.date = get_dir_date;
mkdir(dirName)
save(fullfile(dirName, 'dataOut.mat'), 'dataOut');
fprintf('dataOut saved.\n')

