function [dirName frameno stimFramesTsStartStop stimFrameTimes tsMatrix fileNames ] = load_ts_data(flist, selNeuronInds, suffixName, interStimIntervalSec)

if isempty(interStimIntervalSec)
   interStimIntervalSec = 0.2; 
end

% script_for_natural_movies_stimulus analysis
doPrint = 1;

flistFileNameID = get_flist_file_id(flist{1}, suffixName);

dirName = struct('FFile', [],'St', [],'El', [],'Cl', []) ;
dirName.FFile = strcat('../analysed_data/',   flistFileNameID);
dirName.St = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirName.El = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirName.Cl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');

framenoFileName = strcat('frameno_', flistFileNameID, '.mat');

% load light timestamp framenos
load(fullfile(dirName.FFile,framenoFileName));

% shift timestamps for stimulus frames
frameno = shiftframets(frameno);

if exist(fullfile(dirName.FFile,'stimFramesTsStartStop.mat'),'file')
    % get stop and start times
    
    stimFramesTsStartStop = get_stim_start_stop_ts2(frameno, interStimIntervalSec);
    % save
    save(fullfile(dirName.FFile,'stimFramesTsStartStop.mat'), 'stimFramesTsStartStop');
else
    load(fullfile(dirName.FFile,'stimFramesTsStartStop.mat'));
end

% -->> load all timestamps from all neurons and put into a matrix

% file types to open
fileNamePattern = 'st*mat';

% obtain file names for all neurons
fileNames = dir(strcat(dirName.St,fileNamePattern));

% timestamp matrix
tsMatrix = {};

textprogressbar('init...'),textprogressbar(100),textprogressbar('end')
textprogressbar('loading files...')
for i=1:length(fileNames)
%     fprintf('load %s\n', fileNames(i).name);
    % load file
    inputFileName = fileNames(i).name;
    load(fullfile(dirName.St,inputFileName));
    
    % struct name for struct that is read into this function
    periodLoc = strfind(inputFileName,'.');
    tsMatrix{end+1}.el_ind = i;
    eval(['tsMatrix{end}.spikeTimes = ',inputFileName(1:periodLoc-1),'.ts;']);
    textprogressbar(100*i/length(fileNames))
end
textprogressbar('end')

%% PLOT light timestamps data
ls(dirName.El)
x = 1:length(frameno);
figure, plot(x(1:10:end), frameno(1:10:end)), hold on
plot(stimFramesTsStartStop,frameno(stimFramesTsStartStop), 'r*')
%%
stimFrameTimes = struct('Start', stimFramesTsStartStop(1:2:end), ...
    'End', stimFramesTsStartStop(2:2:end));

end