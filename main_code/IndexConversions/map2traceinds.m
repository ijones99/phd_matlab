function [colNumber channelNum] = map2traceinds(mapChannelIndList, mapChannelInd)

%
% function [colNumber mapChannelsList] = convert_inds_mapfile_to_datastream(mapChannelIndList, ...
%     chNumber)
%
%    - colNumber: column number from datastream (doug's raw trig format)
%
%    - mapChannelsList: list of channel numbers in the Info structure (from
%    loadmapfile function)
%
%    - mapChannelIndList: index of map file that corresponds to inputted col
%    numbers
%
%    - mapChannelsList: channel number
[channelNum] = mapChannelIndList(mapChannelInd);

colNumber = channelNum + 1;

end
