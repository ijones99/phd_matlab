function save_footprints_to_files( flistName, varargin)

% function extract_spiketimes_from_cl_files

idNameStartLocation = strfind(flistName{1},'T');idNameStartLocation(1)=[];
flistFileNameID = flistName{1}(idNameStartLocation:end-11);
selFileInds = [];
selElNos = [];
doFelixCluster = 0;
ntkIdx = [];
i=1;
numTsForFootprint = 200;
preSpikeTime = 40; % in samples
postSpikeTime = 60; % in samples
doKeepWaveforms = 0;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        
        if strcmp(varargin{i},'add_dir_suffix')
            flistFileNameID = strcat(flistName{1}(idNameStartLocation:end-11),varargin{i+1});
        elseif strcmp(varargin{i},'sel_inds')
            selFileInds = varargin{i+1};
        elseif strcmp(varargin{i},'sel_els')
            selElNos = varargin{i+1};
        elseif strcmp(varargin{i},'felix_cluster')
            doFelixCluster=1;
        elseif strcmp(varargin{i},'input_ntk_elidx')
            ntkIdx = varargin{i+1};
        else
            
        end
    end
    i=i+1;
end

% analyzed data directory
analyzedDataDir = strcat('../analysed_data/');

% input data directory
inputDir = strcat('../analysed_data/', flistFileNameID ,'/03_Neuron_Selection/');

% output data directory
outputDir = strcat('../analysed_data/', flistFileNameID,'/04_Footprints/');

% make sure dir exists
if ~exist(outputDir)
    eval(['!mkdir ',  outputDir]);
end

% file types to open
fileNamePattern = 'st_*mat';

% obtain file names
fileNames = dir(fullfile(inputDir,fileNamePattern));

%
iNeurList = 1;

% get file indices to read
if ~isempty(selElNos) % if not empty
    selFileInds = [];
    for iSelElNos = 1:length(selElNos)
        selFileInds(iSelElNos) = get_file_inds_from_el_numbers(inputDir, ...
            fileNamePattern, selElNos(iSelElNos)) ;
    end
    
else
    selFileInds = 1:length(fileNames);
    
end
if iscell(flistName)
    flistName = flistName{1};
end

flist ={};flist{end+1} = flistName;
if length(selFileInds)>0
    h5Data = load_h5_data(flist);
end
% start from file number as specified
textprogressbar('extracting footprints')
elNumbersInFp = get_el_numbers_from_dir(outputDir, 'pf_*','unique');
for i=selFileInds
   try 
    load(fullfile(inputDir,fileNames(i).name ));
    eval(sprintf('ts = round(%s.ts*2e4);', fileNames(i).name(1:end-4)));
    
    if length(ts) < numTsForFootprint
        currNumTsForFootprint = length(ts);
    else
        currNumTsForFootprint = numTsForFootprint;
    end
        
    
    [data] = h5.extract_waveforms_from_h5(h5Data{1}, ts(1:currNumTsForFootprint), ...
    'pre_spike_time', preSpikeTime,'post_spike_time',postSpikeTime );
    if ~doKeepWaveforms
       data = rmfield( data,       'waveform');
    end
    outputStructName = sprintf('fp_%s', fileNames(i).name(4:end-4));
    eval(sprintf('%s=data;', outputStructName));
%      outputName = 
    save(fullfile(outputDir,outputStructName ),outputStructName);
    textprogressbar(100*find(i==selFileInds)/length(selFileInds))
   catch
      warning(sprintf('File failed to process: %s.\n',  fileNames(i).name));
   end
end
textprogressbar('end')
%save a list of all the neurons
% save(fullfile(analyzedDataDir,flistFileNameID,'neuronIndList.mat'), 'neurIndList' );
end