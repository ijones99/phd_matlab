% script to create ntk2 preprocessing data file

preProcessInfoNtk = {};
sessions = 4;
baseDir = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/';

% ----------------------------------------------------------------- %
expDate = '27Nov2012';
flistNames = { ...
    'flist_orig_stat_surr'; ...
    'flist_dyn_surr_each_frame_and_shuffled'; ...
    'flist_pix_surr_50_90_percent'; ...
    'flist_diff_size_dots_moving_bars';...
    }
selEls = [4340 4638 4740 4742 4742 4845 4846 4945 4947 4948 4949 5046 5048 5050 5148 ...
    5149 5150 5151 5152 5153 5252 5253 5255 5353 5354 5355 5356 5357 5456 5457 ...
    5458 5459 5556 5557 5559 5560 5658 5560 5658 5659 5660 5661 5662 5761 5762 ...
    57625763 5862 5865 5964 5966 5967 6068 6069 6071 6169 6170 6170 6171  6173 ...
    6272 9273 6274 6372 6373 6374 6376 6475 6476 6579 ];
selEls = unique(selEls);
numElsPerGroup = round(length(selEls)/sessions);

for i=1:length(flistNames)
    for j=1:sessions-1
        preProcessInfoNtk{end+1}.status = 'unprocessed';
        preProcessInfoNtk{end}.expDate = expDate;
        preProcessInfoNtk{end}.directory = strcat(baseDir,expDate,'/Matlab/');
        preProcessInfoNtk{end}.flist = flistNames{i};
        preProcessInfoNtk{end}.els = selEls([1:numElsPerGroup]+((j-1)*numElsPerGroup));
    end
    
    preProcessInfoNtk{end+1}.status = 'unprocessed';
    preProcessInfoNtk{end}.expDate = expDate;
    preProcessInfoNtk{end}.flist = flistNames{i};
    preProcessInfoNtk{end}.directory = strcat(baseDir,expDate,'/Matlab/');
    preProcessInfoNtk{end}.els = selEls(numElsPerGroup+((j-1)*numElsPerGroup): length(selEls)  );
end

% ----------------------------------------------------------------- %
expDate = '13Dec2012_2';
flistNames = { ...
   'flist_orig_stat_surr'; ...
    'flist_dyn_surr_each_frame_and_shuffled'; ...
    'flist_pix_surr_50_90_percent'; ...
    'flist_diff_size_dots_moving_bars';...
    }
selEls = [4324 4623 4627 4725 4726 4727 4728 4729 4730 4827 4828 4829 4831 ...
    4832 4929 4931 4933 4934 5031 5032 5033 5034 5035 5137 5138 5236 5237 ...
    5339 5440 5444 5645 5747 5749 5848 5950 5952 6051 6051 6052 6054 6153 ...
    6155 6256 6357 6358 6360 6361 6362 6459 6564 6566 ];
selEls = unique(selEls);

numElsPerGroup = round(length(selEls)/sessions);

for i=1:length(flistNames)
    for j=1:sessions-1
        preProcessInfoNtk{end+1}.status = 'unprocessed';
        preProcessInfoNtk{end}.expDate = expDate;
        preProcessInfoNtk{end}.directory = strcat(baseDir,expDate,'/Matlab/');
        preProcessInfoNtk{end}.flist = flistNames{i};
        preProcessInfoNtk{end}.els = selEls([1:numElsPerGroup]+((j-1)*numElsPerGroup));
    end
    
    preProcessInfoNtk{end+1}.status = 'unprocessed';
    preProcessInfoNtk{end}.expDate = expDate;
    preProcessInfoNtk{end}.flist = flistNames{i};
    preProcessInfoNtk{end}.directory = strcat(baseDir,expDate,'/Matlab/');
    preProcessInfoNtk{end}.els = selEls(numElsPerGroup+((j-1)*numElsPerGroup): length(selEls)  );
end


    
save('~/preProcessInfoNtk.mat', 'preProcessInfoNtk')
    

%%
% script to create ntk2 preprocessing data file

preProcessInfoNtk = {};
sessions = 2;
baseDir = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/';

% ----------------------------------------------------------------- %

% ----------------------------------------------------------------- %
expDate = '13Dec2012_2';
flistNames = { ...
   'flist_orig_stat_surr'; ...
    'flist_dyn_med_dyn_med_shuff'; ...
    'flist_pix_surr_50_90_percent'; ...
    'flist_diff_size_dots_moving_bars';...
    }
selEls = [4831  5138 ];
selEls = unique(selEls);

numElsPerGroup = ceil(length(selEls)/sessions);

for i=1:length(flistNames)
    for j=1:sessions-1
        preProcessInfoNtk{end+1}.status = 'unprocessed';
        preProcessInfoNtk{end}.expDate = expDate;
        preProcessInfoNtk{end}.directory = strcat(baseDir,expDate,'/Matlab/');
        preProcessInfoNtk{end}.flist = flistNames{i};
        preProcessInfoNtk{end}.els = selEls([1:numElsPerGroup]+((j-1)*numElsPerGroup));
    end
    
    preProcessInfoNtk{end+1}.status = 'unprocessed';
    preProcessInfoNtk{end}.expDate = expDate;
    preProcessInfoNtk{end}.flist = flistNames{i};
    preProcessInfoNtk{end}.directory = strcat(baseDir,expDate,'/Matlab/');
    preProcessInfoNtk{end}.els = selEls(numElsPerGroup+((j-1)*numElsPerGroup)+1: length(selEls)  );
end


    preProcessInfoNtk
save('~/preProcessInfoNtk.mat', 'preProcessInfoNtk')

    
    
    
    
    
    
    