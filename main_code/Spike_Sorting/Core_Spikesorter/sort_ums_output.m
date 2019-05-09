function sort_ums_output(flistName, varargin)
% sort_ums_output(flistName, varargin)
% phase 2 of spikesorting process: this function opens each file produced
% by the UMS batch process and allows manual merging and separating of
% found clusters. Each file has data from 6 electrodes.
%
% flistName: name of flist file
% neuronsIndSel: indices to select
% initial_batch: use if this is for the initial sorting

% determine if there are multiple files
% if length(flistName) > 1
%     % ID number for files
%     flistFileNameID = strcat(flistName{1}(end-21:end-11),'_plus_others_2Movies');
% else
%     % ID number for files
%     flistFileNameID = flistName{1}(end-21:end-11);
% end
selPatchNumber = [];
if isstr(flistName)
    flistNameNew = {};
    flistNameNew{1} = flistName;
    clear flistName;
    flistName = flistNameNew{1};
end

idNameStartLocation = strfind(flistName{1},'T');idNameStartLocation(1)=[];
idNameEndLocation = strfind(flistName{1},'.stream.ntk')-1;
flistFileNameID = flistName{1}(idNameStartLocation:idNameEndLocation);
selElsInDir = [];
filesSelInDir = [];
neuronsIndSel = 0;
i=1;
displayMode = 2;

while i<=length(varargin)
    if not(isempty(varargin{i}))
        if strcmp(varargin{i}, 'sel_in_list')
            loadingMode = varargin{i};
            neuronsIndSel=varargin{i+1};
        elseif strcmp(varargin{i}, 'all_in_dir')
            loadingMode = varargin{i};
        elseif strcmp(varargin{i}, 'sel_in_dir')
            loadingMode = varargin{i};
            filesSelInDir = varargin{i+1};
        elseif strcmp(varargin{i}, 'sel_els_in_dir')
            loadingMode = varargin{i};
            selElsInDir = varargin{i+1};
        elseif strcmp(varargin{i},'add_dir_suffix')
            flistFileNameID = strcat(flistName{1}(idNameStartLocation:idNameEndLocation),varargin{i+1});
        elseif strcmp(varargin{i},'specify_output_dir')
            flistFileNameID = varargin{i+1};
        elseif strcmp(varargin{i},'display_mode_bands')
            displayMode = 2;
        else
            fprintf('unknown argument at pos %d\n', 2+i);
        end
    end
    i=i+1;
end


% outputted data:
global spikes_saved


% ---------- Dirs ----------
% main directory for this file
FILE_DIR = strcat('../analysed_data/', flistFileNameID,'/');

%create directory
if ~exist(FILE_DIR,'dir')
    mkdir(FILE_DIR);
end

% dir in which to put output files
OUTPUT_DIR = strcat(FILE_DIR, '02_Post_Spikesorting/');
%create directory
if ~exist(OUTPUT_DIR,'dir')
    mkdir(OUTPUT_DIR);
end
% --------------------------
currDir = pwd;

% input data directory
inputDir = strcat(currDir(1:end-6), ...
    'analysed_data/', flistFileNameID ,'/01_Pre_Spikesorting/')

% output data directory
outputDir = strcat(currDir(1:end-6), ...
    'analysed_data/', flistFileNameID,'/02_Post_Spikesorting/')

aaa = input('Dir locations are okay?');

% file types to open
fileNamePattern = 'el*mat';



% select files
if strcmp(loadingMode,'all_in_list') % if not all neurons will be processed
    
    %     load names of all neurons: 'neurIndList' cell
    eval('load ../analysed_data/', flistFileNameID ,'/neuronIndList.mat;');
    neurIndList(find(~ismember([1:length(neurIndList)],neuronsIndSel))) = [];
    
    neurIndList = unique(neurIndList);
    
    for i=1:length(neurIndList)
        fileNames(i).name = strcat('el_', neurIndList{i}(4:7) ,'.mat');
    end
    
elseif strcmp(loadingMode,'sel_in_list')
    
    %     load names of all neurons: 'neurIndList' cell
    eval(['load ../analysed_data/neuronIndList.mat;']);
    eval(['load ../analysed_data/', flistFileNameID ,'/neuronIndList.mat;']);
    %     neurIndList(find(~ismember([1:length(neurIndList)],neuronsIndSel))) = [];
    
    %     neurIndList = unique(neurIndList);
    
    iNeuronsIndSel=1;
    for i=neuronsIndSel
        fileNames(iNeuronsIndSel).name = strcat('el_', neurIndList{i}(4:7) ,'.mat');
        iNeuronsIndSel = iNeuronsIndSel+1;
    end
    
elseif strcmp(loadingMode, 'sel_els_in_dir')
    fileInds = get_file_inds_from_el_numbers(inputDir, 'el_*', selElsInDir)
    allFileNames = dir(strcat(inputDir,fileNamePattern));
    
    fileNames = {};
    for i=fileInds
        fileNames(end+1).name = allFileNames(i).name;
    end
    
    
elseif strcmp(loadingMode,'all_in_dir')
    
    % obtain file names for all neurons
    fileNames = dir(strcat(inputDir,fileNamePattern));
    
    
elseif strcmp(loadingMode,'sel_in_dir')
    
    allFileNames = dir(strcat(inputDir,fileNamePattern));
    
    fileNames = {};
    for i=filesSelInDir
        fileNames(end+1).name = allFileNames(i).name;
    end
    
end

% start from file number as specified
for i=1:length(fileNames)
    fprintf('load %s\n', fileNames(i).name);
    % load file
    inputFileName = fileNames(i).name;
    load(fullfile(inputDir,inputFileName));
    
    % struct name for struct that is read into this function
    periodLoc = strfind(inputFileName,'.');
    inputStructName = inputFileName(1:periodLoc-1);
    
    % output struct name & file name
    outputStructName = strrep(inputStructName,'el', 'cl');
    outputFileName = strrep(inputFileName,'el','cl');
    
    % set display mode
    if displayMode ~= 1
        eval(sprintf('%s.params.display.default_waveformmode = %d;',  ...
            inputStructName , displayMode));
    end
    % send struct to next ums spikesorting phase (manual)
    eval(['splitmerge_tool_mod(', inputStructName ,')']);
    set(gcf,'name',inputStructName,'numbertitle','off')
    
    %     drawnow
    
    % wait for user input after sorting
    fprintf('File %d of %d done\n', i , length(fileNames));
    aa = input('Save and proceed?');
    
    %     %         find max amplitude of main electrode signals
    %     avgWaveformMainEl = mean(spikes_saved.waveforms(:,:,1));
    %     spikes_saved.main_el_avg_amp = max(avgWaveformMainEl) - min(avgWaveformMainEl);
    
    % assign new name to output from UMS sorter
    eval([outputStructName,'=spikes_saved;']);
    
    % save output
    save(fullfile(outputDir,outputFileName),outputStructName);
    
    doCloseAll = input('Close all windows? >> ','s')
    if strcmp(doCloseAll,'y')
        close all
    end
    
    
end

end