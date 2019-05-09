fileNamePattern = 'st*mat';
fileDir = '03_Neuron_Selection';

fileNames = dir(fullfile(fileDir, fileNamePattern));

spikes = {};
selNeuronInds = sort(selNeuronInds)
for i=1:length(selNeuronInds)
    
    % get name of struct that will be loaded
    locationOfPeriod = strfind(fileNames(selNeuronInds(i)).name,'.');
    structName = fileNames(selNeuronInds(i)).name(1:locationOfPeriod-1 )
    
    % load file name
    load(fullfile(fileDir, fileNames(selNeuronInds(i)).name));
    
    eval(['spikes{end+1} = ',structName,'.ts;']);
    
    
end