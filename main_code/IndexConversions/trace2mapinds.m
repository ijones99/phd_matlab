function [mapChannelInd chNumberDatastreams] = trace2mapinds(colNumber, ...
    mapChannelsList)

%
% [mapChannelInd chNumberDatastreams] = convert_inds_datastream_to_mapfile(colNumber, ...
%     mapChannelsList)
%
%    - colNumber: column number from datastream (doug's raw trig format)
%
%    - mapChannelsList: list of channel numbers in the Info structure (from
%    loadmapfile function)
%
%    - mapChannelInd: index of map file that corresponds to inputted col
%    numbers
%
%    - chNumberDatastreams: channel number

chNumberDatastreams = colNumber-1; % remove 1 to get channel number
[junk mapChannelInd ] = ismember(mapChannelsList, chNumberDatastreams );
mapChannelInd = mapChannelInd(find(mapChannelInd>0))';
mapChannelInd = unique(mapChannelInd,'stable');

end
