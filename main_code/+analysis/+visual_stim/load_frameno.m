function frameno  = load_frameno(varargin)
% frameno  = load_frameno(varargin)
%
% varargin
%   'run_no', 'force_reload', 'no_save', 'r_idx'
%

runNo=[];
doForceReload = 0;
doSave = 1;
rIdx = [];

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'run_no')
            runNo = varargin{i+1};
        elseif strcmp( varargin{i}, 'force_reload')
            doForceReload = 1;
        elseif strcmp( varargin{i}, 'no_save')
            doSave = 0;
        elseif strcmp( varargin{i}, 'r_idx')
            rIdx  = varargin{i+1};
        end
    end
end


% PATH INFO
pathDef = dirdefs();
expName = get_dir_date;
if isempty(runNo)
    runNo=input('run no >> ');
end
% flist
load(fullfile(pathDef.dataIn,expName,'configurations'))
if ~isfield(configs(runNo),'flist')
    flist = {};
    run(fullfile(pathDef.dataIn,expName,'flist_all'))
    configs(runNo).flist = flist(configs(runNo).flistidx);
    save(fullfile(pathDef.dataIn,expName,'configurations'),'configs');
end

refFileCtrLoc.flist = configs(runNo).flist;

% load framenos
clear frameno
frameNoFileName = sprintf('frameno_run_%02d', runNo);
if ~exist([frameNoFileName,'.mat'],'file') || doForceReload
    % init frameno
    if isempty(rIdx)
        framenosToLoad = input('idx for framenos to load (usually = 1 for wn_checkerboard) >> ');
    else
        framenosToLoad = rIdx;
    end
    frameno = cell(1,max(framenosToLoad));
    if ~isfield(configs(runNo), 'flist')
        configs = analysis.visual_stim.add_flist_data_to_configs_file(configs, expName);
    end
    frameno(framenosToLoad) = get_framenos(configs(runNo).flist(framenosToLoad));
    if doSave
        save(frameNoFileName, 'frameno');
    end
    % if frameno was already saved:
    
elseif ~exist('frameno','var')
    load(frameNoFileName, 'frameno');
end


% % load switchPoints
% interStimTime=0.5;
% if ~exist('stimChangeTsAll.mat','file')
%     for i=1:length(configs(runNo).flist)
%         currFrameno = get_framenos(configs(runNo).flist{i});
%         stimChangeTs{i} = get_stim_start_stop_ts2(currFrameno{1},interStimTime);
%     end
%
%     save stimChangeTsAll stimChangeTs
% else
%     load stimChangeTsAll
% end





end