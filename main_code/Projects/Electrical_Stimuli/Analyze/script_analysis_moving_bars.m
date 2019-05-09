% analyse flashing spots

% >>>>>>>> LIGHT STIMULI >>>>>>>>>>>>
% load parapin data
profileData.flist = {};
profileData.flist{1} = '../proc/Trace_id1586_2014-03-21T09_50_26_6.stream.ntk';
out = {};
out = load_field_ntk(profileData.flist{1}, 'images.frameno');

% get stimulus timestamps
frChangeTS =get_stim_start_stop_ts2(out.images.frameno, 0.8)
% load spot sizes
clear Settings
load('stimParams_Moving_Bars')
% get el numbers & inds
sortingEls = [];
wnCheckOut = load('checkerboard_n_01_g_01');
sortingEls = wnCheckOut.out.spikes.elidx;
clear wnCheckOut
%% spikesort
sortGroupNumber= input('sorting group #: >> ');
sortingRunName = sprintf('moving_bars_n_%02d',sortGroupNumber);disp(sortingRunName)
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
out = add_field_to_structure(out,'spikes', spikes);
save(sortingRunName,'out')
%% load h5 files only
meaData = mea1.load_mea1_data(profileData.flist);

%% take a look at sorting of the selected cluster to compare with ds cell found (no neurorouter)
outWNCheck = load('checkerboard_n_01_g_01');
splitmerge_tool(outWNCheck.out.spikes);

%% get all spiketimes
unique(out.ts{1}(:,1))'
clusNo= input('cluster #s: >> ');

analData = {};

numParapinChanges = length(rgbBrightness)*length(barLengthPx)*length(movingBarSpeedPx)*...
    length(currDirections)*length(Settings.OFFSET_UM)*2;

for iClus = 1:length(clusNo)
    neurTSInd = find(out.ts{1}(:,1)==clusNo(iClus))';

    analData{iClus}.selTs = ts{1}(neurTSInd,2)';
    analData{iClus}.spikeTrain ={};
    analData{iClus}.spikeTrainZ={};
    analData{iClus}.numSpikes = [];
    analData{iClus}.peakFiringRate = [];
    SettingsNew = Settings;
    %     SettingsNew = rmfield(SettingsNew,'varDotStimMtx');
    %     SettingsNew = rmfield(SettingsNew,'surrStimMtx');
    analData{iClus}.Settings = SettingsNew ;
    analData{iClus}.spikes = spikes;
    analData{iClus}.clusNo = clusNo(iClus);
    analData{iClus}.static_els = spikes.elidx;
    analData{iClus}.flist = profileData.flist{1};
    
    for i = 1:2:length(frChangeTS)
        [analData{iClus}.spikeTrain{end+1} analData{iClus}.spikeTrainZ{end+1}] = ...
            spiketrains.extract_epoch_from_spiketrain(analData{iClus}.selTs,frChangeTS(i),frChangeTS(i+1));
        analData{iClus}.numSpikes(end+1) = length(analData{iClus}.spikeTrain{end} );
        
    end
    
    
    
end
            
numParapinChanges = length(rgbBrightness)*length(barLengthPx)*length(movingBarSpeedPx)*...
    length(currDirections)*length(Settings.OFFSET_UM);

analData{iClus}.stimPresentationIdx = zeros(5,numParapinChanges);

i = 1;
for iBrightness = rgbBrightness
    for iLength = barLengthPx
        for iVel = movingBarSpeedPx
            for iAngle = currDirections
                for iOffset = Settings.OFFSET_UM
                    analData{iClus}.stimPresentationIdx(1:5,i) = ...
                        [iBrightness; iLength; iVel; iAngle; iOffset];
                        i=i+1;
                    
                end
            end
        end
    end
end

analData{iClus}.stimPresentationNames = {'rgb_brightness'; 'bar_length'; ...
    'bar_speed'; 'angle'; 'offset'}

%% add info to profile file
checkerboardClusNo = input('Enter checkerboard cluster no: ');
fileName = dir(fullfile('../analysed_data/profiles/', sprintf('*checkerboard*%d*.mat', ...
    checkerboardClusNo)))
marchingSqrClusNo = input('Enter moving bars cluster no: ');

profiles.save_to_profiles_file(fileName.name, 'moving_bars', [], [], ...
    'add_struct_fields',analData{marchingSqrClusNo})

%% plotting
i = 1
figure,plot(analData{i}.stimDiamMeanResponsePeakFR(:,1),analData{i}.stimDiamMeanResponsePeakFR(:,2),'ko-'), hold on
plot(analData{i}.stimDiamMeanResponsePeakFR(:,1),analData{i}.stimDiamMeanResponsePeakFR(:,2)*6,'ro-')

