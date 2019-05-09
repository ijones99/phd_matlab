function [ spikes localSorting]= load_auto_cluster_file( selDir, neurName, varargin)

% function extract_spiketimes_from_cl_files


selFileInds = [];
selElNos = [];
doFelixCluster = 1;
ntkIdx = [];
i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        
        if strcmp(varargin{i},'sel_inds')
            selFileInds = varargin{i+1};
        elseif strcmp(varargin{i},'sel_els')
            selElNos = varargin{i+1};
        elseif strcmp(varargin{i},'input_ntk_elidx')
            ntkIdx = varargin{i+1};
        else
            
        end
    end
    i=i+1;
end

% file types to open
fileNameSuffix = 'Export4UMS2000';

% obtain file names
fileNames = dir(fullfile(selDir,strcat( '*',neurName,'*',fileNameSuffix, '*.mat')) );


inputFileName = fileNames(1).name;
load(fullfile(selDir,inputFileName));
fprintf('Loading %s.\n', inputFileName);
spikes = localSorting.spikes;
end