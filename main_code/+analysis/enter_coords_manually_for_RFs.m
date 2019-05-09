function wnCheckBrdPosData = enter_coords_manually_for_RFs




runNo = input('Enter run no >> ');
flistName = sprintf('flist_wn_checkerboard_n_%02d',runNo);
flist = {}; eval(flistName);
suffixName = strrep(flistName,'flist', '');
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/')
dirNamePr = strcat('../analysed_data/',   flistFileNameID,'/05_Post_Spikesorting/')
mkdir(dirNamePr)
numSquaresOnEdge = [12 12];
iMaxTimeSTACalcTime = [20];
maxTimeSTACalcTime = 15;


%% get frameno info
close all
framenoName = strcat('frameno_', flistFileNameID,'.mat');
if ~exist(fullfile(dirNameFFile,framenoName))
    frameno = get_framenos(flist, 2e4*60*20);
    save(fullfile(dirNameFFile,framenoName),'frameno');
else
    load(fullfile(dirNameFFile,framenoName)); frameInd = single(frameno);
end

% get file names
% fileNames = dir(strcat(dirNameSt,'*.mat'));

load white_noise_frames.mat
edgePix = 12;
white_noise_frames = white_noise_frames(1:edgePix,1:edgePix,:);
dirSTA = strrep(strrep(dirNameSt,'analysed_data', 'Figs'),'03_Neuron_Selection/','');
mkdir(dirSTA)

%% get el pos
profData.flist = flist;
ntk2 = load_ntk2_data(profData.flist,1)
profData.elConfigCtrXY = [mean(ntk2.x) mean(ntk2.y)];



quitLoop = 'n';

while quitLoop ~= 'y'
    
    [fileNo fileNames] = file.select_file_name(dirNameSt,'*.mat');
    maxTimeSTACalcTime = iMaxTimeSTACalcTime;
    load(fullfile(dirNameSt, fileNames(fileNo).name));
    clusNoLoc(1) = strfind(fileNames(fileNo).name, 'n')+1;
    clusNoLoc(2)= strfind(fileNames(fileNo).name, '.mat')-1;
    profData.clusNo = str2num(fileNames(fileNo).name(clusNoLoc(1):clusNoLoc(2)));
    
    ctrElidxNoLoc(1) = strfind(fileNames(fileNo).name, 'st_')+3;
    ctrElidxNoLoc(2)= strfind(fileNames(fileNo).name, 'n')-1;
    profData.ctrElidx = str2num(fileNames(fileNo).name(ctrElidxNoLoc(1):ctrElidxNoLoc(2)));
    
    eval([  'spikeTimes = ',fileNames(fileNo).name(1:end-4),'.ts*2e4;']);
    spikeTimes(spikeTimes > maxTimeSTACalcTime*2e4*60) = [];
    profData.stSel = spikeTimes;
    
    [profData.staFrames profData.staTemporalPlot profData.plotInfo profData.bestSTAInd h] =...
        ifunc.sta.make_sta( profData.stSel, ...
        white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
        frameno)
    % title(sprintf('WN Checkerboard (cluster %d)',profData.clusNo));
    
    
    
    maxTimeSTACalcTime = iMaxTimeSTACalcTime;
    load(fullfile(dirNameSt, fileNames(fileNo).name));
    clusNoLoc(1) = strfind(fileNames(fileNo).name, 'n')+1;
    clusNoLoc(2)= strfind(fileNames(fileNo).name, '.mat')-1;
    profData.clusNo = str2num(fileNames(fileNo).name(clusNoLoc(1):clusNoLoc(2)));
%     fprintf('Clus # %d.\n',profData.clusNo )
    eval([  'spikeTimes = ',fileNames(fileNo).name(1:end-4),'.ts*2e4;']);
    spikeTimes(spikeTimes > maxTimeSTACalcTime*2e4*60) = [];
    profData.stSel = spikeTimes;
    
    profData.umToPx = 1.6;
    profData.squareSizeUm = 75;
    edgeLengthPx = profData.squareSizeUm*numSquaresOnEdge;
    % plot image
    % figure
    % gui.plot_hidens_els, hold on;
    profData.stimPlotLims{1} = [profData.elConfigCtrXY(1)-edgeLengthPx/2 profData.elConfigCtrXY(1)+edgeLengthPx/2];
    profData.stimPlotLims{2} = [profData.elConfigCtrXY(2)-edgeLengthPx/2 profData.elConfigCtrXY(2)+edgeLengthPx/2];
    staIm = profData.staFrames(:,:,profData.bestSTAInd);
    
    staImAdj = beamer.beamer2array_mat_adjustment(staIm);
    profData.staImAdjRGB = im.mat2rgb(staImAdj);
    % subimage(profData.stimPlotLims{1}, profData.stimPlotLims{2},profData.staImAdjRGB)
    
    % plot footprint
    % plot_footprints_simple([out.neurons{neurInd}.x' out.neurons{neurInd}.y'], ...
    %     out.neurons{neurInd}.template.data', ...
    %         'input_templates','hide_els_plot','format_for_neurorouter',...
    %         'plot_color','k', 'flip_templates_ud', 'flip_templates_lr','scale', 55, ...
    %         'line_width',2);
    
    plotDir = '../Figs/';
    % fileName = sprintf('%s_checkerboard_rf_%s', get_dir_date, strrep(strrep(fileNames(fileNo).name,'st_',''),'.mat',''));
    % % plot.plot_peak2peak_amplitudes(out.neurons{neurInd}.template.data', ...
    % %     out.neurons{neurInd}.x,out.neurons{neurInd}.y);
    % save.save_plot_to_file(plotDir, fileName, 'eps');
    % save.save_plot_to_file(plotDir, fileName, 'fig');
    
    
    
    % Select the center of the RF
    all_els=hidens_get_all_electrodes(2);
    % configNum = input('Enter config#');
    % configIndNum = configNum+1; %because file names start at 0;
    arrayCtrXY = [mean(unique(all_els.x)) mean(unique(all_els.y))];
    
    
    % junk = input('Ready to select center of recreptive field? [press enter]: ')
    
    
    relCtrLocation = input('Enter rel coords >> ');
%     profData.rfRelCtr.x = round(centerLocation(1)-mean(ntk2.x));
%     profData.rfRelCtr.y = round(mean(ntk2.y)-centerLocation(2));

    profData.rfRelCtr.x = relCtrLocation(1);
    profData.rfRelCtr.y = relCtrLocation(2);

    centerLocation(1) = profData.rfRelCtr.x + mean(ntk2.x);
    centerLocation(2) = mean(ntk2.y) - profData.rfRelCtr.y;

    
    profData.rfTrueCtr.x = centerLocation(1);
    profData.rfTrueCtr.y = centerLocation(2);
    
    
    fprintf('Move rel. to center of config: [%3.0f %3.0f]\n', ...
        profData.rfRelCtr.x,profData.rfRelCtr.y  );
    fprintf('Selected xy coord: [%5.0f %5.0f]\n', centerLocation(1), ...
        centerLocation(2))
    fprintf('File name: %s.\n', fileNames(fileNo).name);
    fprintf('file #: %d.\n',fileNo);
    wnCheckBrdRunNo ='';
    wnCheckBrdRunNo = runNo;%input('Enter stim run no to save (if you want to save) >> ');
    
    cellFileName = sprintf('run_%02d_cell_%dn%d', runNo, profData.ctrElidx, profData.clusNo);
    
    save(fullfile(dirNamePr, cellFileName), 'profData');
    
    if ~isempty(wnCheckBrdRunNo)
        wnCheckBrdPosDataFileName = sprintf('wnCheckBrdPosData_%02d.mat', wnCheckBrdRunNo);
        if exist(wnCheckBrdPosDataFileName,'file')
            load( wnCheckBrdPosDataFileName )
        else
            wnCheckBrdPosData = {};
        end
        % select flist
        %     flistFileNames = filenames.get_filenames('*ntk','../proc');
        [fileIdx flistFileNames] = filenames.select_flist_name();
        wnCheckBrdPosData{end+1}.flist{1} = ['../proc/',flistFileNames(fileIdx).name];
        wnCheckBrdPosData{end}.fileNo = fileIdx;
        wnCheckBrdPosData{end}.fileName = strrep(strrep(fileNames(fileNo).name,'st_',''),'.mat','');
        wnCheckBrdPosData{end}.rfAbsCtr = centerLocation;
        wnCheckBrdPosData{end}.rfRelCtr  = struct.xy2vec(profData.rfRelCtr);
        [wnCheckBrdPosData{end}.elIdxCtr wnCheckBrdPosData{end}.clusNo] = ...
            filenames.parse_cluster_name(wnCheckBrdPosData{end}.fileName);
        wnCheckBrdPosData{end}.runNo = wnCheckBrdRunNo;
        wnCheckBrdPosData{end}.stimType = 'wn_checkerboard';
        % save positional data
        save(wnCheckBrdPosDataFileName, 'wnCheckBrdPosData');
        
        %     h1 = figure; hold on, axis square
        %     imagesc(profData.staImAdjRGB),pause(0.1);
        neurName = strrep(strrep(fileNames(fileNo).name,'st_',''),'.mat','');
        fileName = sprintf('%s_best_frame_checkerboard_rf_%s', get_dir_date, ...
            strrep(strrep(fileNames(fileNo).name,'st_',''),'.mat',''));
        %     save.save_plot_to_file(plotDir, fileName, 'fig');
        % close(h1)
        %     fprintf('File saved.\n');
    end
    quitLoop = input('finished? [y/n] >> ','s');
    if isempty(quitLoop)
        quitLoop = 'n';
    end
end