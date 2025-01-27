function set_working_path(varargin)
% function SET_WORKING_PATH('main', mainDirPath,'analyzed', analyzedDataDirPath)
% sets global variable mainDirPath and analyzedDataDirPath
% 
% Example
%     mainDirPath = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/5Mar2011_DSGCs_ij/';
%     analyzedDataDirPath = fullfile(mainDirPath,'analysed_data/rec12_21_7/');



global mainDirPath
global analyzedDataDirPath
flist = {};
flist_for_analysis

mainDirPath = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/5Aug2011_testing_only/';
analyzedDataDirPath = fullfile(mainDirPath,'analysed_data/', strcat('rec',flist{1}(end-11-8:end-11)),'/5Channels/');%create directory

i=1;
while i<=length(varargin)
    if strcmp(varargin{i}, 'main');
        i=i+1;
        mainDirPath = varargin{i}; 
    elseif strcmp(varargin{i}, 'analyzed');
        i=i+1;
        analyzedDataDirPath = fullfile(mainDirPath,varargin{i});
    end
    i=i+1;
end
fprintf('path set to:\n mainDirPath = %s\n analyzedDataDirPath = %s\n (global variables)\n',mainDirPath, analyzedDataDirPath);
end
