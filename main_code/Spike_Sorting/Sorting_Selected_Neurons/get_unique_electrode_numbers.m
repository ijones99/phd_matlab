function uniqueNeuronsIndSel = get_unique_electrode_numbers(flistName, neuronsIndSel, varargin)

%

% determine if there are multiple files
if length(flistName) > 1
    % ID number for files
    flistFileNameID = strcat(flistName{1}(end-21:end-11),'_plus_others');
else
    % ID number for files
    flistFileNameID = flistName{1}(end-21:end-11);
end


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


%     load names of all neurons: 'neurIndList' cell

eval(['load ../analysed_data/', flistFileNameID ,'/neuronIndList.mat;']);
%     neurIndList(find(~ismember([1:length(neurIndList)],neuronsIndSel))) = [];

%     neurIndList = unique(neurIndList);

iNeuronsIndSel=1;
fileNames = {};
for i=neuronsIndSel
    fileNames(iNeuronsIndSel).name = strcat('el_', neurIndList{i}(4:7) ,'.mat');
    iNeuronsIndSel = iNeuronsIndSel+1;
end


electrodeNumbers = 0;

for i=1:length(fileNames)
    %         fprintf('load %s\n', fileNames(i).name);
    % load file
    inputFileName = fileNames(i).name;
%     load(fullfile(inputDir,inputFileName));
    
    % get electrode number
    periodLoc = strfind(inputFileName,'.');
    underscoreLoc = strfind(inputFileName,'_');
    inputStructName = inputFileName(1:periodLoc-1);
    
    electrodeNumbers(i,:) = str2num(inputFileName(underscoreLoc+1:periodLoc-1));
    
end

uniqueElectrodeNumbers = unique(electrodeNumbers);

uniqueNeuronsIndSel = zeros(1,length(electrodeNumbers));
for i=1:length(uniqueElectrodeNumbers)
   uniqueNeuronsIndSel(find(electrodeNumbers == uniqueElectrodeNumbers(i),1)) = 1;
end

uniqueNeuronsIndSel = uniqueNeuronsIndSel.*neuronsIndSel;

uniqueNeuronsIndSel = uniqueNeuronsIndSel(uniqueNeuronsIndSel>0);

