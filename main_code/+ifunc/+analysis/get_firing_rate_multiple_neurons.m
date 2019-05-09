function [firingRatesOut calcCorr]= get_firing_rate_multiple_neurons(stimNames, dirList, flistNames, stimNum,distMoved)
acqFreq = 2e4;
calcCorr = [];
firingRatesOut= {};
if ischar(dirList)
    dirListTemp{1} = dirList; clear dirList;
    dirList = dirListTemp;
end
%go through directories
for iDir = 1:length(dirList)
    % go to dir
    if iscell(dirList)
        cd(dirList{iDir});
        fprintf('Move to dir %s\n', dirList{iDir});
    else
        cd(dirList);
        fprintf('Move to dir %s\n', dirList);
    end
    % load flist
    for iStim = 1:length(flistNames) % go through flists
        % set up directories
        load neurNameMat.mat
        neurNames = neurNameMat(:,stimNum(iStim));
        
        % load flist
        flist = {}; eval(flistNames{iStim});
        binSizeSec = 0.0333; % seconds
        acqRate = 2e4;
        edges = [0:binSizeSec:29.9640-binSizeSec];
        for iFile = 1:length(neurNames)
            data = ifunc.profiles.load_profiles_file(neurNames{iFile},stimNames{iStim});
            
            stimData = getfield(data,stimNames{iStim});
            selRepeats = stimData.processed_data.repeatSpikeTimeTrain(6:35);
            numTrials = length(selRepeats);
            
            for i=1:length(selRepeats), selRepeatsSec{i} = selRepeats{i}/acqRate;end
            psth = ifunc.analysis.calc_psth(selRepeatsSec, edges);
            firingRate = ifunc.analysis.firing_rate.psth2firingrate(psth,numTrials,binSizeSec);
            firingRatesOut{end+1}.firing_rate = firingRate;
            firingRatesOut{end}.stimulus_name = stimNames{iStim};
            firingRatesOut{end}.neuron_name = neurNames{iFile};
            firingRatesOut{end}.exp = get_dir_date;
            firingRatesOut{end}.bin_size = binSizeSec;
            firingRatesOut{end}.edges = edges;
            firingRatesOut{end}.corr = ...
                corr(firingRatesOut{end}.firing_rate',...
                distMoved);
            calcCorr(end+1) = firingRatesOut{end}.corr;
            fprintf('%d\n',iFile)
        end
        
    end
end
end