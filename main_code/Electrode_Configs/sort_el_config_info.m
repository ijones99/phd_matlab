function elConfigInfo = sort_el_config_info(elConfigInfo)

% sort the channel numbers
[elConfigInfo.channelNr I ] = sort(elConfigInfo.channelNr);

% sort other data
elConfigInfo.selElNos = elConfigInfo.selElNos(I);
elConfigInfo.elX = elConfigInfo.elX(I);
elConfigInfo.elY = elConfigInfo.elY(I);

end