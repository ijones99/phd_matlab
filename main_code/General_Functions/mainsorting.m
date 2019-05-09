open function mainsorting(varargin)
activatetoolboxes


%% ----------------- initializing ----------------- %

% ----------------- load data ----------------- %
load electrode_list
loadingError=[];
% dirNames{1} = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/23Nov2010_DSGCs/analysed_data/rec18_56_103';
% dirNames{2} = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/11Jan2011_DSGCs/analysed_data/rec48_16_2';
% dirNames{1} = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/07Feb2011_ij/analysed_data/rec27_252/';
% dirNames{4} = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/07Feb2011_ij/analysed_data/rec27_257/';
% dirNames{5} = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/07Feb2011_ij/analysed_data/rec27_245/';
dirNames{1} = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/4Aug2010_DSGCs_ij/';

% ----------------- load events ----------------- %
% go to each dir.
% aquire electrode_list
% save electrode_list
% load flist
% load ntk2 files and save
% do auto clustering and save
% go to next folder

%% ----------------- load events ----------------- %
for j = 1:length(dirNames)
    % j loops for each ntk2 file
    eval(strcat(['cd ',dirNames{j}]));
    tic
    fprintf('----------------- NEW DIRECTORY: %s -----------------\n', dirNames{j});
    % load list of electrodes
    load electrode_list
    % get existing files
    existingFiles = dir('ntkLoadedDataElectrode*.mat');
    % create vector of all files that have been saved to file (ID by electrode
    % number)
    for i = 1:size(existingFiles,1)
        existingFileNumber(i) =str2num(existingFiles(i).name(end-7:end-4));
    end
    % find positions in electrode list for which the corresponding files exist
    [ElectrodesToDelete, positionInElectrodeList, positionInFilesList] = intersect(electrode_list(:,1),existingFileNumber);
    %delete existing files from list
    electrode_list(positionInElectrodeList,:)=[];
    for i = 19:19%1:length(electrode_list)
        
        try
            %       loadntk2eventsonly(electrode_list(i));
            minutesToLoad = 20;
            
            loadntk2eventsonly('enable_save_data','minutes_to_load', minutesToLoad,'total_channels_to_load',5, 'flist_name','flist_for_analysis','electrode',electrode_list(i,1));
        catch
            loadingError = [loadingError electrode_list(i)]
        end
        
    end
    if ~isempty(loadingError)
        save loadingError loadingError
    end
    
    %% ----------------- cluster events ----------------- %
    clear existingFiles existingFileNumber ElectrodesToDelete positionInElectrodeList positionInFilesList
    
    % load list of electrodes
    load electrode_list
    % get existing files
    existingFiles = dir('clusteredEventsDataElectrode*.mat');
    % create vector of all files that have been saved to file (ID by electrode
    % number)
    existingFileNumber = []
    for i = 1:size(existingFiles,1)
        existingFileNumber(i) =str2num(existingFiles(i).name(end-7:end-4));
    end
    % find positions in electrode list for which the corresponding files exist
    [ElectrodesToDelete, positionInElectrodeList, positionInFilesList] = intersect(electrode_list(:,1),existingFileNumber);
    %delete existing files from list
    electrode_list(positionInElectrodeList,:)=[];
    
    
    loadingError2=[];
    
    for i = 19:19%1:length(electrode_list)
        if isempty(dir('clusteredEventsDataElectrode*.mat'))
            break;
        end
        try
            clusterdata('enable_save_data','electrode', electrode_list(i,1));
        catch
            loadingError2 = [loadingError2 electrode_list(i)]
        end
        close all
        
    end
    
    if ~isempty(loadingError2)
        save loadingError2 loadingError2
    end
    close all
    toc
    disp('!!!!!')
end

%% ----------------- analyze and merge data ----------------- %
% clear existingFiles existingFileNumber ElectrodesToDelete positionInElectrodeList positionInFilesList
% 
% % load list of electrodes
% load electrode_list
% % get existing files
% existingFiles = dir('MergedClustersElectrode*.mat');
% % create vector of all files that have been saved to file (ID by electrode
% % number)
% for i = 1:size(existingFiles,1)
%     existingFileNumber(i) =str2num(existingFiles(i).name(end-7:end-4));
% end
% % find positions in electrode list for which the corresponding files exist
% [ElectrodesToDelete, positionInElectrodeList, positionInFilesList] = intersect(electrode_list(:,1),existingFileNumber);
% %delete existing files from list
% electrode_list(positionInElectrodeList,:)=[];
% 
% 
% 
% for i=1:length(electrode_list)
%     analyzeandmergeclusters('enable_save_data','electrode',electrode_list(i,1));
%     close all
% end

%%


% exit
end

% exit
