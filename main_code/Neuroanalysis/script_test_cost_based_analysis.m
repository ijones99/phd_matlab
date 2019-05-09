%make output struct

clear X
% Number of stimulus classes in experiment
X.M = 1;

% Number of sites in experiment. 
X.N = 1;

% Array of structures with recording site information

X.sites.label = {strcat(['Neuron ', strrep(fileNames(selNeurs).name,'_','-')])};
X.sites.recording_tag = {'episodic'};
X.sites.time_scale = 1;
X.sites.time_resolution = 1.0000e-04;
X.sites.si_unit = 'none';
X.sites.si_prefix = 1;

% trials
numTrials = length(selSpikes);
catLabels = {'orig-movie', ...
    'stat-med-surr', ...
    'dynamic-med-surr', ...
    'dynamic-med-surr-shuffled', ...
    'pix-surr-shuffled-75-percent'};
% catLabelsInds = [1*ones(1,5) 2*ones(1,5) 3*ones(1,5) 4*ones(1,5) 5*ones(1,5)];
numTrials = 15;
iNeur = 1;
for j=1:X.M
    for i=1:numTrials
        X.categories(j).trials(i).start_time = 0;
        X.categories(j).trials(i).end_time = 9.7649;
        X.categories(j).trials(i).Q = int32(length(selSpikes{iNeur}));
        X.categories(j).trials(i).list = selSpikes{iNeur};
        iNeur = iNeur+1;
    end
    X.categories(j).label = catLabels(j);
    X.categories(j).P = numTrials;
    X.categories(j).trials = X.categories(j).trials';
end
%% testing
% modify spiketrains
j=1, i=2, X.categories(j).trials(i).list = selSpikes{1}(1:round(end/2));
j=1, i=2, X.categories(j).trials(i).Q = length(selSpikes{1}(1:round(end/2)));

j=1, i=3, X.categories(j).trials(i).list = selSpikes{1}+3;

j=1, i=4, X.categories(j).trials(i).list = selSpikes{1}(1:round(end/2))+3;
j=1, i=4, X.categories(j).trials(i).Q = length(selSpikes{1}(1:round(end/2))+3);

