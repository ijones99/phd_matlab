function add_data_to_struct(structAdd, structName, savedStruct, pathName, fileName)

error('Not finished.\n')


savedStruct=[];

if exist(fullfile(pathName, fileName),'file')
    load(fullfile(pathName, fileName));
end

if isempty(savedStruct) % nothing saved; create new
    savedStruct = structAdd;
else % saved struct found
    flds = fields(structAdd);
    for i=1:length(flds) % field names
        
    end
end

% save data
save(fullfield(pathName, fileName), structName);

end
