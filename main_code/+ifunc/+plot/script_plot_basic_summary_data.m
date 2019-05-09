%% process selected neurons in movies
flistNamesMovies = {...
    'flist_movie_original', ...
    'flist_movie_static_surr_median'...
    };

%     'flist_movie_dynamic_surr_median_each_frame',...
%     'flist_movie_dynamic_surr_median_each_frame_shuffled',...
%     'flist_movie_pix_surr_50_percent',...
%     'flist_movie_pix_surr_90_percent'};



stimNamesMovies = {...
    'Movie_Original', ...
    'Movie_Static_Surr_Median'...
    };
%     'Movie_Static_Surr_Median',...
%     'Movie_Dynamic_Surr_Median_Each_Frame',...
%     'Movie_Dynamic_Surr_Median_Each_Frame_Shuffled',...
%     'Movie_Pix_Surr_50_Percent',...
%     'Movie_Pix_Surr_90_Percent'};

% get directory names
dirList = ifunc.dir.create_dir_list;
acqRate = 2e4;
% variables
selNeurNames = {};
spikeCounts = [];
% go through neurons in original movie
colNum = [4 5];
stimNum = [1 2];

for iStim=1:2
    neurCount = 1;
    % go through directories
    
    for iDir = 1:length(dirList.profiles)
        
        cd(dirList.belsvn{iDir}); % go to Matlab dir
        load neurNameMat.mat; % load neuron names
        
        
        for iNeur = 1:size(neurNameMat,1)
            data = load_profiles_file(neurNameMat{iNeur,colNum(iStim)}, ...
                'use_sep_dir',stimNamesMovies{stimNum(iStim)});
            stimData = getfield(data,stimNamesMovies{stimNum(iStim)});
            % save neuron name
            if iStim==1
                selNeurNames{neurCount} = strcat(get_dir_date,'_', neurNameMat{iNeur,1});
            end
            summaryData{iStim}.spikecount(neurCount) =  ...
                sum(cellfun(@length,stimData.processed_data.repeatSpikeTimeTrain(6:end)));
            
            summaryData{iStim}.spikecount_mean(neurCount) =  ...
                mean(cellfun(@length,stimData.processed_data.repeatSpikeTimeTrain(6:end)));
            summaryData{iStim}.spikecount_std(neurCount) =  ...
                std(cellfun(@length,stimData.processed_data.repeatSpikeTimeTrain(6:end)));
            
            [psthDataSmoothed psthDataMeanSmoothed ] =    ...
                get_psth_for_repeats(gdivide(stimData.processed_data.repeatSpikeTimeTrain,acqRate), 30, 1);
            summaryData{iStim}.corr_index_meister96(neurCount) = ...
                get_corr_index_meister96(psthDataSmoothed(6:end,:),0.025, 0.1, 0)
            
            
            neurCount = neurCount+1
        end
        
    end
    
end


%% plot data

countTitle = 1;
stimTitleText{countTitle} = 'ON Orientation';
neurNumsToPlot{countTitle} = [88 ];
countTitle = countTitle+1;

stimTitleText{countTitle} = 'ON Transient (very quick)';
neurNumsToPlot{countTitle} = [57 25];
countTitle = countTitle+1;

stimTitleText{countTitle} = 'ON Transient';
neurNumsToPlot{countTitle} = [54 59 66 81 70 ];
countTitle = countTitle+1;

stimTitleText{countTitle} = 'ON Transient II';
neurNumsToPlot{countTitle} = [26 34  ];
countTitle = countTitle+1;

stimTitleText{countTitle} = 'ON Transient DS';
neurNumsToPlot{countTitle} = [1 31 ];
countTitle = countTitle+1;

stimTitleText{countTitle} = 'ON Sustained DS';
neurNumsToPlot{countTitle} = [32];
countTitle = countTitle+1;

stimTitleText{countTitle} = 'OFF DS';
neurNumsToPlot{countTitle} = [106 20];
countTitle = countTitle+1;

stimTitleText{countTitle} = 'OFF Transient';
neurNumsToPlot{countTitle} = [10 21 24 22 12 8 ];
countTitle = countTitle+1;

stimTitleText{countTitle} = 'OFF Transient II';
neurNumsToPlot{countTitle} = [27 33 36   ];

stimTitleText{countTitle} = 'ON-OFF Transient';
neurNumsToPlot{countTitle} = [ 67 69 51 73 ];
countTitle = countTitle+1;

stimTitleText{countTitle} = 'ON-OFF Transient II';
neurNumsToPlot{countTitle} = [35 29 ];
countTitle = countTitle+1;

stimTitleText{countTitle} = 'ON-OFF DS';
neurNumsToPlot{countTitle} = [23 43 ];
countTitle = countTitle+1;

stimTitleText{countTitle} = 'ON-OFF Orientation Spec';
neurNumsToPlot{countTitle} = [86 19 18 ];
countTitle = countTitle+1;

fontSize = 14;
doPrint = 0;
%% Plot data for each neuron in all groups (Meister correlation coeff)
titleText = 'Meister Correlation Index for Movie Stimuli'
movieTimeSec = 29.9367;
hFig = figure; hold on;
for iFig = 1:length(neurNumsToPlot)
    subplot(ceil(length(neurNumsToPlot)/3),3,iFig)
    set(gcf,'Position',   [151 53   1647  1051],'color','w' )
    
    Y = [summaryData{1}.corr_index_meister96(neurNumsToPlot{iFig}); ...
        summaryData{2}.corr_index_meister96(neurNumsToPlot{iFig})];
    if length(neurNumsToPlot{iFig}) == 1
        Y(:,2) = NaN;
    end
    maxXVal = max(max([summaryData{2}.corr_index_meister96(cell2mat(neurNumsToPlot)) ...
        summaryData{1}.corr_index_meister96(cell2mat(neurNumsToPlot))]));
    h = barh(Y');
    set(get(h(1),'BaseLine'),'LineWidth',2,'LineStyle',':')
    colormap gray
    legend('Movie Original', 'Movie Static Surround','FontSize', fontSize)
    mylabels = selNeurNames(neurNumsToPlot{iFig});
    set(gca,'YTickLabelMode', 'manual', ...% Label the tick marks explicitly
        'YTickLabel', mylabels,'YTick',[1:length(neurNumsToPlot{iFig})],'FontSize', fontSize)
    completeTitle = strcat(titleText,' - ',stimTitleText{iFig});
    title(completeTitle,'FontWeight','bold')
    
    xlabel(titleText,'FontSize', fontSize)
    xlim([0 maxXVal*1.05]);
    
end
%     save figure
% exportfig(hFig, fullfile('../Figs/Temp/',strcat(titleText)) ,'Resolution', 120,'Color', ...
%     'cmyk','Format','eps')
% saveas(hFig, fullfile('../Figs/Temp/',strcat(completeTitle)))

%% Plot mean data groups (Meister correlation coeff)
hFig = figure; hold on;

for iGroup = 1:length(neurNumsToPlot)
    set(gcf,'Position',   [151          53        1647        1051],'color','w' )
    
    
    meanY(:,iGroup) = [mean(summaryData{1}.corr_index_meister96(neurNumsToPlot{iGroup})); ...
        mean(summaryData{2}.corr_index_meister96(neurNumsToPlot{iGroup}))];
    stdY(:,iGroup) = [std(summaryData{1}.corr_index_meister96(neurNumsToPlot{iGroup})); ...
        std(summaryData{2}.corr_index_meister96(neurNumsToPlot{iGroup}))];
    
    
end
maxXVal = max(max([summaryData{2}.corr_index_meister96(cell2mat(neurNumsToPlot)) summaryData{1}.corr_index_meister96(cell2mat(neurNumsToPlot))]));
%     h = barh(meanY',0.5); hold on
%     ifunc.plot.herrorbar(meanY(1,:), [1:length(meanY)]-0.15, stdY(1,:),'.k');
mylabels = stimTitleText;
ifunc.plot.barweb(meanY', stdY', [], mylabels, [], [], [], ...
    [0 0 0; 1 1 1 ], [], [], 1, [])

ifunc.plot.rotateXLabels(gca,20)

% set(get(gcf,'BaseLine'),'LineWidth',2,'LineStyle',':')
colormap gray
fontSize = 24
%     set(gca,'YTickLabelMode', 'manual', ...% Label the tick marks explicitly
%         'YTickLabel', mylabels,'YTick',[1:length(neurNumsToPlot)],'FontSize', fontSize)
completeTitle = strcat([titleText,' Mean']);
title(completeTitle,'FontWeight','bold','FontSize', fontSize)

ylabel('Mean Meister Correlation Index','FontSize', fontSize)
ylim([0 maxXVal*1.05]);
set(gca,'FontSize',fontSize)
%         save figure
if doPrint
    exportfig(hFig, fullfile('../Figs/Temp/',strcat(completeTitle)) ,'Resolution', 120,'Color', ...
        'cmyk','Format','eps')
    saveas(hFig, fullfile('../Figs/Temp/',strcat(completeTitle)))
end

%% Plot mean data groups (Precision Change)
hFig = figure; hold on;fontSize = 24;
clear meanY stdY
for iGroup = 1:length(neurNumsToPlot)
    set(gcf,'Position',   [151          53        1647        1051],'color','w' )
    
    selData{1} = summaryData{1}.corr_index_meister96(neurNumsToPlot{iGroup});
    selData{2} = summaryData{2}.corr_index_meister96(neurNumsToPlot{iGroup});
    
    meanY(iGroup) = mean( (selData{2} - selData{1})./selData{1}    );
    stdY(iGroup) = std( (selData{2} - selData{1})./selData{1}    );
    
end
maxXVal = 10;
%     h = barh(meanY',0.5); hold on
%     ifunc.plot.herrorbar(meanY(1,:), [1:length(meanY)]-0.15, stdY(1,:),'.k');
mylabels = stimTitleText;
%
% figure, hold on

errorbar(meanY, stdY,'+k','LineWidth',2), hold on
bar(meanY,'k')

set(gca, 'XTickLabel',mylabels, 'XTick',1:numel(mylabels),'FontSize',fontSize)

ylim([-1 2])
ifunc.plot.rotateXLabels(gca,20)
axis on
title('Percent Change in Meister Precision')
xlabel('RGC Type')
ylabel('Percent Change')
%% Plot data for each neuron in all groups (Spike Count)
titleText = 'Spike Counts for Movie Stimuli'
movieTimeSec = 29.9367;
fontSize = 14;
hFig = figure; hold on;
for iFig = 1:length(neurNumsToPlot)
    subplot(ceil(length(neurNumsToPlot)/3),3,iFig)
    set(gcf,'Position',   [151          53        1647        1051],'color','w' )
    
    
    Y = [summaryData{1}.spikecount(neurNumsToPlot{iFig}); ...
        summaryData{2}.spikecount(neurNumsToPlot{iFig})];
    if length(neurNumsToPlot{iFig}) == 1
        Y(:,2) = NaN;
    end
    maxXVal = max(max([summaryData{2}.spikecount(cell2mat(neurNumsToPlot)) summaryData{1}.spikecount(cell2mat(neurNumsToPlot))]));
    h = barh(Y');
    set(get(h(1),'BaseLine'),'LineWidth',2,'LineStyle',':')
    colormap gray
    legend('Movie Original', 'Movie Static Surround','FontSize', fontSize)
    mylabels = selNeurNames(neurNumsToPlot{iFig});
    set(gca,'YTickLabelMode', 'manual', ...% Label the tick marks explicitly
        'YTickLabel', mylabels,'YTick',[1:length(neurNumsToPlot{iFig})],'FontSize', fontSize)
    completeTitle = strcat(titleText,' - ',stimTitleText{iFig});
    title(completeTitle,'FontWeight','bold')
    
    xlabel(strcat(titleText,' Over 30 repetitions of Movie'),'FontSize', fontSize)
    xlim([0 maxXVal*1.05]);
    
    
end
%     save figure
if doPrint
    exportfig(hFig, fullfile('../Figs/Temp/',strcat(titleText)) ,'Resolution', 120,'Color', ...
        'cmyk','Format','eps')
    saveas(hFig, fullfile('../Figs/Temp/',strcat(completeTitle)))
end
%% Plot mean data groups (Spike Count)
hFig = figure; hold on;
fontSize = 24;
for iGroup = 1:length(neurNumsToPlot)
    set(gcf,'Position',   [151          53        1647        1051],'color','w' )
    
    meanY(:,iGroup) = [mean(summaryData{1}.spikecount(neurNumsToPlot{iGroup})); ...
        mean(summaryData{2}.spikecount(neurNumsToPlot{iGroup}))];
    stdY(:,iGroup) = [std(summaryData{1}.spikecount(neurNumsToPlot{iGroup})); ...
        std(summaryData{2}.spikecount(neurNumsToPlot{iGroup}))];
    
end
maxXVal = max(max([summaryData{2}.spikecount(cell2mat(neurNumsToPlot)) ...
    summaryData{1}.spikecount(cell2mat(neurNumsToPlot))]));
%     h = barh(meanY',0.5); hold on
%     ifunc.plot.herrorbar(meanY(1,:), [1:length(meanY)]-0.15, stdY(1,:),'.k');
mylabels = stimTitleText;
ifunc.plot.barweb(meanY', stdY', [], mylabels, [], [], [], ...
    [0 0 0; 1 1 1 ], [], [], 1, [])

ifunc.plot.rotateXLabels(gca,20)

% set(get(gcf,'BaseLine'),'LineWidth',2,'LineStyle',':')
colormap gray

%     set(gca,'YTickLabelMode', 'manual', ...% Label the tick marks explicitly
%         'YTickLabel', mylabels,'YTick',[1:length(neurNumsToPlot)],'FontSize', fontSize)
completeTitle = strcat([titleText,' Mean']);
title(completeTitle,'FontWeight','bold','FontSize', fontSize)

ylabel('Spike Count Over 30 Repetitions','FontSize', fontSize)
ylim([0 maxXVal*1.05]);
set(gca,'FontSize',fontSize)
%         save figure
if doPrint
    exportfig(hFig, fullfile('../Figs/Temp/',strcat(completeTitle)) ,'Resolution', 120,'Color', ...
        'cmyk','Format','eps')
    saveas(hFig, fullfile('../Figs/Temp/',strcat(completeTitle)))
    
end

%% Plot mean data groups (Spike Count)
hFig = figure; hold on;

for iGroup = 1:length(neurNumsToPlot)
    set(gcf,'Position',   [151          53        1647        1051],'color','w' )
    
    meanY(:,iGroup) = [mean(summaryData{1}.spikecount(neurNumsToPlot{iGroup})); ...
        mean(summaryData{2}.spikecount(neurNumsToPlot{iGroup}))];
    stdY(:,iGroup) = [std(summaryData{1}.spikecount(neurNumsToPlot{iGroup})); ...
        std(summaryData{2}.spikecount(neurNumsToPlot{iGroup}))];
    
end
maxXVal = max(max([summaryData{2}.spikecount(cell2mat(neurNumsToPlot)) ...
    summaryData{1}.spikecount(cell2mat(neurNumsToPlot))]));
%     h = barh(meanY',0.5); hold on
%     ifunc.plot.herrorbar(meanY(1,:), [1:length(meanY)]-0.15, stdY(1,:),'.k');
mylabels = stimTitleText;
ifunc.plot.barweb(meanY', stdY', [], mylabels, [], [], [], ...
    [0 0 0; 1 1 1 ], [], [], 1, [])

ifunc.plot.rotateXLabels(gca,20)

% set(get(gcf,'BaseLine'),'LineWidth',2,'LineStyle',':')
colormap gray

%     set(gca,'YTickLabelMode', 'manual', ...% Label the tick marks explicitly
%         'YTickLabel', mylabels,'YTick',[1:length(neurNumsToPlot)],'FontSize', fontSize)
completeTitle = strcat([titleText,' Mean']);
title(completeTitle,'FontWeight','bold','FontSize', fontSize)

ylabel('Spike Count Over 30 Repetitions','FontSize', fontSize)
ylim([0 maxXVal*1.05]);
set(gca,'FontSize',fontSize)
%         save figure
if doPrint
    exportfig(hFig, fullfile('../Figs/Temp/',strcat(completeTitle)) ,'Resolution', 120,'Color', ...
        'cmyk','Format','eps')
    saveas(hFig, fullfile('../Figs/Temp/',strcat(completeTitle)))
    
end
%%
%% Plot mean data groups (Percent Change in Spike Count)
hFig = figure; hold on;
clear meanY stdY
for iGroup = 1:length(neurNumsToPlot)
    set(gcf,'Position',   [151          53        1647        1051],'color','w' )
    
    selData{1} = summaryData{1}.spikecount(neurNumsToPlot{iGroup});
    selData{2} = summaryData{2}.spikecount(neurNumsToPlot{iGroup});
    
    meanY(iGroup) = mean( (selData{2} - selData{1})./selData{1}    );
    stdY(iGroup) = std( (selData{2} - selData{1})./selData{1}    );
    
end
maxXVal = 10;
%     h = barh(meanY',0.5); hold on
%     ifunc.plot.herrorbar(meanY(1,:), [1:length(meanY)]-0.15, stdY(1,:),'.k');
mylabels = stimTitleText;
%
figure, hold on

errorbar(meanY, stdY,'+k','LineWidth',2), hold on
bar(meanY,'k')

set(gca, 'XTickLabel',mylabels, 'XTick',1:numel(mylabels),'FontSize',fontSize)

ylim([-1 2])
ifunc.plot.rotateXLabels(gca,20)
axis on

title('Percent Change in Spike Count')
xlabel('RGC Type')
ylabel('Percent Change')
%%
ifunc.plot.rotateXLabels(gca,20)

% set(get(gcf,'BaseLine'),'LineWidth',2,'LineStyle',':')
% colormap gray

%     set(gca,'YTickLabelMode', 'manual', ...% Label the tick marks explicitly
%         'YTickLabel', mylabels,'YTick',[1:length(neurNumsToPlot)],'FontSize', fontSize)
completeTitle = strcat([titleText,' Mean']);
title(completeTitle,'FontWeight','bold','FontSize', fontSize)

ylabel('Spike Count Over 30 Repetitions','FontSize', fontSize)
ylim([0 maxXVal*1.05]);
set(gca,'FontSize',fontSize)
%         save figure
if doPrint
    exportfig(hFig, fullfile('../Figs/Temp/',strcat(completeTitle)) ,'Resolution', ...
        120,'Color', ...
        'cmyk','Format','eps')
    saveas(hFig, fullfile('../Figs/Temp/',strcat(completeTitle)))
    
end