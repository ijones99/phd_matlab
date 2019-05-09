function [Rcomp  = compare_gdf_spiketrains(expName, runNo)
error('invalid function.')
% SETTINGS
timeLimMins = 2;
minNumSpikes = 50;


def = dirdefs();

Rall = load(sprintf('/net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut/%s_resultsForIan',expName));
Rwn = load(fullfile(def.sortingOut, 'wn_checkerboard_during_exp', sprintf('%s_resultsForIan.mat', expName)));


% use alignGDFs program
gdf1 = Rall.R{1,runNo};
gdf2 = Rwn.R{1};

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

idxSuffSpikes = find(numSpikes>minNumSpikes)

idxKeep = intersect(idxMatch, idxSuffSpikes);

Rcomp.GtPercent = 100*Rcomp.nTP./Rcomp.nSP1; % Common st over ground truth (st1) 
Rcomp.DetPercent = 100*Rcomp.nTP./Rcomp.nDetected; % Common st over detected (in st2)

% Spks = spikes found in st1
% Det = spikes found st2
% TP = matching time points



end