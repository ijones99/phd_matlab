%% refFileCtrLoc
runNo=input('run no >> ');
framenosToLoad = input('idx for framenos to load (usually = 1 for wn_checkerboard) >> ');
% PATH INFO
pathDef = dirdefs();
expName = get_dir_date;

% create refFileCtrLoc.mat
refFileCtrLoc = {};
% R_num
Rall = load(sprintf('/net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut/%s_resultsForIan',expName));
refFileCtrLoc.R_num = 1:length(Rall.R);
configColumn = runNo; configIdx= 1;

% flist
load(fullfile(pathDef.dataIn,expName,'configurations'))
refFileCtrLoc.flist = configs(1).flist;

% load framenos
frameno = analysis.visual_stim.load_frameno
stimChangeTs = analysis.visual_stim.load_stim_change_ts;

% spots_num
load wn_1
numSpots = input('Number of spots >> ');
numInitStim = input('Number of init stim >> ');
spotFileIdx = [numInitStim+1:numInitStim+1+numSpots-1];

stimNames = {'wn_checkerboard', 'moving_bars', 'marching_sqr', 'spots', ...
    'spots_with_moving_grating_background', 'flashing_sqr'};

for i=1:length(stimNames)
   fprintf('%d) %s\n', i, stimNames{i}); 
end
fprintf('\nExample: [1 2 3 repmat([4 5], 1, 23)] \n\n')
stimNamesIdx = input('Enter idx for stim names >> ');
refFileCtrLoc.stim_names = stimNames(stimNamesIdx)'

spotCtrIdx = [1:numSpots];
refFileCtrLoc.spots_num = [ nan(1,length(refFileCtrLoc.flist ))];
refFileCtrLoc.spots_num(spotFileIdx) = sort(repmat(spotCtrIdx,1,1));

% fileCtrXY 
refFileCtrLoc.file_ctr_xy = nan(length(refFileCtrLoc.spots_num),2);
refFileCtrLoc.file_ctr_xy(spotFileIdx,:) = ...
    wn.rfCenterCoords(refFileCtrLoc.spots_num(find(not(isnan(refFileCtrLoc.spots_num)))),:)

printout.struct_to_commandline(refFileCtrLoc)

save('refFileCtrLoc', 'refFileCtrLoc')

%% create refClusCtrLoc

load frameno_run_01
configIdx=1;
framenoWNIdx=framenosToLoad;

[all.profData all.idxGoodFiles all.selClusterNums  all.rfCenterCoords] = ...
    analysis.visual_stim.extract_RF_data_from_sorted_clusters(runNo, configIdx, Rall.R(framenoWNIdx), frameno(framenoWNIdx));

for i =1:length(all.profData)
    fprintf('%d) Cluster %d: move [%d %d]\n', i, all.selClusterNums(i),  ...
        all.rfCenterCoords(i,1), all.rfCenterCoords(i,2));
%     progress_info(i,length(all.idxGoodFiles));
end

wnFileName = ['all_', num2str(runNo)];
save(wnFileName, 'all');
% create var
refClusCtrLoc = [];
refClusCtrLoc.clus_no = all.selClusterNums';
refClusCtrLoc.RF_ctr_xy = all.rfCenterCoords
save('refClusCtrLoc','refClusCtrLoc')

printout.struct_to_commandline(refClusCtrLoc)

%% SPOTS ONLY: compare center of recorded file with rf centers found by clustering
thresholdDist = 18;
spotsFileIdx = [numInitStim+1:1:length(refFileCtrLoc.file_ctr_xy)-1];
[matchList allCombos] = geometry.match_closest_points_in_two_sets(...
    refClusCtrLoc.RF_ctr_xy, refFileCtrLoc.file_ctr_xy(spotsFileIdx,:), thresholdDist,...
    'lim_to_closest_match');
whos matchList

%% SPOTS ONLY: create refClusInfo
refClusInfo = [];
refClusInfo.clus_no = refClusCtrLoc.clus_no(matchList(:,1));
refClusInfo.R_idx = refFileCtrLoc.R_num(spotsFileIdx(matchList(:,2)));
refClusInfo.flist = refFileCtrLoc.flist(refClusInfo.R_idx );
refClusInfo.clus_ctr_xy = refClusCtrLoc.RF_ctr_xy(matchList(:,1),:);
refClusInfo.file_ctr_xy = refFileCtrLoc.file_ctr_xy(spotsFileIdx(matchList(:,2)),:);
save 'refClusInfo' 'refClusInfo'

%% load all vars
load refFileCtrLoc
load refClusInfo
load wn_1
load all_1
load refClusInfo
load stimChangeTsAll