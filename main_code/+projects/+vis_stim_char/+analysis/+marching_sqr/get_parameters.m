function dataOut = get_parameters(dataOut)
% dataOut = COMPUTE_FIRING_RATES(dataOut)

% load settings file
load settings/stimFrameInfo_marchingSqr.mat

% idx for all segments
idxON = 1:2:length(stimFrameInfo.pos)*2;
idxOFF = idxON+1;

% idx sorted
posUnique = unique(stimFrameInfo.pos(1:end/2,:));

for iClus = 1:length(dataOut.clus)
    
    meanFrAllDirec = [dataOut.direc1{iClus}.on.peak_mean_fr'; ...
    dataOut.direc2{iClus}.on.peak_mean_fr'; ...
    dataOut.direc1{iClus}.off.peak_mean_fr'; ...
    dataOut.direc2{iClus}.off.peak_mean_fr'...
    ];
    
    [Y, I ] = max(meanFrAllDirec,[], 2);
    
    frON = max(Y(1:2));
    frOFF = max(Y(3:4));
    
    % bias index
    dataOut.biasIndex(iClus) = (frON-frOFF)/(frON+frOFF);
    
    % latency
    minLatencyFR = 10;
    [junk , idxMaxR] = max(Y);
    dataOut.latency(iClus) = response_params_calc.latency_simple(...
        meanFrAllDirec(idxMaxR,:), ...
        dataOut.edges,'fit_spline', 'first_peak','min_fr', minLatencyFR);
    
end

