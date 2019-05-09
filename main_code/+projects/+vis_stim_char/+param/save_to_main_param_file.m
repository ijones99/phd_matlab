function save_to_main_param_file( descriptorInfo, param)
% SAVE_TO_MAIN_PARAM_FILE( descriptorInfo, param)

dirNames = projects.vis_stim_char.analysis.load_dir_names;
load(fullfile(dirNames.common.params, 'mainParams'));

currSize = length(mainParams.descriptors); % current size

% check for duplicate existing descriptor
idxDupCol = cells.cell_find_str(mainParams.descriptors, descriptorInfo);

choice = 'e';
if ~isempty(idxDupCol)
    choice = input('Descriptor exists. Overwrite column contents? [y/n] ','s');
end

% add descriptor info
if choice=='e'
    mainParams.descriptors{currSize+1} = descriptorInfo;
elseif choice=='n'
    fprintf('Abort function.\n');
   return; 
end
    
% add data
param = mats.set_orientation(param,'col');

if ~isempty(mainParams.param) % not empty
    
    lengthSavedParams = size(mainParams.param,1); % size of saved param
    lengthInputParams = size(param,1);
    % if length is correct, then save data
    if lengthSavedParams ~= lengthInputParams
        error('inputted data is of wrong length');
    else % ok to save
        if choice=='e'
            mainParams.param(:,currSize+1)=param;
        elseif choice=='y'
            mainParams.param(:,idxDupCol)=param;
        end
        save(fullfile(dirNames.common.params, 'mainParams.mat'),'mainParams');
        fprintf('Wrote mainParams to %s\n', fullfile(dirNames.common.params, 'mainParams.mat'));
    end
    
else
    % if empty, save to variable
    mainParams.param=param;
    save(fullfile(dirNames.common.params, 'mainParams.mat'),'mainParams');
    fprintf('Wrote mainParams to %s\n', fullfile(dirNames.common.params, 'mainParams.mat'));
end

end