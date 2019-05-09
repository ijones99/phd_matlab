function combine_neur_profiles(neurNames, stimNames, dirSaveTo, varargin)
% function combine_neur_profiles(neurNames, stimNames, dirSaveTo)
% neurNames: columns of cells corresponding to neuron names
% stimNames: stimulus names (in cells)
% dirSaveTo: directory to save to (single name)

P.selNeurNameInds = [];
P = mysort.util.parseInputs(P, varargin, 'error');

% % neurnames should have rows for each stim name
% if size(neurNames,1) < size(neurNames,2) 
%     neurNames = neurNames';
% end

dirSaveToFull = strcat('../analysed_data/profiles/',dirSaveTo,'/');


if ~isempty(P.selNeurNameInds)
    selNeurInds = P.selNeurNameInds;
else   
    selNeurInds = 1:size(neurNames,1);
end

data = {};
textprogressbar('Starting process of combining of profiles...'); 
for iNeur =selNeurInds
    
    for iStim =1:length(stimNames)
        % load data for stim
        dataCurr = ifunc.profiles.load_profiles_file( ...
            neurNames{ iNeur,iStim} , stimNames{iStim});
        % contents of field
        fieldContents = getfield(dataCurr, stimNames{iStim});
        fieldContents.neurName = neurNames{ iNeur,iStim}; 
        clear dataCurr
        data = setfield(data,stimNames{iStim}, fieldContents);
    end

     ifunc.profiles.save_profiles_file(neurNames{iNeur,1},dirSaveTo, data);
    textprogressbar(iNeur/size(neurNames,1));
end
textprogressbar('Finished process of combining of profiles.');