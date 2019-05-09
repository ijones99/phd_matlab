% analyse flashing spots

% >>>>>>>> LIGHT STIMULI >>>>>>>>>>>>
% load parapin data
profileData.flist = {};
profileData.flist{1} = '../proc/Trace_id1586_2014-03-21T09_50_26_11.stream.ntk';
ntkOut = load_field_ntk(profileData.flist{1}, 'images.frameno');

% get stimulus timestamps
frChangeTS = get_stimulus_frame_change(ntkOut.images.frameno)';
% load spot sizes
clear Settings
load('stimParams_Flashing_Spots')
spotSizesUm = Settings.DOT_DIAMETERS(Settings.PRESENTATION_ORDER);

% >>>>>>>> RECORDED DATA >>>>>>>>>>>>
% get el numbers & inds
sortingEls = [];
wnCheckOut = load('checkerboard_n_01_g_01');
sortingEls = wnCheckOut.out.spikes.elidx;
clear wnCheckOut

%% spikesort
out = {};
sortGroupNumber= input('sorting group #: >> ');
sortingRunName = sprintf('flashing_spots_n_%02d',sortGroupNumber);disp(sortingRunName)
[spikes meaData dataChunkParts concatData] = load_and_spikesort_selected_els(profileData.flist,...
    sortingEls);  % 'force_file_conversion'
% get spike times for each config
%% put spike times into structure
spikeTimes = [spikes.assigns' round(2e4*spikes.spiketimes')];
ts = {};
for i=1:length(meaData)
    selSpikeTimeInds = extract_indices_within_range(spikeTimes(:,2), dataChunkParts(i), ...
        dataChunkParts(i+1));
    ts{i} = spikeTimes(selSpikeTimeInds,:);
    ts{i}(:,2) = ts{i}(:,2)-dataChunkParts(i);
end
out = add_field_to_structure(out,'ts', ts);

%% load h5 files only
meaData = mea1.load_mea1_data(profileData.flist);

%% take a look at sorting of the selected cluster to compare with ds cell found (no neurorouter)
outWNCheck = load('checkerboard_n_01_g_01');
splitmerge_tool(outWNCheck.out.spikes);

%% get all spiketimes
unique(out.ts{1}(:,1))
clusNo= input('cluster #s: >> ');

analData = {};
for iBrightness = 1:length(Settings.BRIGHTNESS)
    
    for iClus = 1:length(clusNo)
        neurTSInd = find(out.ts{1}(:,1)==clusNo(iClus))';
        analData{iClus}.selTs = ts{1}(neurTSInd,2)';
        
        % extract spikes from a given epoch
        analData{iClus}.spikeTrain ={};
        analData{iClus}.spikeTrainZ={};
        analData{iClus}.numSpikes = [];
        analData{iClus}.peakFiringRate = [];
        for i = 1:2:length(frChangeTS)
            [analData{iClus}.spikeTrain{end+1} analData{iClus}.spikeTrainZ{end+1}] = ...
                spiketrains.extract_epoch_from_spiketrain(analData{iClus}.selTs,frChangeTS(i),frChangeTS(i+1));
            analData{iClus}.numSpikes(end+1) = length(analData{iClus}.spikeTrain{end} );
            try
                analData{iClus}.peakFiringRate((i+1)/2) = 1/(min(diff(analData{iClus}.spikeTrain{end}))/2e4);
            catch
                analData{iClus}.peakFiringRate((i+1)/2) = 0;
            end
        end
        % get mean spiking rates
        analData{iClus}.stimDiamMeanResponsePeakFR = Settings.DOT_DIAMETERS';
        analData{iClus}.stimDiamMeanResponsePeakFR = Settings.DOT_DIAMETERS';
        for i=unique(Settings.FRAME_TABLE)
            sizeInd = find(Settings.PRESENTATION_ORDER==i);
            idxIncrease = length(Settings.PRESENTATION_ORDER)*(iBrightness-1);
            analData{iClus}.stimDiamMeanResponsePeakFR(i,2) = ...
                mean(analData{iClus}.peakFiringRate(sizeInd+idxIncrease));
            analData{iClus}.stimDiamMeanResponsePeakFR(i,2) = ...
                mean(analData{iClus}.numSpikes(sizeInd));
        end
        SettingsNew = Settings;
        %     SettingsNew = rmfield(SettingsNew,'varDotStimMtx');
        %     SettingsNew = rmfield(SettingsNew,'surrStimMtx');
        analData{iClus}.Settings = SettingsNew ;
        analData{iClus}.spikes = spikes;
        analData{iClus}.clusNo = clusNo(iClus);
        analData{iClus}.static_els = spikes.elidx;
        analData{iClus}.flist = profileData.flist{1};
        
    end
end
%% add info to profile file
checkerboardClusNo = input('Enter checkerboard cluster no: ');
fileName = dir(fullfile('../analysed_data/profiles/', sprintf('*checkerboard*%d*.mat', ...
    checkerboardClusNo)))
flashingDotsClusNo = input('Enter flashing dots cluster no: ');

profiles.save_to_profiles_file(fileName.name, 'flashing_spots', [], [], ...
    'add_struct_fields',analData{flashingDotsClusNo})

%% plotting
i = 1
figure,plot(analData{i}.stimDiamMeanResponsePeakFR(:,1),analData{i}.stimDiamMeanResponsePeakFR(:,2),'ko-'), hold on
plot(analData{i}.stimDiamMeanResponsePeakFR(:,1),analData{i}.stimDiamMeanResponsePeakFR(:,2)*6,'ro-')

