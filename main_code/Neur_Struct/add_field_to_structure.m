function structVar = add_field_to_structure(structVar, fieldName, Contents)
% function STRUCTVAR = add_field_to_structure(structVar, fieldName, Contents)
% 
% arguments:
%   structVar: structure to modify
%   fieldName: name of field to add
%   Contents: value to add to field
    
eval(sprintf('structVar.%s = Contents;', fieldName));





end