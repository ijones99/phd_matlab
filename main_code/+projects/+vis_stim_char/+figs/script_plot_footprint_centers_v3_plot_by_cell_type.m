dirNames = projects.vis_stim_char.analysis.load_dir_names;
expNo = 4;
cd([dirNames.dataDirLong{expNo},'Matlab/']); % e

load ~/ln/vis_stim_hamster/data_analysis/cluster_vars/idxAssigns.mat
load('~/ln/neurons_saved/paraOutputMat.mat')
load(fullfile('../analysed_data/moving_bar_ds/dataOut.mat'));

% rowIdxSave


% get cluster numbers
idxGlobalExp = find(paraOutputMat.params(:,1)==expNo )'; % idx for paraOutputMat for this group
clusNumsDir = paraOutputMat.params(idxGlobalExp,2);

% get local (for dir) idx to keep
idxValid = find(ismember(idxGlobalExp,rowIdxSave));


idxGlobalExpValid = idxGlobalExp(idxValid);
clusNumsValid = paraOutputMat.params(idxGlobalExpValid,2);
cellTypeNo = idxAssigns{7}(idxGlobalExpValid);


idxLocalInDir = find(ismember(dataOut.clus_num, clusNumsValid));


LUT = [mats.set_orientation(idxGlobalExpValid,'col')...
    mats.set_orientation(clusNumsValid,'col')...
    mats.set_orientation(cellTypeNo,'col')...
    mats.set_orientation(idxLocalInDir,'col')]; 
% [global idx | clus nums | cell type | localidx]



%%
dirNames = projects.vis_stim_char.analysis.load_dir_names;
figure, hold on

for iDir =expNo%1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    
    hold on
    
    % Plot by radius (proportional to amplitude)
    idxStim = 2;
    
    dirNameProf = '../analysed_data/profiles/';
    
    % load data
    load idxFinalSel
    script_load_data
    
    selClus = idxFinalSel.keep;
    
    % radius = amplitude
    ctrLoc = [];
    maxAmp = nan(1,length(idxDir));
    cMap = plot.colormap_optimal_colors(length(typesInDir));
    for i=1:length(selClus)
        
        filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
        load(fullfile(dirNameProf, filenameProf));
        %         if i==1
        %
        %             plot(neurM(idxStim).footprint.x,neurM(idxStim).footprint.y,'ks','LineWidth',0.25,...
        %                 'MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor','none'), axis equal
        %         end
        %
        waveforms = neurM(idxStim ).footprint.median;
        xyCoord = [neurM(idxStim ).footprint];
        amps = max(waveforms,[],2)'-min(waveforms,[],2)';
        [ctrLoc{i}  maxAmp(i)]= footprint.find_center_with_contour(...
            xyCoord.x, xyCoord.y, amps);
    end

end

jitterAmt = 2*(rand(length(ctrLoc),2)-0.5)*5;

%%
h=figure
figs.scale(h,60,100);
for i = 1:7
        
    subplot(1,7,i)
    hold on
    
    plot(xyCoord.x,  xyCoord.y,'k.');
        
    for i=1:length(selClus )
        
        %     plot(ctrLoc{i}.x+jitterAmt(i,1), ctrLoc{i}.y+jitterAmt(i,2),'o','MarkerSize',5);
        plot.circle2(ctrLoc{i}.x+jitterAmt(i,1), ctrLoc{i}.y+jitterAmt(i,2), 5,...
            'EdgeColor',0.7*ones(1,3), 'LineWidth', 3);
    end
    try
        xLims = minmax(neurM(1).footprint.x)+[-1 1]*borderLen;
        xlim(xLims)
        yLims = minmax(neurM(1).footprint.y)+[-1 1]*borderLen;
        ylim(yLims)
    end
    
end
cMap = distinguishable_colors(11);
cMap = cMap([1:3 5 7:11],:);
% cMap = plot.colormap_optimal_colors(length(typesInDir));

for i=1:size(LUT,1)
    
    cellTypeNo = LUT(i,3);
    subplot(1,7,cellTypeNo )
    hold on
    %     plot(ctrLoc{i}.x+jitterAmt(i,1), ctrLoc{i}.y+jitterAmt(i,2),'o','MarkerSize',5);
    plot.circle2(ctrLoc{LUT(i,4)}.x+jitterAmt(LUT(i,4),1), ...
        ctrLoc{LUT(i,4)}.y+jitterAmt(LUT(i,4),2), 5,...
        'EdgeColor',cMap(cellTypeNo,:), 'LineWidth', 3);
    %     ju = input(' > ')
    axis equal
    borderLen = 30;
    try
        xLims = minmax(neurM(1).footprint.x)+[-1 1]*borderLen;
        xlim(xLims)
        yLims = minmax(neurM(1).footprint.y)+[-1 1]*borderLen;
        ylim(yLims)
    end
    
    dirNameFig = dirNames.local.figs.marching_sqr_over_grid;
    fileNameFig = 'rgc_locations_amps_in_radius';
    % save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
    %      'font_size_all', 13 , ...
    %       'sup_title', ['RGC Locations -  ',expName ]);
    figs.line_width(1)
    %     figs.format_for_pub( 'journal_name','frontiers', 'plot_dims', [10 10])
    % figs.save_for_pub(fullfile(dirNameFig,fileNameFig))
    
    
end
%% plot key

[Y, minMaxAmpIdx] = minmax(A);
xLegend = [850 850];
yLegend = [1300 1200];

for i=1:length(minMaxAmpIdx)
    plot.circle2( xLegend(i),yLegend(i), A(minMaxAmpIdx(i)),...
            'EdgeColor',cMap(minMaxAmpIdx(i),:), 'LineWidth', 3);
        
    text(  xLegend(i)+10,yLegend(i), sprintf('%d',maxAmp(minMaxAmpIdx(i)))) 
    
end


%% Plot by area
dirNames = projects.vis_stim_char.analysis.load_dir_names;
figure, hold on
allAmps = [];
dirNumber = [];
clusIdx = [];
for iDir =1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    subplot(1,7,iDir)
    hold on
    
    idxStim = 2;
    dirNameProf = '../analysed_data/profiles/';
    
    % load data
    load idxFinalSel
    script_load_data
    
    selClus = idxDir;
    
    % radius = amplitude
    ctrLoc = [];
    maxAmp = nan(1,length(selClus));
    for i=1:length(selClus)
        
        filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
        load(fullfile(dirNameProf, filenameProf));
        if i==1
            
            plot(neurM(idxStim).footprint.x,neurM(idxStim).footprint.y,'ks','LineWidth',0.25,...
                'MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor','none'), axis equal
        end
        
        waveforms = neurM(idxStim ).footprint.median;
        xyCoord = [neurM(idxStim ).footprint];
        amps = max(waveforms,[],2)'-min(waveforms,[],2)';
        dirNumber(end+1) = iDir;
        clusIdx(end+1) = i;
        
        [ctrLoc{i}  maxAmp(i)]= footprint.find_center_with_contour(...
            xyCoord.x, xyCoord.y, amps);
        
        
        %     ctrLoc{i} = currCtrLoc;
        
        %     plot.plot_xyz_data(xyCoord.x, xyCoord.y, amps,'n_contour_lines', 10);
        plot.circle_by_area(ctrLoc{i}.x, ctrLoc{i}.y, 20*max(amps)/1000*40, 'MarkerEdgeColor',...
            [.5 .5 .5], 'LineWidth', 1, 'EdgeColor','r','FaceColor','c');
        %     ju = input(' > ')
        
    end
    axis equal
    borderLen = 30;
    xLims = minmax(neurM(1).footprint.x)+[-1 1]*borderLen;
    xlim(xLims)
    yLims = minmax(neurM(1).footprint.y)+[-1 1]*borderLen;
    ylim(yLims)
    n
    
    figs.ticksoff('x','y')
    shg
end
ScaleLengthRatio = 0.4 ;figs.scalebar('ScaleLengthRatio', ScaleLengthRatio)
expName =get_dir_date;
dirNameFig = dirNames.common.figs;
fileNameFig = 'rgc_locations_amps_in_area_all_exp';
% save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
%      'font_size_all', 13 , ...
%       'sup_title', ['RGC Locations -  ',expName ]);
figs.line_width(1)
figs.format_for_pub( 'journal_name','frontiers', 'plot_dims', [25 25])
figs.save_for_pub(fullfile(dirNameFig,fileNameFig))
%% plot stem
for i=1:104
    xLoc(i) = ctrLoc{i}.x;
    yLoc(i) = ctrLoc{i}.y;
end
figure
stem3(xLoc, yLoc, maxAmp,'MarkerFaceColor','c','LineWidth',2,'MarkerEdgeColor','c')
axis equal

%% color = amp

colorMats = graphics.distinguishable_colors(100,[1 1 1]);

for i=1:150%length(selClus)
    
    filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
    load(fullfile(dirNameProf, filenameProf));
    if i==1
        figure, hold on
        plot(neurM(idxStim).footprint.x,neurM(idxStim).footprint.y,'ks','LineWidth',1,'MarkerFaceColor',[.5 .5 .5]), axis equal
    end
    
    waveforms = neurM(idxStim ).footprint.median;
    xyCoord = [neurM(idxStim ).footprint];
    
    amps = max(waveforms,[],2)'-min(waveforms,[],2)';
    ctrLoc = footprint.find_center_with_contour(xyCoord.x, xyCoord.y, amps);
    
    %     plot.plot_xyz_data(xyCoord.x, xyCoord.y, amps,'n_contour_lines', 10);
    idxColor = round(max(amps)/10);
    plot.circle2(ctrLoc.x, ctrLoc.y, 7, 'MarkerEdgeColor',[.5 .5 .5], 'LineWidth', 1,...
        'EdgeColor','r','FaceColor',colorMats(idxColor ,:));
    ju = input(' > ')
    
end
expName =get_dir_date;
dirNameFig = dirNames.local.figs.marching_sqr_over_grid;
fileNameFig = 'rgc_locations_amps_in_color';
save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
    'font_size_all', 13 , ...
    'sup_title', ['RGC Locations -  ',expName ]);
%%
[I J] = find( zi == max(max(zi)))
ctrLoc.x = xi(I,J)
ctrLoc.y = yi(I,J)
plot(ctrLoc.x,ctrLoc.y,'kx','LineWidth',3)

%% check largest amplitude signals
figure
for iDir =1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    
    load idxFinalSel
    script_load_data
    
    selClus = idxDir;
    
    % radius = amplitude
    ctrLoc = [];
    maxAmp = nan(1,length(selClus));
    for i=1:length(selClus)
        
        filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
        load(fullfile(dirNameProf, filenameProf));   
        waveforms = neurM(idxStim ).footprint.median;
        amps = max(waveforms,[],2)'-min(waveforms,[],2)';
        if max(max(amps)) > 2200
            hist(amps,60)
            xx = input('enter')
        end
        
    end
    
end



