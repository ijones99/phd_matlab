function review_clusters_for_waveform_comparison(flistNames)

for i=1:length(flistNames)  
    fprintf('(%d) %s (%d)\n', i, flistNames{i}, i);
end

flistIdx = input('Enter flists to open [d1..d2] >> ');
ctrElidx = input('Enter elidx of center electrode [dddd] >> ');

for i=1:length(flistIdx)
    review_clusters(flistNames{i},'center_elidx', ctrElidx,...
        'add_dir_suffix','open_only')
end

end