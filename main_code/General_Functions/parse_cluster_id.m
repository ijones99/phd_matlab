function [elNo clusterNo] = parse_cluster_id(clusterID, outputType)

nLocation = strfind(clusterID,'n');

elNo = clusterID(1:nLocation-1);
if strcmp(outputType,'number')
    elNo = str2num(elNo);
end

clusterNo = clusterID(nLocation+1:end);
if strcmp(outputType,'number')
    clusterNo = str2num(clusterNo);
end



end