function change_spikes_params

fileNamePattern = 'cl*mat';

fileNames = dir(fileNamePattern);


% go through each file and rename
for i=1:length(fileNames)
    
    i
    % load file
    load(fileNames(i).name);
    
    % new name to assign to struct
    periodLoc = strfind(fileNames(i).name,'.');
    newName = fileNames(i).name(1:periodLoc-1);


    
    eval(['spikes=',newName,';']);
    
    % turn on ISI display
    spikes.params.display.show_isi=1;
    
    % find max amplitude of main electrode signals
    avgWaveformMainEl = mean(spikes.waveforms(:,:,1));
    spikes.main_el_avg_amp = max(avgWaveformMainEl) - min(avgWaveformMainEl);

    
    eval([newName,'=spikes;']);
    
    clear spikes
    
    % save file with alterations
    save(fileNames(i).name, newName);
        
end


end