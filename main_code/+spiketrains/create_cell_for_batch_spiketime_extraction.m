function fileInfoCell = create_cell_for_batch_spiketime_extraction(flistBase, flistNos, stimName, runNo)
% fileInfoCell = create_cell_for_batch_spiketime_extraction(...
% flistBase, flistNos, stimName, runNo)
%
% Purpose: create cell for running extracting timestamps
%
% Args:
%   flistBase: flist name without last number and file type
%   flistNos: array of flist values (for last number)
%   stimName: name of stimulus: e.g. wn_checkerboard
%   runNo: integer

fileInfoCell = {};
for i=1:length(flistNos)
    fileInfoCell{i}.runNo = runNo;
    fileInfoCell{i}.flist = ...
        sprintf('%s%d.stream.ntk',flistBase, flistNos(i));
    fileInfoCell{i}.stimNames = stimName;
    
end

for i=1:length(flistNos)
    spikesorting.extract_spiketimes_from_cl_files('input_file_info_cell',...
        fileInfoCell{i},'force')
    
end









end