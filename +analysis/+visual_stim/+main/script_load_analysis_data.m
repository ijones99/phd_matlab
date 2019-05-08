expName = get_dir_date;
runNo = 1;
def = dirdefs();
% load frameno & data
framenosToLoad = [1:2];
pathDef = dirdefs();
expName = get_dir_date;

% configNo = input('Enter config no >> ');
configColumn = runNo; configIdx= 1;
doLoadFrameNo = 1;
% load data
load(fullfile(pathDef.dataIn,expName,'configurations'))

expName = get_dir_date;
Rall = load(sprintf('/net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut/%s_resultsForIan',expName));
% Rwn = load(fullfile(def.sortingOut, 'wn_checkerboard_during_exp', sprintf('%s_resultsForIan.mat', expName)));


%% load all vars
load refFileCtrLoc
load refClusCtrLoc
load wn_1
load all_1
load refClusInfo
