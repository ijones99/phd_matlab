% script_for_natural_movies_stimulus analysis

% use indices found from script_for_spikesorting.m


flist = {};

selFile = 1
switch selFile
    case 1
        flist_mov2_orig_stat_surr_med;
        fileNameID = 'T11_10_23_6_orig_stat_surr_med_plus_others'; 
end
loadStimFrameTs = 0;

recDir = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/';
genDataDir = fullfile(recDir,'/25Apr2012/analysed_data/');

specDataDir = fullfile(genDataDir, fileNameID);



% get tsMatrix

% get selected neuron indices
% load(fullfile(genDataDir,fileNameID,'selNeuronInds.mat'));
load(fullfile(genDataDir,fileNameID,'neuronIndList.mat'));

% -->> load all timestamps from all neurons and put into a matrix
% input data directory
inputDir = fullfile(genDataDir, fileNameID ,'/03_Neuron_Selection/');

% file types to open
fileNamePattern = 'st*mat';

% obtain file names for all neurons
fileNames = dir(strcat(inputDir,fileNamePattern));

% timestamp matrix
tsMatrix = {};neurLabels = {};
% selNeuronInds = 1:2
for i=1:length(fileNames)
    fprintf('load %s\n', fileNames(i).name);
    % load file
    inputFileName = fileNames(i).name;
    load(fullfile(inputDir,inputFileName));
    
    % struct name for struct that is read into this function
    periodLoc = strfind(inputFileName,'.');
    tsMatrix{end+1}.el_ind = i;
    neurLabels{end+1} = strrep(inputFileName(1:periodLoc-1),'_','-');
    eval(['tsMatrix{end}.spikeTimes = ',inputFileName(1:periodLoc-1),'.ts;']);
end