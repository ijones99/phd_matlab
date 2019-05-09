%% plot # spikes per stim
% stim change timestamps
load stimChangeTsAll

% file info
dirNameProf = '../analysed_data/profiles/';
fileNamesProf = filenames.list_file_names('clus*merg*.mat',dirNameProf);

spikeCnt = zeros(length(idxFinalSel.keep),6);

for iClus=1:length(idxFinalSel.keep)
%     currIdx = idxNeur.final_selection{idxFinalSel.keep(iClus)};
    load(fullfile(dirNameProf, fileNamesProf(iClus).name));
    
    for k=1:length(neurM)
        spikeCnt(iClus, k) = length(neurM(k).ts) ;
    end
    
end

% approx stim dur
timeSec = [];
for i=1:length(stimChangeTs)
    timeSec(i) = max(stimChangeTs{i})/2e4;
end

meanSpks = mean(spikeCnt,1)./timeSec;
stdSpks = std(spikeCnt./repmat(timeSec,size(spikeCnt,1),1),1);
medSpks = median(spikeCnt,1)./timeSec;

h=figure, figs.scale(h,50,50); hold on, axis equal
errorbar(meanSpks, stdSpks)
hold on
plot(medSpks,'--rs')

title('number of cells per stim');
stimNames = {'moving bars on off ',...
    'moving bars length test ',...
    'moving bars speed test ',...
    'drifting linear pattern ',...%3
    'marching sqr over grid ',...%3
    'marching sqr '};
for i=1:6
    stimNamesStr{i} = sprintf('%d) %s', i,stimNames{i});
end
annotation('textbox', [0.7,0.7,0.1,0.1],...
    'String', stimNamesStr,'FontSize',13)

h=figure, figs.scale(h,100,50)
spikeRate = spikeCnt./repmat(timeSec,size(spikeCnt,1),1);
maxSpikeRate = max(spikeRate,[],2)';
xVals = repmat(1:size(spikeCnt,1),2,1);
yVals = zeros(1,size(spikeCnt,1));
yVals(2,:) = maxSpikeRate;
colorVals = graphics.distinguishable_colors(length(idxFinalSel.keep));
colormap(colorVals);
plot(spikeRate ,'s');hold on
legend(stimNames)
plot(xVals, yVals,'k');

xlabel('Neuron Index', 'FontName', 'Courier');
ylabel('Spike Rate (spikes/sec)', 'FontName', 'Courier')
set(gca,'FontSize',13, 'FontName', 'Courier')
set(findall(gcf,'type','text'),'FontSize',13,'FontName', 'Courier')
title('Spike Rate per Stimulus', 'FontName', 'Courier', 'FontSize',14)

%%
spikeRateAll = {};
dirNames = projects.vis_stim_char.analysis.load_dir_names;
for iDir =1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    % stim change timestamps
    load stimChangeTsAll 
    load idxFinalSel
    
    % file info
    dirNameProf = '../analysed_data/profiles/';
    fileNamesProf = filenames.list_file_names('clus*merg*.mat',dirNameProf);
    
    spikeCnt = zeros(length(idxFinalSel.keep),6);
    
    for iClus=1:length(idxFinalSel.keep)
        %     currIdx = idxNeur.final_selection{idxFinalSel.keep(iClus)};
        load(fullfile(dirNameProf, fileNamesProf(iClus).name));
        
        for k=1:6%length(neurM)
            spikeCnt(iClus, k) = length(neurM(k).ts) ;
        end
    end
    
    % approx stim dur
    timeSec = [];
    for i=1:6%length(stimChangeTs)
        timeSec(i) = max(stimChangeTs{i})/2e4;
    end
    
    meanSpks = mean(spikeCnt,1)./timeSec;
    stdSpks = std(spikeCnt./repmat(timeSec,size(spikeCnt,1),1),1);
    medSpks = median(spikeCnt,1)./timeSec;
      
    spikeRate = spikeCnt./repmat(timeSec,size(spikeCnt,1),1);
       
    spikeRateAll{iDir} = spikeRate;
    progress_info( iDir , length(dirNames.dataDirLong));
end


%% Create stacked bar plot of response per stimulus

meanRatio = nan(length(dirNames.dataDirLong),6);

for iDir =1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    % stim change timestamps
    load stimChangeTsAll
    load idxFinalSel
    
    spikeRate = spikeRateAll{iDir};
    
    totalSpikeRateCnt = sum(spikeRate,2);
    denomMat = repmat(totalSpikeRateCnt,1,6);
    spikeRateRatio = spikeRate./denomMat;
    meanRatio(iDir,:) = mean(spikeRateRatio,1);
    %     stdRatio = std(spikeRateRatio,1);
end

stimNames = {'moving bars on off ',...
    'moving bars length test ',...
    'moving bars speed test ',...
    'drifting linear pattern ',...%3
    'marching sqr over grid ',...%3
    'marching sqr '};
legend(stimNames)


