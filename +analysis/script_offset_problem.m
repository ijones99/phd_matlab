coord.x = [];
coord.y = [];
for i=1:length(wnCheckBrdPosData)
    coord.x(i) = wnCheckBrdPosData{i}.rfAbsCtr(1);
    coord.y(i) = wnCheckBrdPosData{i}.rfAbsCtr(2);
end
coordAdj.x = coord.x;
coordAdj.y = coord.y-178;
%%
allCombos = combnk(1:length(coord.y),2);

x = coord.x(allCombos(:,1));
y = coord.y(allCombos(:,1));
x1 = coordAdj.x(allCombos(:,2));
y1 = coordAdj.y(allCombos(:,2));

distances = geometry.get_distance_between_2_points(x,y,x1,y1);

offcenterThresh = 30
distances(pairsUnderThresh); %um
pairsUnderThresh = find(distances < offcenterThresh);
distances(pairsUnderThresh);
substitutionPairs = allCombos(pairsUnderThresh,:);

for i=1:size(substitutionPairs,1)
    currClusNameFrom = wnCheckBrdPosData{substitutionPairs(i,1)}.fileName;
    currClusNameTo = wnCheckBrdPosData{substitutionPairs(i,2)}.fileName;
    flistFrom = wnCheckBrdPosData{substitutionPairs(i,1)}.flist{1}(end-22:end-11);
    flistTo = wnCheckBrdPosData{substitutionPairs(i,2)}.flist{1}(end-22:end-11);
    
    fprintf('%s to %s: replace %s with %s (dist %3.0f)\n', currClusNameFrom,currClusNameTo, flistFrom, flistTo,...
        distances(pairsUnderThresh(i)));
    
end



