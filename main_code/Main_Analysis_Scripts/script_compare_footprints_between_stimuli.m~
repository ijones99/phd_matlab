% script_compare_footprints_between_stimuli

%% compare difference of footprint electrode amplitudes between stimuli
% White Noise
stimName = 'White_Noise'
neurNames.White_Noise = get_neur_names_from_dir(...
    '../analysed_data/profiles/White_Noise','*_00*','remove_date');
textprogressbar('start loading')
for i=21:length(neurNames.White_Noise)
     data = load_profiles_file(neurNames.White_Noise{i}, 'use_sep_dir', stimName );
    waveformFootprintData.White_Noise{i} = center_footprint(data.White_Noise.footprint.averaged);
    textprogressbar(100*i/length(neurNames.White_Noise))
end
textprogressbar('finish loading')

% Moving Bars
stimName = 'Moving_Bars'
neurNames.Moving_Bars = get_neur_names_from_dir(...
    '../analysed_data/profiles/Moving_Bars','*_00*','remove_date');
textprogressbar('start loading')
for i=83:length(neurNames.Moving_Bars)
     data = load_profiles_file(neurNames.Moving_Bars{i}, 'use_sep_dir', stimName );
    waveformFootprintData.Moving_Bars{i} = center_footprint(data.Moving_Bars.footprint.averaged);
    textprogressbar(100*i/length(neurNames.Moving_Bars))
end
textprogressbar('finish loading')
%%
outputMat = compare_waveforms_two_sources( ...
    waveformFootprintData.White_Noise,waveformFootprintData.Moving_Bars)
outputMat = outputMat/max(max(outputMat));
outputMatMatches = zeros(size(outputMat));
outputMatMatches(find(outputMat<0.075)) = 1;
figure, imagesc(outputMatMatches);colormap('hot')

%%
outputMat2 = outputMat;
outputMat2(find(outputMat2==0))=1;
for i=1:length(outputMat2)
    outputMat2(i,i) = 0;
end
