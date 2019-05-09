function [flist] = search_files_by_time( timepoint, dirName, varargin )
% function [flist] = search_files_by_time( timepoint, dirName, varargin )
% function [flist] = search_files_by_time( timeStamp )
% arguments: 
%   timepoint: either a range or a value 
%       e.g. 1200 for 12:00 o'clock or [1200 1230]. If a single value is
%       entered, the program will find the next file after that time.
% options:
%     'save_to_file' followed by file name
%     'file_text' followed by text to put as title within document
%   
%  author: ijones
flist = {};
fileName = [];
fileText = [];
% adjust time input to 6 digits
if length(timepoint) == 1
    if timepoint < 1e5;
        timepoint  = timepoint*100;
    end
    timepoint(2) = timepoint(1)+100;
elseif length(timepoint) > 1   
    if timepoint(1) < 1e5;
        timepoint(1)  = timepoint(1)*100;
    end
    if timepoint(2) < 1e5;
        timepoint(2)  = timepoint(2)*100;
    end     
end



% optional arguments
for i=1:length(varargin)
    if strcmp(varargin{i},'save_to_file');
        fileName = varargin{i+1};
    elseif strcmp(varargin{i},'file_text');
        fileText = varargin{i+1};
    end
end

% list all files of the ntk type in the directory
fileNames = dir(fullfile(dirName,'*.ntk'));
timeValue = 0;
% get each time for each file
for i=1:length(fileNames)
    % get the date of each file
    dateVector = datevec(fileNames(i).date);
    %put the hour, mins and seconds into a number
    timeValue(i) = dateVector(end-2)*1e4 + dateVector(end-1)*1e2 + dateVector(end)*1;
end

% find indices of time stamps of files of interest
timeValueInd = (find(and(timeValue>=timepoint(1),timeValue<=timepoint(2))));

% if single value, then display data for this one and save the file name
if length(timepoint) == 1   
    % find the closest file to that time
    fileInd = find(timeValue == min(timeValue));
    % display file info
    fprintf('%s %s\n', fileNames(fileInd).name, fileNames(fileInd).date);
    
    % save info
    flist{end+1} = strcat('../proc/',fileNames(fileInd).name);
    
% if a range, display the files and save names 
elseif length(timepoint) > 1

    % display file info
    for j = 1:length(timeValueInd)
        fprintf('%s %s\n', fileNames(timeValueInd(j)).name, fileNames(timeValueInd(j)).date);
        
        % save info
        flist{end+1} = strcat('../proc/',fileNames(timeValueInd(j)).name);
    end
    
else
    disp('Error');
end

% write to file
if ~isempty(fileName)
    fid = fopen(fullfile('',fileName),'a');
    if ~isempty(fileText)
        fprintf(fid,strcat('% ',fileText,'\n\n'));
    end
    
    for iWrite = 1:length(flist)
        fprintf(fid,strcat('flist{end+1}=''',flist{iWrite},'''',';\n'));
        flist{iWrite}
    end
    
    fclose(fid);
    
end

end