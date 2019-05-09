function [corrCoeffOut combosOut uniqueClus] = compare_footprints( waveforms1, waveforms2, xyCoords, varargin)
% [corrCoeffOut combosOut uniqueClus]  = COMPARE_FOOTPRINTS( waveforms1, waveforms2, xyCoords)
%
% Purpose: find match waveforms in waveforms1 to waveforms in waveforms2
%
% Args:
%   waveforms1: cell of waveforms from one sorting
%   waveforms2: cell of waveforms from another sorting
%   xyCoords: .x and .y for electrode configs (must be same for all)
%   
% Varargin:
%   matching_threshold
%   intragroup_comparison
%   threshold
%   radius_lim: compare signals within a radius of the peak of the
%   footprint
%   'times_rms'
%
% Out:
%   matchings: with same number of cells as waveforms1

corrCoeffThresh = 0.90;
matchThresh = 0.80; % decimal for minimal matching required for consideration
ctrMassMaxDist = 40; % in microns
interGpCompare = 0;
radiusLimit = inf;
timesNoise= 3;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'matching_threshold')
            matchThresh = varargin{i+1};
        elseif strcmp( varargin{i}, 'intragroup_comparison')
            interGpCompare = 1;
        elseif strcmp( varargin{i}, 'threshold')
            corrCoeffThresh = varargin{i+1};
        elseif strcmp( varargin{i}, 'radius_lim')
            radiusLimit = varargin{i+1};
        elseif strcmp( varargin{i}, 'times_rms')
            timesNoise = varargin{i+1};
        elseif strcmp( varargin{i}, 'min_dist')
            ctrMassMaxDist = varargin{i+1};
            
            
        end
    end
end

numWaveforms1 = length(waveforms1);
numWaveforms2 = length(waveforms2);

% get center of masses
for i=1:numWaveforms1
    try
        ctrMassWaveforms1(i) = footprint.find_center_of_mass(waveforms1{i}, xyCoords );
    catch
        ctrMassWaveforms1(i).x = [];ctrMassWaveforms1(i).y = [];
    end
end
for i=1:numWaveforms2
    try
        ctrMassWaveforms2(i) = footprint.find_center_of_mass(waveforms2{i}, xyCoords );
    catch
        ctrMassWaveforms2(i).x = [];ctrMassWaveforms2(i).y = [];
    end
end

% all combinations (for distances)
if interGpCompare
    combos = combnk(1:numWaveforms1,2);
else
    combos = combvec(1:numWaveforms1,1:numWaveforms2);
    combos = combos';
end

% threshold ctr-of-mass distances between combinations
c2cDist = [];
for i=1:size(combos,1)
    try
        c2cDist(i) = sqrt((ctrMassWaveforms1(combos(i,1)).x-ctrMassWaveforms1(combos(i,2)).x)^2+...
            (ctrMassWaveforms1(combos(i,1)).y-ctrMassWaveforms1(combos(i,2)).y)^2);
    catch
        c2cDist(i) = nan;
        
    end
end

% find idx above threshold
comboIdxOverThresh = find(c2cDist< ctrMassMaxDist );

combosOutInit = combos( comboIdxOverThresh,:);

% for idx above threshold ctr-of-mass distances, compare waveforms.
% Comparison is absolute value of summed difference of two waveforms 
% divided by summed p2p amplitudes for first footprint
corrCoeff = nan(length(comboIdxOverThresh),1);
for i=1:length(comboIdxOverThresh)
    try
%         diffRatio(i) = abs(sum(sum(waveforms1{combos(comboIdxOverThresh(i),1)}...
%             -waveforms2{combos(comboIdxOverThresh(i),2)}))/...
%         sum(sum(waveforms1{combos(comboIdxOverThresh(i),1)}...
%             +waveforms2{combos(comboIdxOverThresh(i),2)})));

            
                
            wf1 = waveforms1{combos(comboIdxOverThresh(i),1)}; % els are rows
            wf2 = waveforms2{combos(comboIdxOverThresh(i),2)};
            
            % get p2p
            wf1p2p = max(wf1,[],2)-min(wf1,[],2);
            wf2p2p = max(wf2,[],2)-min(wf2,[],2);
            
            % get mean rms
            wf1MeanRMS1 = mean(rms(wf1'));
            wf2MeanRMS2 = mean(rms(wf2'));
            
            % get above RMS
            idxAboveRMS1 = find(wf1p2p >= timesNoise*wf1MeanRMS1);
            idxAboveRMS2 = find(wf2p2p >= timesNoise*wf2MeanRMS2);
            idxCompare = union(idxAboveRMS1, idxAboveRMS2);
            % limit to specified radius from center
            if radiusLimit ~= Inf
               peakCtrLoc = ctrMassWaveforms1(combos(comboIdxOverThresh(i)));
               distFromCtr = geometry.get_distance_between_2_points(peakCtrLoc.x, peakCtrLoc.y,xyCoords.x,xyCoords.y);
               idxWithinLimRadius = find(distFromCtr<radiusLimit);
               idxCompare = intersect(idxAboveRMS1,idxWithinLimRadius);
            end
            
            corrCoeff(i) = corr2(  wf1(idxCompare,:),wf2(idxCompare,:)   );
         
    catch
       error('Fix calculation of coefficient.'); 
    end

end

idxAboveCoeffThresh = find(corrCoeff > corrCoeffThresh);

corrCoeffOut = corrCoeff(idxAboveCoeffThresh);
combosOut = combosOutInit(idxAboveCoeffThresh,:);

% find unique clusters
allClusNum = 1:length(waveforms1);
allInMatchingGp = unique(combosOut)';
allNotMatching = find(~ismember(allClusNum, allInMatchingGp));

matchingClus = unique(combosOut(:,1));
redundant = unique(combosOut(:,2));
matchingMinusRed = remove_values_from_matrix(matchingClus, redundant);

warning('may be shortcut calculation');

uniqueClus = sort([allNotMatching matchingMinusRed']);