function data = load_felix_sorted_data(inputDate)
% data = load_felix_sorted_data(inputDate)
% Function to load data from felix-sorted data;
% ian.jones@bsse.ethz.ch

% % To implement:
% Roska/<expname>/<nktfname>/sortings/<run_name>/<group_name>
%  
% So I added the “run_name” as a folder. This helps keeping different ...
% runs apart from each other since “group001” might be different for ...
% different runs.

% suffix 
suffixName = '/sortings/run_felix2/run_felix2Export4UMS2000.mat';

% dir name
selDir.Roska = '/net/bs-filesvr01/export/group/hierlemann/recordings/HiDens/SpikeSorting/Roska/';

% get file names
fileNames = dir(fullfile(selDir.Roska,inputDate,'*.stream'));

% display files
for i=1:length(fileNames)
    
   fprintf('(%d) %s\n',i,fileNames(i).name); 
    
end

selFile = input('\nSelect one file above:');

fprintf('\nWill now load %s.\n', fullfile(selDir.Roska, inputDate, fileNames(selFile).name,suffixName));

data = load(fullfile(selDir.Roska, inputDate, fileNames(selFile).name,suffixName));







end