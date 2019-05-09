function varOut = load_single_var(dirName, fileName)
%  varOut = LOAD_SINGLE_VAR(dirName, fileName)

if nargin == 2
    fullPath = fullfile(dirName, fileName);
else
    fullPath = dirName;
end

% load data
loadedVar = load(fullPath);
loadedVarFields = fields(loadedVar);

% remove struct 
if length(loadedVarFields) > 1
    error('must have one variable in file.\n')
end

fieldName = loadedVarFields{1};
varOut = getfield ( loadedVar, fieldName );


end