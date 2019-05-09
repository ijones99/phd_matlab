%% plot all waveforms
h=figure, figs.scale(h,70,80); hold on, axis equal

% load footprintData.mat
waveforms = {};
iStim = 2;

% file info
dirNameProf = '../analysed_data/profiles/';
fileNamesProf = filenames.list_file_names('clus*merg*.mat',dirNameProf);

for iFile =1:length(fileNamesProf)
        
    load(fullfile(dirNameProf, fileNamesProf(iFile).name));
    tsPlot = neurM(iStim).ts(find(neurM(iStim).ts < 2e4*60*4))/2e4;
    plot.raster(tsPlot,'offset',iFile,'height',0.75)
    
end

ylim([0 105]), hold on
xlim([0 60*4])
title('Rasters for All RGCs')
xlabel('Time (seconds)')
ylabel('RGC Number')