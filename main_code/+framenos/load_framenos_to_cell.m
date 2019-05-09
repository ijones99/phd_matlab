function frameno = load_framenos_to_cell(runNo)
% frameno = LOAD_FRAMENOS_TO_CELL(runNo)
% Purpose: load all framenos (either load mat file, or extract from ntk files);
doLoadFrameNo=1;
pathDef = dirdefs();
expName = get_dir_date;

configColumn = runNo; 

% load configs
load(fullfile(pathDef.dataIn,expName,'configurations'))
% load(sprintf('%s%s_resultsForIan',pathDef.sortingOut, expName))

% load framenos
frameNoFileName = sprintf('frameno_run_%02d', runNo);
if ~exist([frameNoFileName,'.mat'],'file') % if frameno doesn't exist, extract it
    frameno = {};
    if ~isfield(configs(runNo), 'flist')
        configs = analysis.visual_stim.add_flist_data_to_configs_file(configs, expName);
    end
    
    frameno = get_framenos(configs(runNo).flist);
    save(frameNoFileName, 'frameno')
    
elseif ~exist('frameno','var') %if it exists load it
    if doLoadFrameNo
        load(frameNoFileName, 'frameno');
    end
end




end