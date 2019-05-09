function [out profData ] = get_receptive_fields(neurNames,runNo)



flistName = sprintf('flist_wn_checkerboard_n_%02d',runNo);
flist = {}; eval(flistName);
suffixName = strrep(flistName,'flist', '');
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/')

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
fileNames = dir(strcat(dirNameSt,'*.mat'));

load white_noise_frames.mat
edgePix = 12;
white_noise_frames = white_noise_frames(1:edgePix,1:edgePix,:);
dirSTA = strrep(strrep(dirNameSt,'analysed_data', 'Figs'),'03_Neuron_Selection/','');
mkdir(dirSTA)

%% get el pos
profData  = {};

ntk2 = load_ntk2_data(flist,1)

out = {};
iFile = 1;

for iFile = 1:length(neurNames)
    
    profData{iFile}.flist = flist;
    profData{iFile}.elConfigCtrXY = [mean(ntk2.x) mean(ntk2.y)];
    
    neurNameIn = ['st_', neurNames{iFile},'.mat'];
    fileNo = filenames.find_str_in_filenames_cell(neurNameIn,fileNames);
    
    maxTimeSTACalcTime = iMaxTimeSTACalcTime;
    load(fullfile(dirNameSt, fileNames(fileNo).name));
    clusNoLoc(1) = strfind(fileNames(fileNo).name, 'n')+1;
    clusNoLoc(2)= strfind(fileNames(fileNo).name, '.mat')-1;
    profData{iFile}.clusNo = str2num(fileNames(fileNo).name(clusNoLoc(1):clusNoLoc(2)));
    
    ctrElidxNoLoc(1) = strfind(fileNames(fileNo).name, 'st_')+3;
    ctrElidxNoLoc(2)= strfind(fileNames(fileNo).name, 'n')-1;
    profData{iFile}.ctrElidx = str2num(fileNames(fileNo).name(ctrElidxNoLoc(1):ctrElidxNoLoc(2)));
    
    eval([  'spikeTimes = ',fileNames(fileNo).name(1:end-4),'.ts*2e4;']);
    spikeTimes(spikeTimes > maxTimeSTACalcTime*2e4*60) = [];
    profData{iFile}.stSel = spikeTimes;
    
    [profData{iFile}.staFrames profData{iFile}.staTemporalPlot profData{iFile}.plotInfo profData{iFile}.bestSTAInd h] =...
        ifunc.sta.make_sta( profData{iFile}.stSel, ...
        white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
        frameno)
    % title(sprintf('WN Checkerboard (cluster %d)',profData{iFile}.clusNo));
 
    maxTimeSTACalcTime = iMaxTimeSTACalcTime;
    load(fullfile(dirNameSt, fileNames(fileNo).name));
    clusNoLoc(1) = strfind(fileNames(fileNo).name, 'n')+1;
    clusNoLoc(2)= strfind(fileNames(fileNo).name, '.mat')-1;
    profData{iFile}.clusNo = str2num(fileNames(fileNo).name(clusNoLoc(1):clusNoLoc(2)));
    %     fprintf('Clus # %d.\n',profData{iFile}.clusNo )
    eval([  'spikeTimes = ',fileNames(fileNo).name(1:end-4),'.ts*2e4;']);
    spikeTimes(spikeTimes > maxTimeSTACalcTime*2e4*60) = [];
    profData{iFile}.stSel = spikeTimes;
    
    profData{iFile}.umToPx = 1.6;
    profData{iFile}.squareSizeUm = 75;
    edgeLengthPx = profData{iFile}.squareSizeUm*numSquaresOnEdge;
    % plot image
    % figure
    % gui.plot_hidens_els, hold on;
    
    
    profData{iFile}.stimPlotLims{1} = [profData{iFile}.elConfigCtrXY(1)-edgeLengthPx/2 profData{iFile}.elConfigCtrXY(1)+edgeLengthPx/2];
    profData{iFile}.stimPlotLims{2} = [profData{iFile}.elConfigCtrXY(2)-edgeLengthPx/2 profData{iFile}.elConfigCtrXY(2)+edgeLengthPx/2];
    out{iFile}.staIm = profData{iFile}.staFrames(:,:,profData{iFile}.bestSTAInd);
    
    out{iFile}.staImAdj = beamer.beamer2array_mat_adjustment(out{iFile}.staIm);
    out{iFile}.fileName = sprintf('%dn%d', profData{iFile}.ctrElidx, profData{iFile}.clusNo);
    
    
  
    iFile = 1+iFile;
    
end