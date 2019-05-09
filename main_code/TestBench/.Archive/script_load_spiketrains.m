suffixName = '_orig_stat_surr';
flistName = 'flist_orig_stat_surr'
flist ={}; eval(flistName);
% elNumbers = [4631 4938 5444 5749 5851 6059 6361 6464]; % %get from white
% noise checkerboard
flistFileNameID = get_flist_file_id(flist{1}, suffixName);

flistFileNameID = get_flist_file_id(flist{1}, suffixName);
% dir names
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);

% frameno file name
framenoFileName = strcat('frameno_', flistFileNameID, '.mat');
% load light timestamp framenos
load(fullfile(dirNameFFile,framenoFileName));

% shift timestamps for stimulus frames
frameno = shiftframets(frameno);

% get timestamps
neurNames = '6172n169';
selNeuronInds = get_file_inds_from_neur_names(dirNameSt, '*.mat', neurNames);
tsMatrix  = get_tsmatrix(flistFileNameID, 'sel_by_ind', selNeuronInds)
tsMatrixOrig = tsMatrix;
%% load real data
precisionInfo{1}.spikeTrains = selSpikes{1};
precisionInfo{2}.spikeTrains = selSpikes{2};



%% parse data
clear precisionInfo
neuronIndNo = 1
clear X
% clear selSpikes
% clear stimDurSec
for iStimNum = 1:2
    [selSpikes{iStimNum} , stimDurSec{iStimNum}] = ...
        parse_stimulus_repeat_responses_natural_movie(frameno, tsMatrix , ...
        neuronIndNo, iStimNum);
end

spikeTrains = selSpikes{1};
spikeTrainBase = selSpikes{1}{1};