function save_profiles_file(neuronName, outputDir, data, varargin)
% save_profiles_file(neuronName, outputDir, data)

P.dirDate = get_dir_date;
P.suppressPrint = 0;

% check for arguments
P = mysort.util.parseInputs(P, varargin, 'error');

% directories
dirNameProfiles = fullfile('../analysed_data/profiles/', outputDir);

% get filename
fileName = strcat(get_dir_date, '_', neuronName);

% save data
if ~exist(dirNameProfiles)
    mkdir(dirNameProfiles);
end

save(fullfile(dirNameProfiles,fileName), 'data');
if ~P.suppressPrint
    fprintf('processed and saved %s to %s%s\n',neuronName,dirNameProfiles,fileName);
end
end