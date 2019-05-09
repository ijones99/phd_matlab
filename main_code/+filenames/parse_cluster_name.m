function [elIdx clusNo] = parse_cluster_name(clusterName)
% [elIdx clusNo] = PARSE_CLUSTER_NAME(clusterName)
nLoc = find(clusterName == 'n');

if length(nLoc) >1
   error('More than one n location found in name.\n'); 
end

numberChars = num2str([0:9]');

% find el number
atEnd = 0;
iAdd = 0;
while atEnd==0
    if nLoc-1-iAdd <= 0
         atEnd = 1;
         stepNo = iAdd;
    elseif isempty(find((ismember(numberChars,(clusterName(nLoc-1-iAdd))))))
         atEnd = 1;
         stepNo = iAdd;
     end
    iAdd = iAdd+1;
end
% idx for elno
locElIdx = nLoc-stepNo: nLoc-1; 
elIdx =  str2num(clusterName(locElIdx));

% find cluster number
atEnd = 0;
iAdd = 0;
while atEnd==0
    
    if  nLoc+1+iAdd>length(clusterName)
         atEnd = 1;
          stepNo = iAdd;
    elseif isempty(find((ismember(numberChars,(clusterName(nLoc+1+iAdd)))))) 
         atEnd = 1;
          stepNo = iAdd;
     end
    iAdd = iAdd+1;
end

% idx for clusNo
locClusNo = nLoc+1: nLoc+stepNo; 
clusNo =  str2num(clusterName(locClusNo));

end