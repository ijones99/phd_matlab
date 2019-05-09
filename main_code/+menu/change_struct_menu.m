function myStruct = change_struct_menu(myStruct)
% myStruct = change_struct_menu(myStruct)
%
% Purpose change structure values using menu

userInput = 'x';
fldNames = fields(myStruct);

while userInput~='s'
    fprintf('\n');
    printout.struct_fields_and_vals(myStruct,'numbered');
    
    userInput = input('Select number to change or [s] to save >> ','s');
    if userInput ~= 's'
       fldValInput = input(sprintf('Enter field value for "%s" >> ',fldNames{str2num(userInput)}));
       myStruct = setfield(myStruct, fldNames{str2num(userInput)}, fldValInput);
        
    end
    fprintf('\n');
end


end