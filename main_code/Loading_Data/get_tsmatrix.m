function tsMatrix  = get_tsmatrix(flistFileNameID, varargin)
% get tsMatrix

fileInds = [];

% input data directory
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');


% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'sel_by_el')
            elNos = varargin{i+1};
            fileInds = get_file_inds_from_el_numbers(dirNameSt, '*.mat', elNos);
        elseif strcmp( varargin{i}, 'sel_by_ind')
            fileInds = varargin{i+1};
        elseif strcmp( varargin{i}, 'all_in_dir')

        else
            if i/2 ~= round(i/2) % for odd numbers
                fprintf('argument not recognized\n');
            end
            
        end
    end
end

% -->> load all timestamps from all neurons and put into a matrix

% file types to open
fileNamePattern = 'st*mat';

% obtain file names for all neurons
fileNames = dir(strcat(dirNameSt,fileNamePattern));

% timestamp matrix
tsMatrix = {};

if isempty(fileInds)
   fileInds = 1: length(fileNames);
end


for i=fileInds
    fprintf('load %s\n', fileNames(i).name);
    % load file
    inputFileName = fileNames(i).name;
    load(fullfile(dirNameSt,inputFileName));
    
    % struct name for struct that is read into this function
    periodLoc = strfind(inputFileName,'.');
    tsMatrix{end+1}.el_ind = i;
    eval(['tsMatrix{end}.spikeTimes = ',inputFileName(1:periodLoc-1),'.ts;']);
    eval(['tsMatrix{end}.name = ''', fileNames(i).name(4:periodLoc-1),''';']);

end