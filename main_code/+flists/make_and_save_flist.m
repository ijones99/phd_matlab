function  [sortGroupNumber flist sortingRunName] = make_and_save_flist(stimName)
% function [sortGroupNumber flist sortingRunName] = make_and_save_flist(stimName)

if nargin<1
    stimName = input('stimName? [e.g. "wn_checkerboard"] >> ','s');
end

sortGroupNumber = input('Enter sort group number>> ');
makeNewFlist = prompt_for_string_selection('Make new flist?', 'yes_no');
sortingRunName = sprintf('flist_%s_n_%02d',stimName, sortGroupNumber);

if makeNewFlist,
    
    make_flist_select(sprintf('flist_%s_n_%02d.m',stimName,sortGroupNumber))
end
flist = {};eval([sprintf('flist_%s_n_%02d',stimName,sortGroupNumber)]);

end