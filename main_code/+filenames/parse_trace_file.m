function partsName = parse_trace_file( fileName ) 
% partsName = PARSE_TRACE_FILE( fileName ) 

partsName = {};
fileName = strrep(fileName,'_','');
fileName = strrep(fileName,'Trace','');

i=1;
partsName{i} = fileName(1:4);
fileName(1:4) = [];
i=i+1;

for j=i:6
    partsName{j} = fileName(1:2);
    fileName(1:2) = [];
end


end
