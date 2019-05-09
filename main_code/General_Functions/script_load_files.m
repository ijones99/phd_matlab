% script load_files

% file types to open
fileNamePattern = 'st*mat';

% obtain file names
fileNames = dir(fileNamePattern);

% start from file number as specified
for i=1:length(fileNames)
    
    % load file
    inputFileName = fileNames(i).name;
    load(inputFileName);
    
    % struct name for struct that is read into this function
    periodLoc = strfind(inputFileName,'.');
    inputStructName_st{i} = inputFileName(1:periodLoc-1);
    
end