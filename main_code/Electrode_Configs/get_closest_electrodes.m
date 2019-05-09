function [elsInPatch elsNumberInList]=get_closest_electrodes(mainElIdNumber, elConfigInfo, numEls)

% return the distance and the index for the closest electrode
% 
% args:
%       x: is a list of x-coordinates
%       y: is a list of y-coordinates
%       mainElNo: electrode in middle
%       elConfigInfo: obtain from get_el_pos_from_nrk2_file.m
%                         
%       numEls: number els in patch
%            
%

x = elConfigInfo.elX;
y = elConfigInfo.elY;

len=length(x);
if length(y)~=len
    error('x and y must have the same length')
end

totalNumElsVector=1:length(x);

% find list number for main electrode (what number in the list it is)
mainEl.listNumber = find(elConfigInfo.selElNos == mainElIdNumber);

% get euclidian distances to main electrode
euclDist=sqrt((elConfigInfo.elX(mainEl.listNumber)-elConfigInfo.elX).^2 + ...
    (elConfigInfo.elY(mainEl.listNumber)-elConfigInfo.elY).^2);

% sort by distance
[dist2 euclDistInd] = sort(euclDist);

% get electrode Nos in the patch
elsInPatch = elConfigInfo.selElNos([euclDistInd(1:numEls)]);
elsNumberInList = euclDistInd(1:numEls);


end











