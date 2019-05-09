

def = dirdefs();

%       batchInfo
%           .data_path
%           .out_path
%           experiments(n)
%               .expNames
%               .flistName
%               .sortingName

% assign paths
initBathInfo = input('init batch info? [y/n]','s');
if strcmp(initBathInfo ,'y')
    batchInfo = {};
end
batchInfo.data_path = def.expRecordings;
batchInfo.out_path = def.sortingOut;
batchInfo.in_path = [def.projHamster, 'sorting_in/'];
% /home/ijones/Projects/hamster_visual_characterization/sorting_in/
mkdir(batchInfo.in_path)

% loop to create batch file
doneCreatingBatchInfo = 'n';
iBatchIdx = 1;
while ~strcmp(doneCreatingBatchInfo,'y')
    cd(batchInfo.in_path)
    fprintf('>>> New experiment: ... \n');
    expName = input('Enter expName (e.g. 30Apr2014) >> ','s');
    batchInfo.experiments(iBatchIdx).expNames = expName;
    batchInfo.experiments(iBatchIdx).sortingName = 'Sorting_01';
    batchInfo.experiments(iBatchIdx).flistName = 'flist_all.m';

    % make directories (file structure)
    mkdir(expName);
    cd(expName);
    mkdir('Matlab')
    % soft link
    eval(sprintf('!ln -s %s%s/proc proc',def.expRecordings, expName ))
    % make flist
    cd ('Matlab')
    [flist batchInfo.experiments(iBatchIdx).flistName ] =  ...
        flists.make_flist_select('all',[],'no_flist_id','no_run_no');
    
    cd(fullfile(batchInfo.in_path,expName))
    !mv Matlab/flist*.m .
    fprintf('Printing flist...\n')
    for i=1:length(flist),fprintf('%d) %s\n', i,flist{i}),end
    % make configs file
    configs = spikesorting.felix_sorter.create_configs_file(batchInfo,'exp_name', expName);
    
    iBatchIdx = iBatchIdx+1;
    doneCreatingBatchInfo = input('Done creating batch file? [y/n]','s');
end
cd(batchInfo.in_path)
fileNameIsNew = 0
while fileNameIsNew ~= 1
   batchFileName = input('Enter file name to save batch file. >> ','s');
   if ~exist([fullfile('batch_info',batchFileName), '.mat'],'file')
       save(fullfile('batch_info',batchFileName),'batchInfo');
       fileNameIsNew = 1;
   else
       warning('File exists. Please choose another name...');
   end
    
end

%% 
% /home/ijones/Projects/hamster_visual_characterization/sorting_in/batch_info/
numCPUcores = 2;
spikesorting.felix_sorter.start_sorting(batchInfo, numCPUcores )
 
 