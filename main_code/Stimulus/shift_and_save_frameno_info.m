function shift_and_save_frameno_info(dirName, varargin)
% [framenoInfo] = get_frameno_info(dirName )

forceReshift  = 0;

if ~isempty(varargin )
    forceReshift = 1;
end

framenoInfo.name = dirName; % T directory name
framenoName = dir(fullfile('../analysed_data/',framenoInfo.name,'frameno*' )); % get frame names

% remove shifted version, if it exists
for i=1:length(framenoName)
    if sum(strfind(framenoName(i).name,'shift')) % remove already shifted files from list
       framenoName(i).name = []; 
    end
    
end

fileNameShifted = strrep(framenoName(1).name, '.mat', '_shift860.mat'); % name of shifted file

if or(~exist(fullfile('../analysed_data/',framenoInfo.name, fileNameShifted)), ...
        forceReshift )
        % check for shifted file
    
    % if shifted file does not exist
    load(fullfile('../analysed_data/',framenoInfo.name,framenoName(1).name));% load the frameno
    frameno = shiftframets( frameno); % take into account the projector delay
    save(fullfile('../analysed_data/',framenoInfo.name, fileNameShifted),'frameno') % save file
    fprintf(strcat(['save ', fullfile('../analysed_data/',framenoInfo.name,fileNameShifted),'\n']));
else 
    fprintf(strcat(['Already exists:', fullfile('../analysed_data/',framenoInfo.name,fileNameShifted),'\n']));
end
    
    
    
end
