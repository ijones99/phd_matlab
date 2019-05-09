%Circle with radius centered at 40,40 in an 80x80image
frameEdgeLength = 80;

% create circle in center; center has ones and surround has zeros
[rr cc] = meshgrid(1:frameEdgeLength);
C = sqrt((rr-round(frameEdgeLength/2)).^2+ ... 
    (cc-round(frameEdgeLength/2)).^2)<=20;

% change data type
C = uint8(C);

% get indices for surround
indSurround = find(C==0);

% shuffle the indices for the surround 
indSurrShuffled = randperm(length(indSurround));

C([indSurround]) = C(indSurround(indSurrShuffled));
imagesc(C)

