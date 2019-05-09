function spikesort_movies_for_spec_neurs
% PUPROSE: Process the h5 files for found neurons in every experiment for 
% all movies.

% get dir struct
dirList = ifunc.dir.create_dir_list


for iExp = 1:length(dirList.net)
    
    % go to matlab dir
    cd(dirList.belsvn{iExp});
    
    % load neuron names list
    load neurNameMat.mat; selNeurNames = neurNameMat(:,1);
    
    % load neuron profiles and get inds for highest amp
    groupsidx = {};
    for iNeur = 1:length(selNeurNames)
        try
        % load neur profile
        data = load_profiles_file(selNeurNames{iNeur},'use_sep_dir','All_Stim');
        
        % get inds of max amp and put into group
        groupsidx{iNeur} = get_max_amp_spikes(data.White_Noise.footprint_median, 7)
        
        clear data
        catch
            funcName = mfilename('fullpath');
            msgToSave = sprintf('Date %s: Cannot load neuron %s',get_dir_date, selNeurNames{iNeur}  );
            ifunc.log.write_to_log_file(funcName, msgToSave );
            
        end
        
    end
    
    % change to net dir
    cd(dirList.net{iExp});
    
    %run spikesorting
    expName = get_dir_date;
    flist = {}; flist_movies;
    ifunc.proc.sort_cluster_based(expName, flist, groupsidx )
    
end