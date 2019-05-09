spkN = 350;

cd /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/10Apr2014/Matlab
dirName = '../analysed_data/T11_10_38_51_wn_checkerboard_n_01/03_Neuron_Selection/';
dirNameSave = '../analysed_data/extracted_footprints/';
mkdir(dirNameSave);


fileNames = filenames.get_filenames('*mat', dirName);

ntkData = load_ntk2_data('../proc/Trace_id1588_2014-04-10T11_10_38_51.stream.ntk',1)
data = load_h5_data({'../proc/Trace_id1588_2014-04-10T11_10_38_51.stream.h5'});


for i=1:length(fileNames)
    
    fileNameMean = sprintf('wf_mean_%d', i);
    if ~exist(fullfile(dirNameSave, [fileNameMean,'.mat']),'file');
        
        % get ts
        neur = file.load_single_var(dirName,fileNames(i).name);
        ts = double(round(2e4*neur.ts));
        if length(ts) > spkN
            ts = ts(1:spkN);
        end
        
        [wf]  = extractWaveformsFromH5(data{1},ts);
        wfMean = squeeze(mean(wf,1));
        
        fileName = sprintf('wf_%d', i);
        save(fullfile(dirNameSave, fileName), 'wf');
        
        fileNameMean = sprintf('wf_mean_%d', i);
        save(fullfile(dirNameSave, fileNameMean), 'wfMean');
        
    end
    i
end


%% plot footprints in groups around center of fp
elsN = 7;
h=figure, hold on
plot(ntkData.x,ntkData.y,'s','markerfacecolor',0.8*ones(1,3),...
    'markeredgecolor',0.8*ones(1,3),'markersize',15);
axis equal
cMap = plot.colormap_optimal_colors(length(fileNames));
hP = {};
for i=1:length(fileNames)
    
    fileNameMean = sprintf('wf_mean_%d', i);
    load(fullfile(dirNameSave, fileNameMean));
    
    p2pA = max(wfMean,[],1)-min(wfMean,[],1);
    
    [Y, I] = sort(p2pA,'descend');
    
    pts1 = [ntkData.x(I(1))' ntkData.y(I(1))'];
    pts2 = [ntkData.x' ntkData.y'];
    
    
    [elDist,idxEls] = geometry.find_closest_els_to_ctr_el(pts1, pts2, elsN);
    
    idxDist = find(elDist<20); idxEls = idxEls(idxDist);
    
    
    [ ppAmps hP{i}] = plot_footprints_simple([ ntkData.x(idxEls)' ...
        ntkData.y(idxEls)'], wfMean(:,idxEls)', ...
        'input_templates','hide_els_plot','plot_color',cMap(i,:));%,'label', m.elNo(validIdx)
    axis equal
    
    
    shg
    %     choice = input('keep? [y/n]', 's');
    %     if choice =='n'
    %         set(hP{i},'Visible','off')
    %     end
end
axis equal

%% plot footprints random els - full fp
elsN = 107;
h=figure, hold on
plot(ntkData.x,ntkData.y,'s','markerfacecolor',0.8*ones(1,3),...
    'markeredgecolor',0.8*ones(1,3),'markersize',10);
axis equal
cMap = plot.colormap_optimal_colors(length(fileNames));
hP = {};

randSel = randi(length(fileNames),[1 3]);

for i=1:length(randSel)
    
    fileNameMean = sprintf('wf_mean_%d', randSel(i));
    load(fullfile(dirNameSave, fileNameMean));
    
    fileName
    p2pA = max(wfMean,[],1)-min(wfMean,[],1);
    
    [Y, I] = sort(p2pA,'descend');
    
    pts1 = [ntkData.x(I(1))' ntkData.y(I(1))'];
    pts2 = [ntkData.x' ntkData.y'];
    
%     idxEls = 1:length(ntkData.x);
        [elDist,idxEls] = geometry.find_closest_els_to_ctr_el(pts1, pts2, elsN);
    
        %idxDist = find(elDist<20); idxEls = idxEls(idxDist);
    
    
    [ ppAmps hP{randSel(i)}] = plot_footprints_simple([ ntkData.x(idxEls)' ...
        ntkData.y(idxEls)'], wfMean(:,idxEls)', ...
        'input_templates','hide_els_plot','plot_color',cMap(randSel(i),:),...
        'line_width', 2);%,'label', m.elNo(validIdx)
    axis equal
    
    
    shg
    %     choice = input('keep? [y/n]', 's');
    %     if choice =='n'
    %         set(hP{randSel(i)},'Visible','off')
    %     end
end
axis equal

strNums = '';
for i = 1:length(randSel)
    strNums = strcat(strNums,sprintf('%d', randSel(i)));
    if i<length(randSel)
        strNums = strcat(strNums,'_');
    end
end
axis equal
figs.scale(h,40,100)

titleName = sprintf('%s in T11_10_38_51 from %s', strNums,  get_dir_date);
fileName = strrep(titleName,' ','_');
title_no_interpreter(titleName );       
dirNameFig = '../figs/some_example_footprints/';
mkdir(dirNameFig);
figs.save_plot_to_file(dirNameFig, fileName, 'fig'  )
figs.save_for_pub({dirNameFig,fileName});


%% plot circles at fp centers
elsN = 50;
h=figure, hold on
plot(ntkData.x,ntkData.y,'s','markerfacecolor',0.8*ones(1,3),...
    'markeredgecolor',0.8*ones(1,3),'markersize',10);
axis equal
cMap = plot.colormap_optimal_colors(length(fileNames));
hP = {};

randSel = 1:length(fileNames)%randi(length(fileNames),[1 3]);

for i=1:length(randSel)
    
    fileNameMean = sprintf('wf_mean_%d', randSel(i));
    load(fullfile(dirNameSave, fileNameMean));
    
    fileName
    p2pA = max(wfMean,[],1)-min(wfMean,[],1);
    
    [Y, I] = sort(p2pA,'descend');
    
    pts1 = [ntkData.x(I(1))' ntkData.y(I(1))'];
    pts2 = [ntkData.x' ntkData.y'];
    
    %     idxEls = 1:length(ntkData.x);
    [elDist,idxEls] = geometry.find_closest_els_to_ctr_el(pts1, pts2, elsN);
    
    %idxDist = find(elDist<20); idxEls = idxEls(idxDist);
    
    
%     [ ppAmps hP{randSel(i)}] = plot_footprints_simple([ ntkData.x(idxEls)' ...
%         ntkData.y(idxEls)'], wfMean(:,idxEls)', ...
%         'input_templates','hide_els_plot','plot_color',cMap(randSel(i),:),...
%         'line_width', 2);%,'label', m.elNo(validIdx)
    axis equal
    coords.x = pts2(:,1);
    coords.y = pts2(:,2);
    [ctrMass amps ]= footprint.find_center_of_mass_v2(wfMean', coords);
%     plot(ctrMass.x,ctrMass.y,'ok','markersize',15,'markerfacecolor',cMap(randSel(i),:))
    jitterAmt = 2*(rand(1,2)-0.5)*5;
    
    maxAmp = max(amps);
    A = 2*sqrt(maxAmp/pi())/4;
    plot.circle2(ctrMass.x+jitterAmt(1), ctrMass.y+jitterAmt(2), A, 'EdgeColor',...
        cMap(randSel(i),:), 'LineWidth', 3); %20*max(amps)/1000
    shg 
    %     choice = input('keep? [y/n]', 's');
    %     if choice =='n'
    %         set(hP{randSel(i)},'Visible','off')
    %     end
end
axis equal
figs.reverse_y_axis

strNums = '';
for i = 1:length(randSel)
    strNums = strcat(strNums,sprintf('%d', randSel(i)));
    if i<length(randSel)
        strNums = strcat(strNums,'_');
    end
end
axis equal
figs.scale(h,40,100)
%%
titleName = sprintf('%s in T11_10_38_51 from %s', strNums,  get_dir_date);
fileName = strrep(titleName,' ','_');
title_no_interpreter(titleName );       
dirNameFig = '../figs/some_example_footprints/';
mkdir(dirNameFig);
figs.save_plot_to_file(dirNameFig, fileName, 'fig'  )
figs.save_for_pub({dirNameFig,fileName});