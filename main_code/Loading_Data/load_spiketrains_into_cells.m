function [allSpikeTimes epoch] = load_spiketrains_into_cells(flistFileNameID, flist, dateValTxt, dirOutputFig, selNeuronInds, textLabel)

% script_for_natural_movies_stimulus analysis
doPrint = 1;
loadStimFrameTs=0;

recDir = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/';
genDataDir = fullfile(recDir, strcat('/', dateValTxt, '/analysed_data/'));


specDataDir = fullfile(genDataDir, flistFileNameID);
framenoFileName = strcat('frameno_', flistFileNameID, '.mat');
% load light timestamp framenos
load(fullfile(genDataDir,flistFileNameID,framenoFileName));

% shift timestamps for stimulus frames
frameno = shiftframets(frameno);

if ~loadStimFrameTs
    % get stop and start times
    interStimIntervalSec=.2;
    stimFramesTsStartStop = get_stim_start_stop_ts(frameno, interStimIntervalSec);
    % save
    save(fullfile(specDataDir,'stimFramesTsStartStop.mat'), 'stimFramesTsStartStop');
else
    load(fullfile(specDataDir,'stimFramesTsStartStop.mat'));
end

% -->> load all timestamps from all neurons and put into a matrix
% input data directory
inputDir = fullfile(genDataDir, flistFileNameID ,'/03_Neuron_Selection/');

% file types to open
fileNamePattern = 'st*mat';

% obtain file names for all neurons
fileNames = dir(strcat(inputDir,fileNamePattern));

% timestamp matrix
tsMatrix = {};
% selNeuronInds = 1:2
for i=1:length(fileNames)
    fprintf('load %s\n', fileNames(i).name);
    % load file
    inputFileName = fileNames(i).name;
    load(fullfile(inputDir,inputFileName));
    
    % struct name for struct that is read into this function
    periodLoc = strfind(inputFileName,'.');
    tsMatrix{end+1}.el_ind = i;
    eval(['tsMatrix{end}.spikeTimes = ',inputFileName(1:periodLoc-1),'.ts;']);
end
%% PLOT light timestamps data
ls(fullfile(specDataDir,'/01_Pre_Spikesorting/'))
% load(fullfile(specDataDir,'/01_Pre_Spikesorting/', 'el_5263.mat'));
x = 1:length(frameno);
% figure, plot(x(1:10:end), frameno(1:10:end)), hold on
% figure, plot(x(1:el_6984.last_read_ts), frameno(1:el_6984.last_read_ts)), hold on
% plot(stimFramesTsStartStop(1:11*3),frameno(stimFramesTsStartStop(1:11*3)), 'r*')
% plot(stimFramesTsStartStop,frameno(stimFramesTsStartStop), 'r*')
%i = 23; plot(stimFramesTsStartStop(i),frameno(stimFramesTsStartStop(i)),
%'c*')
%% raster plot settings
% flist = {};
% % flist_for_analysis_3;
% flist_for_birds_mov_orig_stat_surr_med
flistNo = 1;
flistName = flist{1};
flistflistFileNameID = flistName(end-21:end-11);

DATA_DIR = '../analysed_data/';
FILE_DIR = strcat(DATA_DIR, flistflistFileNameID,'/');

% constants
% e.g. there are 5 repeats per stimulus type or 'stimulus cluster'
numStartStopTsPerStimulusCluster = 35;
% vars
rowSpacing = 1; % spacing between the plotted rows
rangeLim = 0.42;
acqRate = 20000; % samples per second

% get the stimulus start stop timestamps
stimFramesTsStartStop = get_stim_start_stop_ts(frameno, 0.2);


%% plot raster

% DEFINITIONS
% stimulus group: a group of repetitions of the same stimulus
% repetition: one stimulus within a group
% index stimulus timestamp: index for the timestamp of the stimulus start
% or stop

% textprogressbar('Plotting rasters...')

epoch = {};
%     subplot(2,1,stimGroup)
for selNeurs =  selNeuronInds
%     figure, hold on
    for stimGroup = [1:length(textLabel)]
        %     stimGroup = 2; % each group of stimuli contains several repetitions
        
%         subplot(2,1,stimGroup)
        stimTypeName = textLabel{stimGroup};
        %             stimTypeName = ['Dyn Surr Median'];
        
        titleName = strcat(['Raster Plot - Neuron ', strrep(fileNames(selNeurs).name,'_','-'), ' Ind ', num2str(selNeurs),' ', stimTypeName]);
        titleName = strrep(titleName,'_','-');
        % titleName = 'Raster Plot - Natural Movie All Neurons';
        
        numRepsPerGroup = 35; % number of repetitions per stimulus group
        numRepsToDrop = 5;
        numStimGroups = 1; % number of such groups
        stimGroupAllReps = [0:numRepsPerGroup:numRepsPerGroup*(numStimGroups-1)]+stimGroup;
        % the group numbers for the stimulus of interest
        
        plotStartTimeZ = -2;
        plotEndTimeZ = 35;
        spikeMarkerHeight = 0.8;
        stimMarkerHeight = 1;
        
        iPlotCounter = 1;
        % cycle through the stimulus groups
        for iStimGroup = stimGroupAllReps
            for iStimRepeatNumber = numRepsToDrop+1:numRepsPerGroup
                
                % the first timestamp for a series cluster
                indStimTsStartFirst = (iStimGroup-1)*(numStartStopTsPerStimulusCluster*2+1)+1;
                indStimTsStart = repmat(indStimTsStartFirst,1,numRepsPerGroup)+[0:2:numRepsPerGroup*2-2];
                
                % there is an element for each neuron found
                for iNeuron = selNeurs%:length(tsMatrix)
                    % go through each repetition for the stimulus (along the x
                    % direction)
                    for iIndStimTsStart = indStimTsStart(iStimRepeatNumber)
                        stimStartTs = stimFramesTsStartStop(iIndStimTsStart)/acqRate;
                        stimEndTs = stimFramesTsStartStop(iIndStimTsStart+1)/acqRate;
                        
                        epoch{end+1} = extract_epoch_from_spiketrain(tsMatrix{iNeuron}.el_ind,tsMatrix{iNeuron}.spikeTimes, ...
                            stimStartTs,stimEndTs, plotStartTimeZ, plotEndTimeZ, spikeMarkerHeight,stimMarkerHeight, ...
                            iPlotCounter );
                        iPlotCounter = iPlotCounter+1;
                        
                    end
                end
            end
%             title(titleName,'Fontsize', 14)
%             %             title('Raster Plot - Natural Movie (neurInd 14)','Fontsize', 14)
%             xlabel('Time (sec)', 'Fontsize', 14)
            %     print(gcf,'-depsc', '-r150',strcat('Figs/T16_07_02_2_plus_others/RasterPlots/',titleName,'Rep',num2str(iStimRepeatNumber)) );
            
            
            
        end
        
        fileName = strcat(['Raster Plot - Neuron ', strrep(fileNames(selNeurs).name,'_','-'), ...
            ' Ind ', num2str(selNeurs),' ', textLabel{1},'_',textLabel{2} ]);
        fileName = strrep(fileName,'_','-');
    end
    if doPrint
        %             print(gcf,'-depsc', '-r150',  fullfile(dirNameSTA,strcat(titleName,'.ps')) );
        
        
        if ~isdir(dirOutputFig)
            fprintf('Directory does not exist\n');
            pause(.5);
        else
            exportfig(gcf, fullfile(dirOutputFig,strcat(fileName,'.ps')) ,'Resolution', 120,'Color', 'cmyk')
        end
        
    end
%     textprogressbar(100*find(selNeurs==selNeuronInds)/length(selNeuronInds));
    
    
end
% textprogressbar('end')
allSpikeTimes = tsMatrix{iNeuron}.spikeTimes;

end