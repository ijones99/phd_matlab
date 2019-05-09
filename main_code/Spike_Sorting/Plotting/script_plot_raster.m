%Variables
acqRate = 2e4;

% file types to open
fileNamePattern = 'st_*mat';

% obtain file names
fileNames = dir(fileNamePattern);

% row spacing
rowSpacing = 1;

figure, hold on

rangeLim=0.25;

for iFile=1:length(fileNames)
    
    % load file
    inputFileName = fileNames(iFile).name;
    load(inputFileName);
    
    % struct name for struct that is read into this function
    periodLoc = strfind(inputFileName,'.');
    inputMatrixName = inputFileName(1:periodLoc-1);
    
    % temporary name for matrix
    workingStruct = eval([inputMatrixName]);
%     workingStruct = workingStruct(:);
    
       plot([(workingStruct)/acqRate; (workingStruct)/acqRate],...
        [iFile*rowSpacing*ones(size(workingStruct))+rangeLim; ...
        iFile*rowSpacing*ones(size(workingStruct))-rangeLim])
    
    
    text(-1, iFile*rowSpacing, num2str( iFile ));
    
end