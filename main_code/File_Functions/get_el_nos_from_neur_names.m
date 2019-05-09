function elNos = get_el_nos_from_neur_names( neurNames)

elNos = [];
 
if iscell(neurNames)
    for iNeur=1:length(neurNames) % go through all neuron names
        nLoc = strfind(neurNames{iNeur},'n');
        
        elNos(end+1) = str2num( neurNames{iNeur}(nLoc-4:nLoc-1) );
    end       
    
elseif isstr(neurNames)
    
    nLoc = strfind(neurNames,'n');
    elNos(end+1) = str2num( neurNames(nLoc-4:nLoc-1) )
else
    fprintf('Error: wrong electrode number name type or file does not exist.\n');
    
  
    
end



elNos = unique(elNos);  






end