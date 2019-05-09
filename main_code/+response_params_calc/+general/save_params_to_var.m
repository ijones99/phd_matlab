function save_params_to_var(readDir, readSearchStr, writeDir, writeFileName)
% SAVE_PARAMS_TO_VAR(readDir, readSearchStr, writeDir, writeFileName)
%
%

fileNames = dir(fullfile(readDir, readSearchStr));

paramsAll.names = {}
paramsAll.values = zeros(length(fileNames), 5);
paramsAll.runNo = [];
paramsAll.date = {};

for i=1:length(fileNames)
     neurInfo = file.load_single_var(readDir, fileNames(i).name) ;
     
     paramsAll.names{i} = neurInfo.wn_checkerbrd.clusterName;
     paramsAll.runNo(i) = str2num(fileNames(i).name(5:6));
     paramsAll.date{i} = get_dir_date;
     if isfield(neurInfo, 'paramOut')
         
         % cluster name
         
         % fields
         
         fieldNames = fields(neurInfo.paramOut);
         % param values
         for iPar = 1:length(fieldNames)
             paramsAll.values(i,iPar) = ...
                 getfield(neurInfo.paramOut,fieldNames{iPar});
         end
     else
         warning('Error with (%d) %s \n', i,  fileNames(i).name);
     end
end

paramsAll.fieldNames = fieldNames;

overWriteData = 'y';
if exist(fullfile(writeDir,writeFileName))
   warning('File exists.\n') 
   overWriteData = input('Overwrite data? [y/n/(a)ppend] >> ','s');
end

if strcmp(overWriteData,'y')
    save(fullfile(writeDir,writeFileName), 'paramsAll');
    warning('Overwriting.\n')
elseif strcmp(overWriteData,'a')
    fprintf('Appending.\n')
    old = load(fullfile(writeDir,writeFileName));
    paramsAll.names = [paramsAll.names(:); old.paramsAll.names(:)];
    paramsAll.runNo = [paramsAll.runNo, old.paramsAll.runNo];
    paramsAll.date = [paramsAll.date, old.paramsAll.date];
    paramsAll.values = [paramsAll.values; old.paramsAll.values];
    save(fullfile(writeDir,writeFileName), 'paramsAll');
else
    warning('Nothing done.\n');
end


end