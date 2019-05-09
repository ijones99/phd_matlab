function [tsMatrix ] = ...
    extract_single_neur_spiketrains_from_felix_sorter_results(R, ...
    configColumn, configIdx, varargin)
% function [tsMatrix uniqueClus] = ...
%     EXTRACT_SINGLE_NEUR_SPIKETRAINS_FROM_FELIX_SORTER_RESULTS(R, configColumn, configIdx, varargin)
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
        if strcmp( varargin{i}, 'clus_no')
            clusNo = varargin{i+1};           
        end
    end
end

% if no cluster number suppled, then use all from the first cell
if isempty(clusNo)
    clusNo = unique(R{1,configColumn}(:,1));
end

clear tsMatrix

% Create out matrix
for iClus = 1:length(clusNo)
    tsMatrix(iClus).clus_num = clusNo(iClus);
end
m = {};
for iClus = 1:length(clusNo)
    st = {};
    for iConfigIdx = 1:length(configIdx)
        currStIdx = find(R{configIdx(iConfigIdx),configColumn}(:,1)==clusNo(iClus));
        st{iConfigIdx} = R{configIdx(iConfigIdx),configColumn}(currStIdx,2)';
    end
    m{iClus} = st;
    progress_info(iClus, length(clusNo))
end


for iClus = 1:length(clusNo)
    tsMatrix(iClus).st = m{iClus};
end


end
