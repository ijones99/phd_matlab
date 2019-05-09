function [tsMatrix uniqueClus] = extract_spiketrains_from_felix_sorter_results(rIdx, fileName, varargin)
% [tsMatrix uniqueClus] = extract_spiketrains_from_felix_sorter_results(rIdx, ...
%   fileName, dirName)
%
%           clus_num: 100
%             ts (in samples!): [1x2411 single]
% /net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut/

def = dirdefs();
dirName=def.sortingOut;
clusNo = [];

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'dir_name')
            dirName = varargin{i+1};
        elseif strcmp( varargin{i}, 'clus_no')
            clusNo  = varargin{i+1};
        end
    end
end

% load timestamps
load(fullfile(dirName, fileName)); %output "R"

% timestamps
currDataset = R{rIdx(1),rIdx(2)}; 

% find clusters
if isempty(clusNo)
    uniqueClus = unique(currDataset(:,1))';
else
    uniqueClus
end
tsMatrix = {};

% Create out matrix
for i=1:length(uniqueClus)
    tsMatrix{i}.clus_num = uniqueClus(i);    
    tsMatrix{i}.ts = currDataset(find(currDataset(:,1)==uniqueClus(i)),2)';
end

end
