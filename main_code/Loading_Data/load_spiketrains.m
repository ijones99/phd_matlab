function tsMatrix = load_spiketrains(flistFileNameID, varargin)
timeRange = [];
timeRangeInds = [];
acqRate = 2e4;
neurName = '';
if ~isempty(varargin)
    for i=1:length(varargin)
        
        if strcmp(varargin{i},'time_range' )
            timeRange = varargin{i+1};
        elseif strcmp(varargin{i},'time_range_inds' )
            timeRangeInd = varargin{i+1};
        elseif strcmp(varargin{i},'neur_name' )
            neurName = varargin{i+1};
        end
    end  
end

% directory
dirName = strcat('../analysed_data/', flistFileNameID ,'/03_Neuron_Selection/');

% promtp
aa = input(strcat('dir name = ',dirName,' ok?'));

% file types to open
fileNamePattern = fullfile(dirName,'st_*mat');

% obtain file names
fileNames = dir(fileNamePattern);

% init struct
neuronTs = struct('name', {}, 'ts', {});

% for loading specific neuron
if isempty(neurName)
    loadFileIdx = 1:length(fileNames);
else
    loadFileIdx = filenames.find_str_in_filenames_cell(['st_',neurName],fileNames);
end


for iFile=1:length(loadFileIdx)
    %     iFile
    % load file
    inputFileName = fileNames(loadFileIdx(iFile)).name;
    load(fullfile(dirName,inputFileName));
    
    % struct name for struct that is read into this function
    periodLoc = strfind(inputFileName,'.');
    inputMatrixName = inputFileName(1:periodLoc-1);
    
    % temporary name for matrix
    tsMatrix{iFile}.name = inputMatrixName;
    tsMatrix{iFile}.el_avg_amp =  eval([inputMatrixName,'.el_avg_amp;']);
    tsMatrix{iFile}.ts = [];

    if ~isempty(timeRangeInds)
       allChannelTs =  eval([inputMatrixName,'.ts']);

       % output cell
       tsMatrix{iFile}.ts = single(zeros(1,length(allChannelTs)));
       for iRange = 1:2:length( timeRange)
           selTs = allChannelTs(and(allChannelTs>=timeRange(iRange)/acqRate,allChannelTs<=timeRange(iRange+1)/acqRate));
           zeroPt = find(tsMatrix{iFile}.ts==0,1);
           tsMatrix{iFile}.ts(zeroPt:zeroPt+length(selTs)-1);
       end
       tsMatrix{iFile}.ts(tsMatrix{iFile}.ts==0) = [];
    
    else
        % assign timestamps and round to nearest msec
        tsMatrix{iFile}.ts = eval([inputMatrixName,'.ts']);
    end
    iFile
end

end