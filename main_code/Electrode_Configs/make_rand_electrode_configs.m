function make_rand_electrode_configs(elNumberPool, elConfigSize, dirName, ...
    stimElNum, namePrefix)

% function make_rand_electrode_configs(elNumberPool, elConfigSize, dirName, ...
%     stimElIdx, stimElNum, namePrefix)
% create random configurations given a list of electrode numbers.

% elNumberPool = mm.configList.selectedElectrodes;
% elConfigSize = 120;

idxStimElInPool = find(ismember( elNumberPool, stimElNum ));

if idxStimElInPool
    % remove the stimulus electrode if it exists
    elNumberPool(idxStimElInPool) = [];
end

numConfigs = ceil(length(elNumberPool)/elConfigSize);
elNumberPoolRand = elNumberPool(randperm(length(elNumberPool)));
elNumberPoolRandFullSets = reshape(elNumberPoolRand(1:(numConfigs-1)*elConfigSize),...
    [numConfigs-1, elConfigSize]);
elNumberPoolRandEndSet = elNumberPoolRand((numConfigs-1)*elConfigSize:end);

for iConfig = 1:numConfigs-1
    
    fileName = sprintf('%s%03.0f', namePrefix, iConfig-1);
    fprintf('--------------------------_>>>>>>>>>>>>>>>>>>>>>>..')
    selectedElectrodes = [stimElNum elNumberPoolRandFullSets(iConfig,:)];
    stimElIdx = 1;
    create_configuration_from_el_numbers(dirName, ...
        fileName,selectedElectrodes , stimElIdx);
    fprintf('%d of %d completed\n', iConfig, numConfigs);
    
end

iConfig = numConfigs;
fileName = sprintf('%s%03.0f', namePrefix, iConfig-1);
fprintf('--------------------------_>>>>>>>>>>>>>>>>>>>>>>..')

idxStimElInPool = find(ismember( elNumberPoolRandEndSet, stimElNum ));

if idxStimElInPool
    % remove the stimulus electrode if it exists
    elNumberPoolRandEndSet(idxStimElInPool) = [];
end

selectedElectrodes = [stimElNum elNumberPoolRandEndSet];
create_configuration_from_el_numbers(dirName, ...
    fileName,selectedElectrodes , stimElIdx);
fprintf('%d of %d completed\n', iConfig, numConfigs);

