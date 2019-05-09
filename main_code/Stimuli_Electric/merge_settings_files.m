function settings = merge_settings_files(dirName)
% settings = merge_settings_files(dirName)

% get files
fileNames = dir(fullfile(dirName,'stimulus_log*.mat'));

% load first
structFirstFile = load(fullfile(dirName, fileNames(1).name));
settingsFirstFile = structFirstFile(1).data;
% create output struct
settings = [];
% set header fields
fieldNames = {...
    
'saveRecording', ...
    'recNTKDir', ...
    'slotNum', ...
    'delayInterSpikeMsec', ...
    'delayInterAmpMsec', ...
    'hostIP'};
% header info (not cells)
for iFields=1:length(fieldNames)
    fieldData = getfield(settingsFirstFile, fieldNames{iFields});
    % if not cell, then is header
    
    settings = setfield(settings,fieldNames{iFields}, fieldData);
    
end

fieldNamesHeader = fieldNames;
fieldNamesAll = fields(settingsFirstFile);
fieldNamesBodyIdx = find(~ismember(fieldNamesAll,fieldNamesHeader));


fieldNames = fieldNamesAll(fieldNamesBodyIdx);

% get structs to copy over
dataCurr = {};

for iFile = 1:length(fileNames)
    structFile = load(fullfile(dirName, fileNames(iFile).name));
    settingsFile = structFile(1).data;
    
    for iFields = 1:length(fieldNames)
        if isfield(settingsFile, fieldNames{iFields})
            dataCurr{iFields}{iFile} = getfield(settingsFile, fieldNames{iFields});
        end
    end
end

for iFields = 1:length(fieldNames)
    
    settings = setfield(settings,fieldNames{iFields}, dataCurr{iFields});
    
end

end