
chunkSize = 2e4*60*4;
ntk=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
[ntk2_1 ntk]=ntk_load(ntk, chunkSize, 'images_v1');
%% Data 1
nChannel = 10;
X = ntk2_1.sig;
samplesPerSecond = 20000;
name = 'Config1';
epos = [ntk2_1.x' ntk2_1.y'];
enrs = ntk2_1.channel_nr;

% Build one Data Source for First Configuration:
DS1 = mysort.ds.Matrix(X, samplesPerSecond, name, epos, enrs);
clusterNo = 100;
inds = find(SC(1).gdf_merged(:,1)'==clusterNo);

nSpikes = 1000;
spikeTimes = randi(9000, nSpikes) + 100;
nNeurons = 8;
spikeNeuronIDs = randi(nNeurons, nSpikes);
cutLeft = 10;
cutLength = 40;
gdf = [spikeNeuronIDs(:) spikeTimes(:)];
SC1 = mysort.spiketrain.SpikeSortingContainer('TestSorting', gdf, ...
        'wfDataSource', DS1,...
        'templateCutLeft', cutLeft,...
        'templateCutLength', cutLength);
%%
SCm = mysort.spiketrain.SpikeSortingContainer('TestSorting', gdf, ...
        'wfDataSource', mea1,...
        'templateCutLeft', cutLeft,...
        'templateCutLength', cutLength);
%%
    
chunkSize = 2e4*60*4;
ntk=initialize_ntkstruct(flist{3},'hpf', 500, 'lpf', 3000);
[ntk2_2 ntk]=ntk_load(ntk, chunkSize, 'images_v1');
%% Data 2
nChannel = 10;
X = ntk2_2.sig;
samplesPerSecond = 20000;
name = 'Config1';
epos = [ntk2_2.x' ntk2_2.y'];
enrs = ntk2_2.channel_nr;

DS2 = mysort.ds.Matrix(X, samplesPerSecond, name, epos, enrs);
nSpikes = 1000;
spikeTimes = randi(9000, nSpikes) + 100;
nNeurons = 8;
spikeNeuronIDs = randi(nNeurons, nSpikes);
cutLeft = 10;
cutLength = 40;
gdf = [spikeNeuronIDs(:) spikeTimes(:)];
SC2 = mysort.spiketrain.SpikeSortingContainer('TestSorting', gdf, ...
        'wfDataSource', DS2,...
        'templateCutLeft', cutLeft,...
        'templateCutLength', cutLength);
    
%% Build Spike Sorting Container
TL1 = SC1.getTemplateList();
TL2 = SC2.getTemplateList();
TLmerged = TL1(1).merge(TL2(1));

mysort.plot.templates2D(TLmerged.waveforms, TLmerged.MultiElectrode.electrodePositions, 20, 0)
hold on
mysort.plot.templates2D(TL1(1).waveforms, TL1(1).MultiElectrode.electrodePositions, 20, 0, 'ah', gca, 'IDs', 2)
TL1(1).MultiElectrode.electrodeNumbers
TL2(1).MultiElectrode.electrodeNumbers
TLmerged.MultiElectrode.electrodeNumbers
%% Loop over SC
TLcell = {};
SCcell = {};
cutLeft = 15; cutLength = 45;
for i=1:5%length(SC)
    
    dataSource = mysort.mea.CMOSMEA(strrep(flist{i+1},'ntk','h5'), 'useFilter', 0, 'name', 'Raw');
    
    SCcell{i} = mysort.spiketrain.SpikeSortingContainer('TestSorting', ...
        SC(i).gdf_merged , ...
        'wfDataSource', dataSource ,...
        'templateCutLeft', cutLeft,...
        'templateCutLength', cutLength,'nMaxSpikesForTemplateCalc', 100);
    
    TLcell{i} =     SCcell{i}.getTemplateList();
    
end

%% test merging 
TLmerged = TLcell{2}(3).merge(TLcell{4}(3));
% plot merged
mysort.plot.templates2D(TLmerged.waveforms, TLmerged.MultiElectrode.electrodePositions, 1000, 0)

%%
TLm = SCm.getTemplateList

%% plot as a test
i=2
k = 3
mysort.plot.templates2D(TLcell{i}(k).waveforms, TLcell{i}(k).MultiElectrode.electrodePositions, 1000, 0)

%% For each Neuron, get Waveforms
%% convert to hdf


mysort.mea.convertNTK2HDF(flist(2:end),'prefilter', 1);


%% load all h5 files
for i=1:length(flist)
    h5FileName = strrep(flist{i},'ntk','h5');
    mea1{i} = mysort.mea.CMOSMEA(h5FileName, 'useFilter', 0, 'name', 'Raw');
    fprintf('Loading...%3.0f percent done.\n', i/length(flist)*100)
end

% concatenate datastreams
neuroRouting = load('elsToScanSort1Cell26.nrconfig.mat');
staticElNumbers = neuroRouting.configList(1).selectedElectrodes;

% concatenate data
concatData = single([]);
dataChunkParts = [];
for i=1:length(flist)
    % find inds for sel channels
    [a b] = multifind(mea1{i}.getAllSessionsMultiElectrodes.electrodeNumbers, staticElNumbers);
    % inds for data
    dataInds = a(b)';
    if i==1
        concatData = single(mea1{i}.getData(:,dataInds));
    else
        concatData = [concatData; single(mea1{i}.getData(:,dataInds))];
    end
    dataChunkParts(i) = size(concatData,1);
    fprintf('Progress %3f\n', i/length(flist));
end
save loadChData.mat concatData dataChunkParts
%% do limited spike sorting (~5els)

nSamplesPerSecond = 2e4;
DS = mysort.ds.Matrix(concatData, nSamplesPerSecond, 'Concat Data');
% % Set the dead-time of the spike detector to the length of the spikes
% P.spikeDetection.minDist = size(T1,1);   
% % Set the time in which multiple detection on different channels are merged
% % into one spike to the length of the templates
% P.spikeDetection.mergeSpikesMaxDist = size(T1,1); 
 P.botm.run = 1;                          % activate botm sorting
%% spikesort all configs
tmpDataPath = 'TestSorting';
[S P] = mysort.sorters.sort(DS, tmpDataPath,'TestSort');
clusterSorting = [S.clusteringMerged.ids(:) round(S.clusteringMatched.ts(:))];
mysort.plot.SliderDataAxes(mea1{1})
%% plot waveforms
clusterNo = 7;
% gdfInds = find(clusterSorting(:,1)==clusterNo);
% spikeTimes = clusterSorting(gdfInds,:);
spikeTimes = clusterSorting;
figure;
ah = axes; hold on
for i=2:length(mea1)
    if i==1
        selSpikeTimes = spikeTimes(find(spikeTimes(:,2)<dataChunkParts(i)));
    else
        selSpikeTimes = spikeTimes(find(and(spikeTimes(:,2)>dataChunkParts(i-1), spikeTimes(:,2)<dataChunkParts(i))),:);
        selSpikeTimes(:,2) = selSpikeTimes(:,2)-dataChunkParts(i-1);
    end
    SSC = mysort.spiketrain.SpikeSortingContainer('ClusterSorting', selSpikeTimes, 'wfDataSource', mea1{i}, 'nMaxSpikesForTemplateCalc' , 250);
    TL = SSC.getTemplateList();
    for k=clusterNo-1%:length(TL)
        mysort.plot.templates2D(TL(k).waveforms, TL(k).MultiElectrode.electrodePositions, 10000, 0, 'ah', ah, 'IDs', TL(k).name)
    end
    
    if 0 %~isempty(selSpikeTimes)
        chNum = mea1{i}.getChannelNr;
        %         waveForms = mea1{i}.getWaveform(selSpikeTimes, 15,45,[1:80]);
        
        waveForms = extractWaveformsFromH5(mea1{i}, selSpikeTimes);
        waveForms = permute(waveForms,[1 3 2]);
        size(waveForms)
        %% plot templates
        elPositionXY = mea1{i}.MultiElectrode.electrodePositions;
        waveform = waveForms;
        elNumber = mea1{i}.MultiElectrode.electrodeNumbers;
        [h1 h2] = plot_footprints_simple( elPositionXY, waveform, elNumber, ...
            'plot_color',rand(1,3),'hide_els_plot');
        % figure, mysort.plot.waveforms2D(permute(waveform,[2 3 1]), elPositionXY,'plotMedian',1, ...
        %     'maxWaveforms', 400)
        
        i
        
    end
    drawnow
end
legend(num2str([clusterNo-1]'));
