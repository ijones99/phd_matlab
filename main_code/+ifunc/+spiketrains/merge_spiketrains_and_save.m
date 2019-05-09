function merge_spiketrains_and_save(neurNames, stimName)
% ifunc.spiketrains.merge_spiketrains_and_save(neurNames, stimName)
% spikes will be saved to first neuron structure

dirName = sprintf('../analysed_data/profiles/%s/',stimName);

% load first struct
neur1  = load_neur_file(dirName, neurNames{1});
data1 = getfield(neur1,stimName);
spiketimes = data1.spiketimes;

for iNeur = 2:length(neurNames)
    % load neuron
    neurCurr  = load_neur_file(dirName, neurNames{iNeur});
    % get time stamps
    dataCurr = getfield(neur1,stimName);
    
    spiketimes = [spiketimes dataCurr.spiketimes];
    save_to_profiles_file(neurNames{iNeur}, stimName, 'merged_with_other_neuron',...
        neurNames{1},1, 'use_sep_dir', stimName);
   
    
end

spiketimes = sort(spiketimes);

save_to_profiles_file(neurNames{1}, stimName, 'spiketimes_before_merge',...
        data1.spiketimes , 1, 'use_sep_dir', stimName);
save_to_profiles_file(neurNames{1}, stimName, 'spiketimes',...
        spiketimes , 1, 'use_sep_dir', stimName);

    
end