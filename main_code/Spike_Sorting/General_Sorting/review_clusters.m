function review_clusters(flistName, varargin)
% sort_ums_output(flist, varargin)
% phase 2 of spikesorting process: this function opens each file produced
% by the UMS batch process and allows manual merging and separating of
% found clusters. Each file has data from 6 electrodes.
%
% flist: name of flist file
% neuronsIndSel: indices to select
% initial_batch: use if this is for the initial sorting
doOpenOnly = 0;

selPatchNumber = [];
flist = {}; eval(flistName);
filesSelInDir = [];
selElNos = [];
neuronsIndSel = 0;
loadingMode = 'all_in_dir';
ctrElidx = [];
flistNo = [];
i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        if strcmp(varargin{i}, 'sel_in_list')
            loadingMode = varargin{i};
            neuronsIndSel=varargin{i+1};
        elseif strcmp(varargin{i}, 'sel_flist')
            flistNo=varargin{i+1};
        elseif strcmp(varargin{i}, 'all_in_dir')
            loadingMode = varargin{i};
        elseif strcmp(varargin{i}, 'sel_els')
            loadingMode = varargin{i};
            selElNos = varargin{i+1};
        elseif strcmp(varargin{i}, 'sel_in_dir')
            loadingMode = varargin{i};
            filesSelInDir = varargin{i+1};
        elseif strcmp(varargin{i}, 'open_only')
            doOpenOnly = 1;
        elseif strcmp(varargin{i}, 'center_elidx')
            loadingMode = varargin{i};
            ctrElidx= varargin{i+1};
        else
            warning('unknown argument at pos %d: %s\n', 2+i, varargin{i});
        end
    end
    i=i+1;
end
% inputted data:
global spikes_saved
% ---------- Dirs ----------
% main directory for this file
if ~isempty(flistNo)
    flist = flist(flistNo );
end
idNameStartLocation = strfind(flist{1},'T');idNameStartLocation(1)=[];
flistFileNameID = get_flist_file_id(flist);
stimName  = strrep(strrep(flistName,flistFileNameID,''),'flist_','');


flistFileDirName = sprintf('%s_%s', flistFileNameID, strrep(stimName,'flist_',''));

FILE_DIR = strcat('../analysed_data/', flistFileDirName,'/');

% dir in which to put input files
INPUT_DIR = strcat(FILE_DIR, '02_Post_Spikesorting/');

% --------------------------
currDir = pwd;

% input data directory
inputDir = INPUT_DIR; %strcat(currDir(1:end-6), ...
    %'analysed_data/', flistFileNameID,'/02_Post_Spikesorting/')
fprintf('%s.\n', inputDir);
aaa = input('Dir locations are okay?');

% file types to open
fileNamePattern = 'cl*mat';

% select files
if strcmp(loadingMode,'all_in_list') % if not all neurons will be processed
    
    %     load names of all neurons: 'neurIndList' cell
    eval('load ../analysed_data/', flistFileNameID ,'/neuronIndList.mat;');
    neurIndList(find(~ismember([1:length(neurIndList)],neuronsIndSel))) = [];
    
    neurIndList = unique(neurIndList);
    
    for i=1:length(neurIndList)
        fileNames(i).name = strcat('cl_', neurIndList{i}(4:7) ,'.mat');
    end
    
elseif strcmp(loadingMode,'sel_els')
    for iSelElNos = 1:length(selElNos)
        fileInds(iSelElNos) = get_file_inds_from_el_numbers(inputDir, ...
            fileNamePattern, selElNos(iSelElNos))
    end
    
    allFileNames = dir(strcat(inputDir,fileNamePattern));
    
    fileNames = {};
    for i=fileInds
        fileNames(end+1).name = allFileNames(i).name;
    end
    
    
elseif strcmp(loadingMode,'sel_in_list')
    
    %     load names of all neurons: 'neurIndList' cell
    eval(['load ../analysed_data/neuronIndList.mat;']);
    eval(['load ../analysed_data/', flistFileNameID ,'/neuronIndList.mat;']);
    %     neurIndList(find(~ismember([1:length(neurIndList)],neuronsIndSel))) = [];
    
    %     neurIndList = unique(neurIndList);
    
    iNeuronsIndSel=1;
    for i=neuronsIndSel
        fileNames(iNeuronsIndSel).name = strcat('cl_', neurIndList{i}(4:7) ,'.mat');
        iNeuronsIndSel = iNeuronsIndSel+1;
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

if strcmp(loadingMode,'center_elidx')
    fileNames = {};
    
    for i=1:length(ctrElidx)
        fileNames(end+1).name = sprintf('cl_%04d.mat', ctrElidx(i));
    end
    
    
end

if ~doOpenOnly
    % start from file number as specified
    for i=1:length(fileNames)
        
        
        fprintf('load %s\n', fileNames(i).name);
        % load file
        inputFileName = fileNames(i).name;
        load(fullfile(inputDir,inputFileName));
        
        % struct name for struct that is read into this function
        periodLoc = strfind(inputFileName,'.');
        inputStructName = inputFileName(1:periodLoc-1);
        
        % send struct to next ums spikesorting phase (manual)
        eval(['spikes_saved = ', inputStructName,';']);
        eval(['splitmerge_tool_mod(', inputStructName ,')']);
        
        inputStructNameTitle = [ flistFileNameID inputStructName];
        set(gcf,'name',inputStructNameTitle,'numbertitle','off')
        drawnow
        
        % wait for user input after sorting
        fprintf('File %d of %d done\n', i , length(fileNames));
        inputDoSave = [];
        inputDoSave = input('Save and proceed [Enter/(n)o]?','s');
        
        
        % assign new name to input from UMS sorter
        eval([inputStructName,'=spikes_saved;']);
        if ~strcmp(inputDoSave,'n')
            % save input
            save(fullfile(inputDir,inputFileName),inputStructName);
        end
        close all
        eval(['clear ',inputStructName,' spikes_saved']);
        
    end
else
    for i=1
        
        
        fprintf('load %s\n', fileNames(i).name);
        % load file
        inputFileName = fileNames(i).name;
        load(fullfile(inputDir,inputFileName));
        
        % struct name for struct that is read into this function
        periodLoc = strfind(inputFileName,'.');
        inputStructName = inputFileName(1:periodLoc-1);
        
        % send struct to next ums spikesorting phase (manual)
        eval(['spikes_saved = ', inputStructName,';']);
        eval(['splitmerge_tool_mod(', inputStructName ,')']);
        
        inputStructNameTitle = [ sprintf('%s - %s - %s', flistFileNameID, stimName, inputStructName)];
        set(gcf,'name',inputStructNameTitle,'numbertitle','off')
        drawnow
        
        
    end
    
end
