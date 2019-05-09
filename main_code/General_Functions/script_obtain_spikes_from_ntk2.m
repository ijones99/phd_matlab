function get_spikes_from_ntk2(selFileNameNos, neursToProcess)
% script isolate spikes from ntk2 file

% get file names
flist = {};
flist_for_analysis

% go through each file
for i =1:length(selFileNameNos)
    basic_sorting_batch_single_neur(neursToProcess, flist{selFileNameNos(i)},1);
    fprintf('File %d of %d processed.\n', i, length(selFileNameNos));
end

end