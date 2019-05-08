% script add flist data to config

% load config
def = dirdefs(); expName = get_dir_date; 
pathDataIn = [def.projHamster, 'sorting_in/',expName];


% load flist
flist={}; run(fullfile(pathDataIn,'flist_all'));

for i=1:length(configs)
   
    configs(i).flist = flist(configs(1).flistidx);
end

save(fullfile(pathDataIn,'configurations.mat'),'configs');