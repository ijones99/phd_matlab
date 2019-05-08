
% load locations used for data
load wnCheckBrdPosData_01 % wnCheckBrdPosData

% get all locations of interest
% outAuto{1}.xyRelLoc

numActualLoc = length(wnCheckBrdPosData);
numRFCtrs = length(profData); 

outMat = zeros(numRFCtrs, numActualLoc);

for i=1:numActualLoc %experimental
    for j=1: numRFCtrs % auto
        try
            outMat(j,i) =...
                geometry.get_distance_between_2_points(...
                wnCheckBrdPosData{i}.rfRelCtr(1),wnCheckBrdPosData{i}.rfRelCtr(2),...
                profData{j}.rfRelCtrFit(1), profData{j}.rfRelCtrFit(2));
        catch
            outMat(j,i) = -1;
        end
    end
end

% numRFCtrs X numActualLoc
% set to max distance for auto-comparisons
outMat(find(outMat==-1)) = max(max(outMat)); 
 % Find min distance for each measured ctr
[minDist idxWnCheckBrdPosData] = min(outMat,[],2);

coordPairings = [1:length(idxWnCheckBrdPosData)]';
coordPairings(:,2) = idxWnCheckBrdPosData';
% max distance threshold
distThreshold = 25;
[idxUnderMinRFtoSpotDist] = find(minDist < distThreshold);
coordPairings = coordPairings(idxUnderMinRFtoSpotDist,:);
coordPairings(:,3) = minDist(idxUnderMinRFtoSpotDist);


idxWnCheckBrdPosDataSel = idxWnCheckBrdPosData(idxUnderMinRFtoSpotDist);

% fprintf('Distances: ');
% round(minDist(idxUnderMinRFtoSpotDist))'

fprintf('idx_profData | idx_wnCheckBrdPosData | Distance(um)\n');
coordPairings

