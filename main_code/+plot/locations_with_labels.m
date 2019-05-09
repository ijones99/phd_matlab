function locations_with_labels(xyCol, textCol)
% locations_with_labels(xyCol, textCol)
%
% Purpose: use with retinal ganglion cell (RGC) receptive field centers
% in order to visualize where the centers are located.s

xyOff = [2 2];

plot(xyCol(:,1),xyCol(:,2),'bx');
text(xyCol(:,1)+xyOff(1),xyCol(:,2)+xyOff(2),textCol);




end