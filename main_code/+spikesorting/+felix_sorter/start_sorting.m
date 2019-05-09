function start_sorting(batchInfo, requestedNumWorkersInPool, varargin)
%% vars needed
%   ARGUMENTS
%       batchInfo
%           .data_path
%           .out_path
%           experiments(n)
%               .expNames
%               .flistName
%               .sortingName
%
% requestedNumWorkersInPool = 5;
% expNames{n}: % make sure you have the path of a folder with all .ntk files WITH A SINGLE
%   COMMON configuration in the variable "dpath"
%
% data_path =
%   '/net/bs-filesvr01/export/group/hierlemann/projects/retina_project/ijones_data/hamster_retina_data_and_sorting_01';
%   -> contains: configurations.mat  flist_run_01.m  Matlab  proc
% out_path: sorting output results path
%     DIR: /links/groups/hierlemann/Temp/FelixFranke/IanSortingOut
%        DIR CONTENTS: 30Apr2014Out  30Apr2014_resultsForIan.mat
% outPath = fullfile(out_path, [expName 'Out']);
%     DIR: /links/groups/hierlemann/Temp/FelixFranke/IanSortingOut/0
%        DIR CONTENTS: h5 files, Configs results
% flistName{n}
% 
% NOTE: this takes 36 minutes on a typical white noise stimulus
% when using 6 processors. 

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'skip_h5_conversion')
            doConvertH5Files = varargin{i+1};
        end
    end
end





fprintf('add try/catch.\n');

%check for existence of function, indicating that paths are existent
funcFound = which('MeanShiftClusterIncreaseBW');
if isempty(funcFound)
%    error('Please cd to ~/bel.svn/hima_internal/cmosmea/trunk/matlab/ and run setup.');
    currDir = pwd;
    cd('~/bel.svn/hima_internal/cmosmea/trunk/matlab/');
    setup
    fprintf('setup run.\n');
end

def = dirdefs();
%% init matlabpool
isOpen = matlabpool('size') > 0;
% if ~isOpen
%     matlabpool open
% end

if isOpen
    currPoolSize = matlabpool('size') ;
    if requestedNumWorkersInPool ~= currPoolSize
        matlabpool close;
        eval(sprintf('matlabpool open local%dclus',requestedNumWorkersInPool));
    else
        fprintf('Pool already open.\n');
    end
    
else
    eval(sprintf('matlabpool open local%dclus',requestedNumWorkersInPool));
    
end

for iBatchNo = 1:length(batchInfo.experiments)
    % data_path = sprintf('/net/bs-filesvr01/export/group/hierlemann/projects/retina_project/ijones_data/hamster_retina_data_and_sorting_%02d/',runNo);
    % data_path = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/'
    % pd = pdefs();
    % make sure you have the path of a folder with all .ntk files WITH A SINGLE
    % COMMON configuration in the variable "dpath"
    % expNames = {'30Apr2014_02'};
    expNames = batchInfo.experiments(iBatchNo).expNames;
    for kk=1
        % var defs
        expName = expNames ;
        depath = batchInfo.out_path;
        
        outPath = fullfile(depath, [expName 'Out']);
        data_path = batchInfo.in_path;
        flistName = batchInfo.experiments(iBatchNo).flistName;
        sortingName = batchInfo.experiments(iBatchNo).sortingName;
        % --------
        if ~exist(outPath, 'file'); mkdir(outPath); end
        confListFile = fullfile(data_path, expName, 'configurations.mat');
        c = load(confListFile);
        flist_file = fullfile(data_path, expName, flistName);
        flist = {};
        run(flist_file)
        %% prepare ians configNTKList cell of cells
        
        configNTKLists = {};
        for ci = 1:length(c.configs)
            configNTKLists{ci} = flist(c.configs(ci).flistidx);
            for i=1:length(configNTKLists{ci})
                [a b ending] = fileparts(configNTKLists{ci}{i});
                configNTKLists{ci}{i} = fullfile(data_path, expName, 'proc', [b ending]);
            end
        end
        
        %% Now we CONVERT all ntk files to H5. Doing this we also prefilter the data
        h5FileLists = {};
%         if  matlabpool('size') == 0
%             eval(sprintf('matlabpool open local%dclus',requestedNumWorkersInPool));
%         end
        parfor i=1:length(configNTKLists)
            for k=1:length(configNTKLists{i})
                fn = configNTKLists{i}{k};
                [ffolder ffname fsuffix] = fileparts(fn);
                fnpf = fullfile(outPath, [ffname fsuffix '_prefilter.h5']);
                h5FileLists{i}{k} = fnpf;
                bConvertFile = true;
                if exist(fnpf, 'file')
                    try
                        bIsInProcess = hdf5read(fnpf, '/bFileIsInProcess');
                        if bIsInProcess
                            % This means the file is still in process. We assume no
                            % other user/matlab instance is writing so it is
                            % probably a left over from some other run and we
                            % delete it.
                            delete(fnpf);
                        else
                            % The file was already properly processed, we dont need
                            % to do anything.
                            bConvertFile = false;
                        end
                    catch
                        delete(fnpf);
                    end
                end
                if bConvertFile
                    % Only convert file if it was non existent or deleted
                    mysort.mea.convertNTK2HDF(fn, 'prefilter', 1, 'outFile', fnpf);
                end
            end
        end
        
        disp('Done Converting.');
        
        %%
        
        for i=1:length(h5FileLists)
            
            sortOutPath = fullfile(outPath, ['Config' num2str(i)], sortingName);
            ana.michele.spikeSortingStartScripts.run(h5FileLists{i}, sortOutPath, sortingName);
        end
        
        %% EXPORT TO SINGLE FOLDER
        exportPath = fullfile(outPath, 'Results');
        if ~exist(exportPath, 'file')
            mkdir(exportPath)
        end
        R = {};
        for i=1:length(h5FileLists)
            sortOutPath = fullfile(outPath, ['Config' num2str(i)], sortingName);
            sourceFile = fullfile(sortOutPath, [sortingName '_results.mat'])
            assert(exist(sourceFile, 'file')>0, 'File not found!');
            D = load(sourceFile);
            
            % get individual files' length in samples
            compoundMea = mysort.mea.compoundMea(h5FileLists{i}, 'useFilter', 0, 'name', 'PREFILT');
            L = compoundMea.X.getAllSessionsLength();
            
            % break gdf apart
            start_end_times = [0 cumsum(L)];
            mgdf = mysort.spiketrain.gdf2multiSessionGdf(D.gdf_merged, start_end_times);
            for k=1:length(L)
                gdf = mgdf(mgdf(:,3)==k,[1:2]);
                R{k, i} = gdf;
            end
        end
        out_path = batchInfo.out_path;
        save(fullfile(out_path, [expName '_resultsForIan.mat']), 'R');
    end
end

matlabpool close
fprintf('Entire batch completed.\n')