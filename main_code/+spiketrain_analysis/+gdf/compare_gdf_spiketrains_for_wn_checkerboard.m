function [Rcomp Rout] = compare_gdf_spiketrains_for_wn_checkerboard(expName, runNo, varargin)
%     [Rcomp Rout] = compare_gdf_spiketrains_for_wn_checkerboard(expName, runNo, varargin)
%
% varargin
%   'min_spike_num'
%   'min_common_to_gt_percent'


minNumSpikes = 0;
minCommonToGT = 100;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'min_spike_num')
            minNumSpikes = varargin{i+1};
        elseif strcmp( varargin{i}, 'min_common_to_gt_percent')
            minCommonToGT = varargin{i+1};
        end
    end
end

% SETTINGS
timeLimMins = 2;

def = dirdefs();

Rall = load(sprintf('/net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut/%s_resultsForIan',expName));
Rwn = load(fullfile(def.sortingOut, 'wn_checkerboard_during_exp', sprintf('%s_resultsForIan.mat', expName)));


% use alignGDFs program
gdf1 = Rwn.R{1};
gdf2 = Rall.R{1,runNo};


timeLim = 2e4*60*timeLimMins; % minutes

% apply max
I = find(gdf1(:,2)>timeLim,1,'first')-1;
gdf1cat = gdf1(1:I,:);
I = find(gdf2(:,2)>timeLim,1,'first')-1;
gdf2cat = gdf2(1:I,:);

Rcomp = mysort.spiketrain.alignGDFs(gdf1cat, gdf2cat, 10, 10, 10);
mysort.plot.printEvaluationTable(Rcomp,'ignoreEmptySorted', 0)

% valid matches: match was found
idxMatch = find(Rcomp.k2f>0);

% get num spikes
numSpikes = Rcomp.nSP1;

% filter by low number of spikes
idxSuffSpikes = find(numSpikes>minNumSpikes);

Rout.GtPercent = 100*Rcomp.nTP./Rcomp.nSP1; % Common st over ground truth (st1) 
Rout.DetPercent = 100*Rcomp.nTP./Rcomp.nDetected; % Common st over detected (in st2)

% For mysort.plot.printEvaluationTable(R, 'ignoreEmptySorted', 0);
% Spks = spikes found in st1
% Det = spikes found st2
% TP = matching time points

% filter by common st / ground truth
idxCommotToGt = find(Rout.GtPercent > minCommonToGT);

% idx to keep
Rout.idxKeep = intersect(intersect(idxMatch, idxSuffSpikes), idxCommotToGt);

% get cell names
for i=1:length(Rcomp.k2f)
    if Rcomp.k2f(i)>0
        Rout.U1(i) = Rcomp.St1IDs(i);
        Rout.U2(i) = Rcomp.St2IDs(Rcomp.k2f(i));
        Rout.U1idx(i) = i;
        Rout.U2idx(i) = Rcomp.k2f(i);
    else
        Rout.U1(i) = -1;
        Rout.U2(i) = -1;
        Rout.U1idx(i) = -1;
        Rout.U2idx(i) = Rcomp.k2f(i);
    end
end


end



