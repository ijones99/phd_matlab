function create_exp_dir

flistFileNames = dir('../proc/Trace_id*.stream.ntk');

%make dir for first pass spike sorting with all neurons
eval(['!mkdir ../analysed_data/all_neur/' ]);
eval(['!mkdir ../analysed_data/full_sel_neur/' ]);
eval(['!mkdir ../analysed_data/final_sel_neur/' ]);

for i=1:length(flistFileNames)
    
    % get start position for parsing dir name from file name
    startPos = strfind(flistFileNames(i).name,'T');startPos = startPos(2);
    endPos = strfind(flistFileNames(i).name,'stream')-2;
    
    % obtain dir name
    dirName = flistFileNames(i).name(startPos:endPos);
    
    % create dir
    eval(['!mkdir ../analysed_data/full_sel_neur/',dirName ]);
    eval(['!mkdir ../analysed_data/final_sel_neur/',dirName ]);
end

end