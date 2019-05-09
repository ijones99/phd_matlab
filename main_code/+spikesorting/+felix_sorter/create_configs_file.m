function configs = create_configs_file(batchInfo, varargin)

def = dirdefs();
mainPath = [def.projHamster, 'sorting_in/'];
expName = '';
extraDir = '';
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'main_path')
            mainPath = varargin{i+1};
        elseif strcmp( varargin{i}, 'exp_name')
            expName = varargin{i+1};
        elseif strcmp( varargin{i}, 'add_dir_to_path')
            extraDir = varargin{i+1};
        end
    end
end



doneCreatingConfig= 'n';
iConfigIdx = 1;
configs = [];
while ~strcmp(doneCreatingConfig,'y')
    
    cd(mainPath)
    % exp name
    if isempty(expName)
        expName = input('Enter expName (e.g. 30Apr2014) >> ','s');
    end
    cd([batchInfo.in_path,expName]);
%     get flist
    flist={},run('flist_all');
    %print flist
    for i=1:length(flist), fprintf('(%d) %s \n',i,flist{i}), end
    
    [ntkFileNum ntkFileNames] = filenames.select_flist_name('prompt_string_only','Enter flist numbers for config file',...
        'proc_dir', 'proc', 'flist', flist);
    
    flistIdx = filenames.filename_idx_to_flist_idx(ntkFileNames, flist, ntkFileNum  )
    
    configs(iConfigIdx).flistidx = flistIdx;
    configNamesCell = input('Enter cell with stimulus names (e.g. {''wn_checkerboard'', ''marching_sqr'', ''moving_bars''}) >> ');
    configs(iConfigIdx).info =  configNamesCell;%{'wn_checkerboard'    'marching_sqr'    'moving_bars'};
    % add spots
    numBaseStim = length(configs(iConfigIdx).info);
    for i=numBaseStim+1:length(configs(iConfigIdx).flistidx)
        configs(iConfigIdx).info{i} = sprintf('spots_%02d', i-numBaseStim);
    end
    for i=1:length(configs(iConfigIdx).flistidx)
        configs(iConfigIdx).name{i} = sprintf('config %02d', i);
    end
    
    % check to ensure that config file is correct
    if length(configs(iConfigIdx).flistidx)~=length(configs(iConfigIdx).info) ||...
        length(configs(iConfigIdx).flistidx)~=length(configs(iConfigIdx).name)
        warning('configs struct checksum fail.')
    end
    
    % add flist data to configs file
    if isempty(extraDir)
        pathDataIn = [def.projHamster, 'sorting_in/',expName];
    else
         pathDataIn = [def.projHamster, 'sorting_in/',extraDir, '/', expName];
    end
    % load flist
    flist={}; run(fullfile(pathDataIn,'flist_all'));

    for i=1:length(configs)
        
        configs(i).flist = flist(configs(1).flistidx);
    end
    
    doneCreatingConfig = input('Finish creating config? [y/n]','s');
    
    
    
   save('configurations.mat','configs');
    
    iConfigIdx=iConfigIdx+1;
end