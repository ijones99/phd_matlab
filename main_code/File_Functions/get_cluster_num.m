function clusterNum = get_cluster_num(neuronName)

nLoc = strfind(neuronName,'n');
clusterNum = str2num(neuronName(nLoc+1:end));



end