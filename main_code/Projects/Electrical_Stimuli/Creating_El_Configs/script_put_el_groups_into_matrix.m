% first run script_gen_sequence_with_fix_electrodes.m
maxNumElsInGroup = 0;

% find max length of group
for i=1:length(scan_els)
    maxNumElsInGroup = max(length(scan_els{i}.el_idx),maxNumElsInGroup);
end

% create rows with this value
allElConfigGroupsMat = zeros(length(scan_els),maxNumElsInGroup);

% put el numbers into groups
for i=1:length(scan_els)
    allElConfigGroupsMat(i,1:length(scan_els{i}.el_idx)) = scan_els{i}.el_idx;
    
end

