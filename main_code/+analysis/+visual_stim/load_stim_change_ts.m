function stimChangeTs  = load_stim_change_ts(varargin)
% stimChangeTs  = load_stim_change_ts
%
% varargin
%   'run_no'
%   'idx_exclude'
%   'idx_include'
%   'no_save'
%   'force_reload'
%   'interstim_time'

runNo=1;
idxExclude = [];
idxInclude = [];
doSave = 1;
doForceFileReload = 0;

% load switchPoints
interStimTime=0.5;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'run_no')
            runNo = varargin{i+1};
        elseif strcmp( varargin{i}, 'idx_exclude')
            idxExclude = varargin{i+1};
        elseif strcmp( varargin{i}, 'idx_include')
            idxInclude = varargin{i+1};        
        elseif strcmp( varargin{i}, 'force_reload')
            doForceFileReload = 1;
        elseif strcmp( varargin{i}, 'no_save')
            doSave = 0;
        elseif strcmp( varargin{i}, 'interstim_time')
            interStimTime = varargin{i+1};        
        end
    end
end


% PATH INFO
pathDef = dirdefs();
expName = get_dir_date;

% framenosToLoad = input('idx for stimChangeTs to load (usually = 1 for wn_checkerboard) >> ');


% flist
load(fullfile(pathDef.dataIn,expName,'configurations'))
refFileCtrLoc.flist = configs(runNo).flist;

% idx of files to load
allIdx = [1:length(configs(runNo).flist)];
if ~isempty(idxExclude)
    allIdx = allIdx(~ismember(allIdx,idxExclude));
elseif ~isempty(idxInclude)
    allIdx = allIdx(ismember(allIdx,idxInclude));
end
    



stimChangeTs = cell(1,length(configs(runNo).flist));

if ~exist('stimChangeTsAll.mat','file') | doForceFileReload
    for i=allIdx
        currFrameno = get_framenos(configs(runNo).flist{i});
        stimChangeTs{i} = get_stim_start_stop_ts2(currFrameno{1},interStimTime);
    end
    
    if doSave
    save stimChangeTsAll stimChangeTs
    fprintf('Saved stimChangeTs to stimChangeTsAll.mat\n');
    else
        fprintf('No file saved.\n');
    end
else
    load stimChangeTsAll
    fprintf('Loaded matrix stimChangeTs, file stimChangeTsAll.mat\n');
end




end