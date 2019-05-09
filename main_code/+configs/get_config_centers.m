function [configCtrX configCtrY] = get_config_centers(dirName, varargin)

fileNames = dir(fullfile(dirName,'*fi2el.nrk2'));


for i=1:length(fileNames)
    
    elConfigInfo = get_el_pos_from_nrk2_file('file_dir', dirName, 'file_name', ...
        fileNames(i).name);
    
    configCtrX(i) = mean(elConfigInfo.elX);
    configCtrY(i) = mean(elConfigInfo.elY);
    progress_info(i,length(fileNames));
end

end