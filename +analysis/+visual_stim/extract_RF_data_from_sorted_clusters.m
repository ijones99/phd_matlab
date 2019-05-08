function [profDataOut idxGoodFiles selClusterNums  rfCenterCoords] = ...
    extract_RF_data_from_sorted_clusters(runNo, configIdx, R, frameno, varargin)
% [profDataOut idxGoodFiles selClusterNums  rfCenterCoords] = ...
%     extract_RF_data_from_sorted_clusters(runNo, configIdx, R, frameno)

debug = 0;
numSquaresOnEdge=12;
savePlots =1;
idxGoodFiles = [];
doPrompt = 1;
% directories
def = dirdefs();
expName = get_dir_date;
doAutoSelect = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'idxGoodFiles')
            idxGoodFiles = varargin{i+1};
        elseif strcmp( varargin{i}, 'no_prompt')
            doPrompt  = 0;
        elseif strcmp( varargin{i}, 'no_plot_save')
            savePlots =0;
        elseif strcmp( varargin{i}, 'auto_sel')
            doAutoSelect =1;
        end
    end
end

%% get list of neurons found automatically (white noise)
configColumn = runNo; 
[tsMatrixAuto ] = spiketrains.extract_single_neur_spiketrains_from_felix_sorter_results(...
    R, configColumn, configIdx);

load white_noise_frames.mat

%% select good neurons


if ~iscell(frameno)
   framenoNew = {frameno}; 
   clear frameno;
   frameno = framenoNew;
   clear framenoNew;
   
end

profData = {};



if isempty(idxGoodFiles)
   
    for iFile = 1:length(tsMatrixAuto)
        try
            [profData{iFile}.staFrames profData{iFile}.staTemporalPlot ...
                profData{iFile}.plotInfo profData{iFile}.bestSTAInd h] =...
                ifunc.sta.make_sta( tsMatrixAuto(iFile).st{1}, ...
                white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
                frameno{configIdx},'do_print');
            if doPrompt
                choice = input('Keep (k)? >> ','s');
            elseif doAutoSelect
                currIm = all2.profData{4}.staFrames(:,:,all2.profData{4}.bestSTAInd);
                meanStdX = mean(std(currIm));
                if sum(find(currIm>3*meanStdX)) | sum(find(currIm<3*meanStdX))
                    choice = 'k';
                end
            else
                choice = 'k';
            end
            if strcmp(choice, 'k')
                idxGoodFiles(end+1) = iFile;
                
            end
        catch
            profData{iFile}.staFrames=[];
            profData{iFile}.staTemporalPlot=[];
            profData{iFile}.plotInfo=[];
            profData{iFile}.bestSTAInd=[];
            warning('Too few spikes')
        end
        close all
        iFile
    end
else
    
    
    for iFile = 1:length(tsMatrixAuto)
        try
            [profData{iFile}.staFrames profData{iFile}.staTemporalPlot ...
                profData{iFile}.plotInfo profData{iFile}.bestSTAInd h] =...
                ifunc.sta.make_sta( tsMatrixAuto(iFile).st{1}, ...
                white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
                frameno{configIdx});,'do_print'
            
        catch
            profData{iFile}.staFrames=[];
            profData{iFile}.staTemporalPlot=[];
            profData{iFile}.plotInfo=[];
            profData{iFile}.bestSTAInd=[];
            warning('Too few spikes')
        end
        close all
        iFile
    end
    
end

% save('idxGoodFiles', 'idxGoodFiles')
% save('profData_allsorted', 'profData')

%% look for RFs
% add best im field to profData
for i=1:length(profData), profData{i}.bestSTAIm =profData{i}.staFrames(:,:,profData{i}.bestSTAInd); end
% look for duplicates in RFs
thresholdVal = 0.80;
fieldName = 'bestSTAIm';
[matchingList outputMat] = im.look_for_duplicate_images(profData, fieldName, thresholdVal);
% apply to idx
idxRem = find(ismember(idxGoodFiles, matchingList(:,2)));
idxGoodFiles(idxRem) = [];

%% Put unique cell RFs into matrix
% 
idxEmptyFile = [];

for iFileSel = 1:length(profData)
        
    profData{iFileSel}.clusNum = tsMatrixAuto(iFileSel).clus_num;
    profData{iFileSel}.staIm = profData{iFileSel}.staFrames(:,:,profData{iFileSel}.bestSTAInd);
    profData{iFileSel}.staImAdj = beamer.beamer2array_mat_adjustment(profData{iFileSel}.staIm);
    iFileSel;
    
end

%% Find centers
% "goodFiles" are those with visible and clean RFs


for i = 1:length(idxGoodFiles)
    [xFitPercent yFitPercent zInterp fitData zInterpMask] = fit.find_rf_center_by_fitting_gaussian(...
        profData{idxGoodFiles(i)}.staImAdj,'mask_size_um',100);
    profData{idxGoodFiles(i)}.rfRelCtr = [round(xFitPercent*900/2) round(yFitPercent*900/2)]
    profData{idxGoodFiles(i)}.staImInterp=zInterp;
    profData{idxGoodFiles(i)}.staImInterpMask=zInterpMask;
    profData{idxGoodFiles(i)}.fit_data = fitData;
    fileName = sprintf('%d_RF_localization',profData{idxGoodFiles(i)}.clusNum);
    plotDir = sprintf('../Figs/Visual_Stim/%d/',profData{idxGoodFiles(i)}.clusNum);
    title(sprintf('Cluster %d Receptive Field', profData{idxGoodFiles(i)}.clusNum));

    if savePlots
        save.save_plot_to_file(plotDir, fileName, 'fig');
        save.save_plot_to_file(plotDir, fileName, 'eps');
    else
        pause(0.1)
    end
end

selClusterNums = [];
rfCenterCoords=[];
profDataOut = {};
for i =1:length(idxGoodFiles)
    selClusterNums(i) = profData{idxGoodFiles(i)}.clusNum;
    rfCenterCoords(i,1) = profData{idxGoodFiles(i)}.rfRelCtr(1);
    rfCenterCoords(i,2) = profData{idxGoodFiles(i)}.rfRelCtr(2);
    profDataOut(i) = profData(idxGoodFiles(i));
end
end

