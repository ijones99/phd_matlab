function [listMatches reverseMatExpNorm outputMat medianFootprints neurNames] = ...
    compute_footprint_similarity_for_two_groups(neurNames, stimNames)
% function [listMatches reverseMatExpNorm outputMat medianFootprints neurNames] = ...
%     compute_footprint_similarity_for_two_groups(neurNames, stimNames)
% This function returns a list of the best matches to the first group:
% Column 1 lists the neurons from group 1
% Column 2 and great lists the matching neurons in group 2, in order of
% decreasing matching percentage

dirName.profiles{1} = strcat('../analysed_data/profiles/',stimNames{1},'/');
dirName.profiles{2} = strcat('../analysed_data/profiles/',stimNames{2},'/');

stimNum = 1;
numNeurons{stimNum} = length(neurNames{stimNum});
textprogressbar('Load footprints for group 1: ')
for i=1:numNeurons{stimNum} 
    data = load_profiles_file(neurNames{stimNum}{i},'use_sep_dir',stimNames{stimNum} );
    stimStruct = getfield(data,stimNames{stimNum});
    medianFootprints{stimNum}{i} =  stimStruct.footprint_median;
    clear data stimStruct
    textprogressbar(100*i/numNeurons{stimNum});
end
textprogressbar('Finished loading footprints for group 1')

stimNum = 2;
numNeurons{stimNum} = length(neurNames{stimNum});
textprogressbar('Load footprints for group 2:')
for i=1:numNeurons{stimNum} 
    data = load_profiles_file(neurNames{stimNum}{i},'use_sep_dir',stimNames{stimNum} );
    stimStruct = getfield(data,stimNames{stimNum});
    medianFootprints{stimNum}{i} =  stimStruct.footprint_median;
    clear data stimStruct
    textprogressbar(100*i/numNeurons{stimNum});
end
textprogressbar('Finished loading footprints for group 2')

outputMat = ifunc.footprints.compare_footprints_two_sources(medianFootprints{1},medianFootprints{2});
reverseMat = 1-outputMat./max(max(outputMat));
reverseMatExp = exp(reverseMat);
reverseMatExpNorm = reverseMatExp/max(max(reverseMatExp));

listMatches = ifunc.footprints.find_closest_matching_footprints_from_sim_mat(reverseMatExpNorm,8);
fprintf('----------------------------------------\n');
fprintf('Matches between %s (main) and %s\n',stimNames{1},stimNames{2});
fprintf('----------------------------------------\n\n');

for i=1:length(neurNames{1})
   fprintf('%d) %s, %s (%3.0f), %s (%3.0f), %s (%3.0f), %s (%3.0f), %s (%3.0f), %s (%3.0f), %s (%3.0f), %s (%3.0f)\n', i,...
       neurNames{1}{listMatches(i,1)}, ...
       neurNames{2}{listMatches(i,2)},100*reverseMatExpNorm(i, listMatches(i,2)), ...  
       neurNames{2}{listMatches(i,3)},100*reverseMatExpNorm(i, listMatches(i,3)), ...
       neurNames{2}{listMatches(i,4)},100*reverseMatExpNorm(i, listMatches(i,4)), ...
       neurNames{2}{listMatches(i,5)},100*reverseMatExpNorm(i, listMatches(i,5)), ...
       neurNames{2}{listMatches(i,6)},100*reverseMatExpNorm(i, listMatches(i,6)), ...
       neurNames{2}{listMatches(i,7)},100*reverseMatExpNorm(i, listMatches(i,7)), ...
       neurNames{2}{listMatches(i,8)},100*reverseMatExpNorm(i, listMatches(i,8)), ...
       neurNames{2}{listMatches(i,9)},100*reverseMatExpNorm(i, listMatches(i,9)))
    
end

end