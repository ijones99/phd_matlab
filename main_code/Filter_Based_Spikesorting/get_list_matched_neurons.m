function outputNeurList = get_list_matched_neurons(location)
S = csvimport('../analysed_data/refinfo/lookupTableNeurons.csv');
colNum = 0;

% obtain column number
if ischar(location)
    i=1;
    while and(i<=size(S,2),colNum==0)
        if strcmp(location,S{1,i})
            colNum = i;
        end
        i=i+1;
    end
else
    colNum = location;
end

if colNum == 0
   fprintf('location not found\n');
   return
end

 outputNeurList = {};

% go through all rows in column
for i=2:size(S,1)
    if ~isempty(S{i,colNum})
        outputNeurList{end+1} = S{i,colNum};
    end
    
    
end

end