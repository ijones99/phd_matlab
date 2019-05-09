function save_felix_sorting_to_sort_group_files(inputDate, dirName)
% function save_felix_sorting_to_sort_group_files(inputDate)
input1 = input('Are you sure you want to proceed with loading all data \nand converting each cell to a file?');

rgcs = load_felix_sorted_data(inputDate);
rgcs = rgcs.rgcs;
baseNum = '000';
numRgcs = length(rgcs);

textprogressbar('converting cells to files: ');
for i=1:length(rgcs)
    
    elNum = strcat(baseNum,num2str(i));
    neurClustMat = strcat('cl_',elNum(end-3:end));
    neurClustFileName = strcat('cl_',elNum(end-3:end),'.mat')
    eval([neurClustMat,'= rgcs{i}.spikes;']);
    eval([neurClustMat,'.elidx= rgcs{i}.el_idx;']);
    
    save(fullfile(dirName.cl, neurClustMat),neurClustMat);
    textprogressbar(100*i/numRgcs);
end
textprogressbar('Done.');

end