load ~/Matlab/ProcessedData/paramsAll.mat
% b = combnk(1:5,2);
% b = b(:,end:-1:1);
b = [1 2; 1 3 ; 1 4; 1 5; 2 3; 2 4; 2 5; 3 4 ; 3 5; 4 5] 
dirNameFig = '~/MatlabData/Plots/Presentation_21May2014/';
xBox = [-1 1; -1 1; -1 1; -1 1; ...
    0.06 0.9; 0.06 0.9; 0.06 0.9; 0.03 1.2; ...
    0.03 1.2; 0.08 0.92]
yBox = [0.06 0.9; 0.03 1.2; 0.08 0.92; 0 0.55; ...
    0.03 1.2; 0.08 0.92; 0 0.55; 0.08 0.92; ...
    0 0.55; 0.0 0.55]

for i=1:length(b)
    xIdx = b(i,1);
    yIdx = b(i,2);
    
    titleName = sprintf('%s vs %s', paramsAll.fieldNames{xIdx},paramsAll.fieldNames{yIdx});
    figure('name',titleName); hold on
    plot(paramsAll.values(:,xIdx),paramsAll.values(:,yIdx),'o','LineWidth', 10)
    xlabel(paramsAll.fieldNames{xIdx})
    ylabel(paramsAll.fieldNames{yIdx})
    %     plot box
    xBoxCurr = xBox(i,:); yBoxCurr = yBox(i,:); 
    xCoords = [xBoxCurr(1) xBoxCurr(2) xBoxCurr(2) xBoxCurr(1) xBoxCurr(1)];
    yCoords = [yBoxCurr(1) yBoxCurr(1) yBoxCurr(2) yBoxCurr(2) yBoxCurr(1)];
    plot(xCoords, yCoords, 'r', 'LineWidth',3,'LineStyle','--')
%     w = abs(diff(xBox(i,:)));h = abs(diff(yBox(i,:)));
%     rectangle('Position',[x,y,w,h],'LineWidth',3,'LineStyle','--')
    
    title(titleName)
    figureHandle = gcf;
    % set font sizes
    set(findall(figureHandle,'type','text'),'fontSize',30)
    set(gca,'FontSize',30,'LineWidth',3);
    % save plots
    fileNameFig = strrep(titleName, ' ','_');
    save.save_plot_to_file(dirNameFig, fileNameFig,'fig');
    save.save_plot_to_file(dirNameFig, fileNameFig,'eps');
end
%% Firing rate for preferred spot, 1.5 seconds
figure, hold on
startStopTime = [-0.5 1.5]*2e4;
[firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
    neur.spt.spikeTrains(selResponseIdx),startStopTime,'bin_width',0.0001*2e4);
% plot figure
lineWidth = 2;
% total possible area
squarePtCoords.x = [0 0 1.5 1.5];
squarePtCoords.y = [0 1 1 0];
area(squarePtCoords.x, squarePtCoords.y,'FaceColor','b')
firingRate = firingRate/max(firingRate);
 area(edges/acqRate,firingRate,'LineWidth', lineWidth,'FaceColor','r'), hold on
xlabelName='Time (ms)'; ylabelName='Firing Rate Normalized'; 
xlabel(xlabelName); ylabel(ylabelName); 
dotBrightness = {'OFF', 'ON'};
titleName = sprintf('RGC Response to Preferred %s Spot (%s)', dotBrightness{OFForON},neur.spt.clusterName)
title(titleName)
figureHandle = gcf;
% set font sizes
set(findall(figureHandle,'type','text'),'fontSize',14)
set(gca,'FontSize',14)
dirNameFig = '../Figs/Visual_Stim/';
fileNameFig = sprintf('%s_fr_best_spot', neurFileName);
legend({'total possible area';'area under curve'});
%% Spots: get FR per dot size
% load stim params
load ~/Matlab/settings/stimFrameInfo_spots.mat
dotDiams = unique(stimFrameInfo.dotDiam);
dotRGBVal = unique(stimFrameInfo.rgb);
startStopTime = [-0.5 1]*2e4;
clear peakFR
for jRGB = 1:length(dotRGBVal)
    for i=1:length(dotDiams)
        selResponseIdx = find(stimFrameInfo.dotDiam == dotDiams(i)&stimFrameInfo.rgb == ...
            dotRGBVal(jRGB) );
%         [firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_from_psth(...
%             neur.spt.spikeTrains(selResponseIdx ),startStopTime);
         [firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
            neur.spt.spikeTrains(selResponseIdx ),startStopTime);
        
        peakFR(jRGB,i) = max(firingRate);
        
    end
end
figure, hold on, 
lineWidth = 2;
% total possible area
squarePtCoords.x = [0 0 900 900];
squarePtCoords.y = [0 1 1 0];
area(squarePtCoords.x, squarePtCoords.y,'FaceColor','b'), hold on
hold on

area(dotDiams, peakFR(1,:)/max(peakFR(1,:)),'FaceColor','r');
% plot(dotDiams, peakFR(2,:),'ro-','LineWidth',lineWidth);
xlabelName='Dot Diameters (um)'; ylabelName='Firing Rate Normalized';
xlabel(xlabelName); ylabel(ylabelName); 
dotBrightness = {'OFF', 'ON'};
titleName = sprintf('RGC Response to Flashing Spots (%s)', neur.spt.clusterName)
title(titleName)
figureHandle = gcf;
% set font sizes
set(findall(figureHandle,'type','text'),'fontSize',14)
set(gca,'FontSize',14)
legend({'total possible area';'area under curve'});

dirNameFig = '../Figs/Visual_Stim/';
fileNameFig = sprintf('%s_fr_per_spot_size', neurFileName);
