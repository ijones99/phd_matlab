function [selElsIdx elsToExcludeIdx] = get_sel_el_ids(hdmea)
% [selElsIdx elsToExcludeIdx] = get_sel_el_ids(hdmea)
% PURPOSE:
%   get the electrodes that are the square in the middle of the
%   configuration

uniqueXCoords = unique(hdmea.MultiElectrode.electrodePositions(:,1));

elsToExcludeIdx = [];
for i=1:length(uniqueXCoords)
    
    matchesForCoord = ismember(hdmea.MultiElectrode.electrodePositions(:,1),uniqueXCoords(i));
    coordMatchInx = find(matchesForCoord);
    if  sum(matchesForCoord) == 1
        elsToExcludeIdx(end+1) = coordMatchInx;
    end
    
end

allElIdx = 1:126;%1:size(hdmea.MultiElectrode.electrodePositions,1);


selElsIdx = allElIdx(~ismember(allElIdx,elsToExcludeIdx));




end