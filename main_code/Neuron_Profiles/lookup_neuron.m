function outputNeurName = lookup_neuron(neurName, location)
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


% go through all neuron names in this row
rowNum = 0;
i=1;
while and(i<=size(S,1),rowNum==0)
    if strcmp(neurName,S{i,colNum})
        rowNum = i;
    end
       
    i=i+1;
end


if rowNum == 0
   fprintf('neuron not found\n');
   return
end

outputNeurName = S{rowNum, 1};

end