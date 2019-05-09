function neurNames = get_neur_names_from_el_inds( elInds, dirName, prefix, keepPlaceHolders)
% function neurNames = get_neur_names_from_el_nos( elNos, dirName, prefix)

if nargin < 4
    keepPlaceHolders = 0;
end
neuronNamesList = dir(fullfile(dirName, prefix));

if length(elInds) == 1  % if there is only one number
    
    neurNames = neuronNamesList(elInds).name;
    
else
    neurNames = {};
    
    for i=1:length(elInds)
        neurNames{i} = neuronNamesList(elInds(i)).name;
    end
end


end