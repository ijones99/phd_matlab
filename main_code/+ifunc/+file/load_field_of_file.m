function selField = load_field_of_file(selDirName, fileNamePhrase, fieldName, varargin)
% selField = load_field_of_file(selDirName, fileNamePhrase, fieldName, varargin)
% P.file_type = '';
% P.prefix ='';


P.file_type = '';
P.prefix ='';
P.suffix ='';
P = mysort.util.parseInputs(P, varargin, 'error');

fileName = dir(fullfile(selDirName,strcat(P.prefix, '*', fileNamePhrase,'*',P.suffix,'*',P.file_type)));

loadedFile = load(fullfile(selDirName,fileName(1).name));
loadedStructName = fields(loadedFile);
loadedStruct = getfield(loadedFile,loadedStructName{1});

selField = getfield(loadedStruct,fieldName);

end