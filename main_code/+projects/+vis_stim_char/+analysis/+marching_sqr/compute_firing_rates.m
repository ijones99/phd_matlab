function dataOut = compute_firing_rates(dataOut)
% dataOut = COMPUTE_FIRING_RATES(dataOut)

% settings
doPlot = 0;
minLatencyFR = 0;

% load settings file
load settings/stimFrameInfo_marchingSqr.mat

% idx for all segments
idxON = 1:2:length(stimFrameInfo.pos)*2;
idxOFF = idxON+1;

% idx sorted
posUnique = unique(stimFrameInfo.pos(1:end/2,:));

for iClus = 1:length(dataOut.clus)
    
    dataOut = init_struct(dataOut, iClus, posUnique)
    
    for iPos = 1:length(posUnique)
        % create rows of mean firing rate at each position:
        %[position x mean firing rate over time]
        
        [idxCurrPos, cols,vals]= find(stimFrameInfo.pos==posUnique(iPos));
        % ON direction 1
        [firingRate edges] = get_fr(dataOut, iClus, idxON, idxCurrPos(1:5));
        dataOut.direc1{iClus}.on.mean_fr(iPos,:) = firingRate;
        
        % ON direction 2
        [firingRate edges] = get_fr(dataOut, iClus, idxON, idxCurrPos(6:10));
        dataOut.direc2{iClus}.on.mean_fr(iPos,:) = firingRate;
        
        % OFF direction 1
        [firingRate edges] = get_fr(dataOut, iClus, idxOFF, idxCurrPos(1:5));
        dataOut.direc1{iClus}.off.mean_fr(iPos,:) = firingRate;
        
        % OFF direction 2
        [firingRate edges] = get_fr(dataOut, iClus, idxOFF, idxCurrPos(6:10));
        dataOut.direc2{iClus}.off.mean_fr(iPos,:)= firingRate;
        
    end
       
    % mean peak fr per position.
    [dataOut.direc1{iClus}.on.peak_mean_fr, idxPrefPos] = max(dataOut.direc1{iClus}.on.mean_fr,[],2);
    dataOut.direc1{iClus}.on.idx_pref_pos = idxPrefPos;
    [dataOut.direc2{iClus}.on.peak_mean_fr, idxPrefPos] = max(dataOut.direc2{iClus}.on.mean_fr,[],2);
    dataOut.direc2{iClus}.on.idx_pref_pos = idxPrefPos;
    [dataOut.direc1{iClus}.off.peak_mean_fr, idxPrefPos]  = max(dataOut.direc1{iClus}.off.mean_fr,[],2);
    dataOut.direc1{iClus}.off.idx_pref_pos = idxPrefPos;
    [dataOut.direc2{iClus}.off.peak_mean_fr, idxPrefPos] = max(dataOut.direc2{iClus}.off.mean_fr,[],2);
    dataOut.direc2{iClus}.off.idx_pref_pos = idxPrefPos;
end

dataOut.edges = edges;

end

function dataOut = init_struct(dataOut, iClus, posUnique)

% init fields
dataOut.direc1{iClus}.on.mean_fr = nan( length(posUnique), 41);
dataOut.direc2{iClus}.on.mean_fr = nan( length(posUnique), 41);
dataOut.direc1{iClus}.off.mean_fr = nan( length(posUnique), 41);
dataOut.direc2{iClus}.off.mean_fr = nan( length(posUnique), 41);

% init pos
dataOut.pos_unique = posUnique;


end

function [firingRate edges] = get_fr(dataOut, iClus, idxONorOFF, idxCurrPos)
% constants
sweepDur_samp = 2;
startStopTime = [0 sweepDur_samp];
integWinTime_sec = 0.05;

segsCurr = dataOut.segmentsAdj{iClus}(idxONorOFF(idxCurrPos));
[firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
    segsCurr,startStopTime*2e4,'bin_width', integWinTime_sec*2e4);

end