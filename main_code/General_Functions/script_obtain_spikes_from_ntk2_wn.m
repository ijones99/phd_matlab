% script isolate spikes from ntk2 file

% get file names
flist = {};
flist_for_analysis

% define neurons to process

% obtained from script_get_list_of_unique_neurs.m
% neursToProcess = neuronIndsToCompare;
neursToProcess = [56 ]%24];

flist = {};
flist{end+1} = '../proc/Trace_id843_2011-12-06T11_27_53_1.stream.ntk';

% go through each file
for i = 6%length(flist)-2:length(flist)
    MINS_TO_LOAD = 30;
    basic_sorting_batch_single_neur_wn_chunk(neursToProcess, flist{i}, MINS_TO_LOAD );
end

%% 