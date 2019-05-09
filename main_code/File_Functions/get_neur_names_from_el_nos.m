function neurNames = get_neur_names_from_el_nos( elNos, dirName, prefix, keepPlaceHolders)
% function neurNames = get_neur_names_from_el_nos( elNos, dirName, prefix)

if nargin < 4
    keepPlaceHolders = 0;
end
neuronNamesList = dir(fullfile(dirName, prefix));

if length(elNos) == 1  % if there is only one number
    neurNames = '';
    for i=1:length(neuronNamesList)
        if sum(strfind(neuronNamesList(i).name, num2str(elNos)))
            neurNames = ...
                strrep(strrep(neuronNamesList(i).name,'.mat',''),'st_','');
            
        end
    end
else
    neurNames = {};
    for iEl = 1:length(elNos) % go through all electrode numbers
        fileFound = 0;
        for iNeurName =1:length(neuronNamesList) % go through neuron names
            
            if sum(strfind(neuronNamesList(iNeurName).name, num2str(elNos(iEl))))
                neurNames{end+1} = ...
                    strrep(strrep(neuronNamesList(iNeurName).name,'.mat',''),'st_','');
                fileFound = 1;
                
            elseif and(and(iNeurName==length(neuronNamesList), fileFound ==0), keepPlaceHolders )
                neurNames{end+1}={};
            end
        end
    end
    
end
neurNamesNew = {};
for i=1:length(neurNames)
    if ~isempty(neurNames{i})
        neurNamesNew{end+1} = neurNames{i};
    end
    
end
neurNames = neurNamesNew;
end