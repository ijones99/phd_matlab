function elConfigInfo = rm_element_of_elconfiginfo(elConfigInfo, elNumber)
% function elConfigInfo = rm_element_of_elconfiginfo(elConfigInfo,
% elNumber)


% get field names
structFieldNames= fieldnames(elConfigInfo);

% fields to be removed
fieldNumbers = [1 2 3 7];

% find index corr. to electrode number
for iElNumber = 1:length(elNumber)
    
    I = find(elConfigInfo.selElNos == elNumber(iElNumber));
    
    
    for i=1:length(fieldNumbers)
        eval(['elConfigInfo.',structFieldNames{fieldNumbers(i)}, '(',num2str(I),')=[];'])
        
        
    end
    
end
end