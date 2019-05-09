%% load matrices
clear neurNameMat stimNames
load neurNameMat, load stimNames

dirDate = get_dir_date;
neurNameReg = {};
for iNeurName=1:size(neurNameMat,1)
    tempCell = {};
    % set neuron reference name
    for iStimName=1:length(stimNames)
        tempCell = setfield(tempCell,stimNames{iStimName},sprintf('%s_%s', ...
            dirDate, neurNameMat{iNeurName,iStimName}));
        
    end
    neurNameReg{end+1} = tempCell;
end

save('neurNameReg.mat','neurNameReg');
fprintf('saved.\n')