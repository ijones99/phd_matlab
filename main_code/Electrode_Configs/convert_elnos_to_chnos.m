function chNumbers = convert_elnos_to_chnos(elConfigInfo, inputElNos)

% this function tells you which numbers in the second argument one must
% take in order to get the numebrs in the first argument
[Y I] = ismember(inputElNos, elConfigInfo.selElNos);

chNumbers = elConfigInfo.selChNos(I);


end