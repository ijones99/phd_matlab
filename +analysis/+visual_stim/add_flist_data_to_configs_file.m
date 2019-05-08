function configs = add_flist_data_to_configs_file(configs, expName)
% configs = ADD_FLIST_DATA_TO_CONFIGS_FILE(configs,expName)
%
% arguments:
%   Tip: use "expName = get_dir_date"

% load config
def = dirdefs();
pathDataIn = [def.projHamster, 'sorting_in/',expName];

% load flist
flist={}; run(fullfile(pathDataIn,'flist_all'));

for i=1:length(configs)
    
    configs(i).flist = flist(configs(1).flistidx);
end

save(fullfile(pathDataIn,'configurations.mat'),'configs');

end