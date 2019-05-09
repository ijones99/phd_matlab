function elConfigInfoAll = get_all_config_info(dirName, varargin)

selConfig = [];
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'select_configs')
           selConfig = varargin{i+1};
        end
    end
end


filesInDir = dir(fullfile(dirName,'*.el2fi.nrk2'));

if isempty(selConfig)
   selConfig =  1:length(filesInDir);
end

for i=selConfig
    elConfigInfoAll{i}.number = i;
    elConfigInfoAll{i}.name = filesInDir(i).name;
    elConfigInfoAll{i}.info = get_el_pos_from_nrk2_file('file_dir', dirName, 'file_name', ...
        filesInDir(i).name);
    fprintf('%d/%d\n', i, length(filesInDir));
    
end

end