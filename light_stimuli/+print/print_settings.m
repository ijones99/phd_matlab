function print_settings(settingsFileName)

dirName = 'settings';

load(dirName, settingsFileName);

fieldNames = fields(Settings);

for i=1:length(fieldNames)
    fieldInfo = getfield(Settings,  fieldNames{i});
    if isnumeric(fieldInfo)
        fieldInfoStr = num2str(fieldInfo);
    else
        fieldInfoStr = fieldInfo;
    end
    fprintf('%s\t\t%s\n', fieldNames{i},fieldInfoStr );
    
    
end





end

