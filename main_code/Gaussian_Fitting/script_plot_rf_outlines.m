rejectRF = [];
acceptRF = [];
acceptNeurons = {};
h=figure, hold on
percentEllipseInApertureThresh = 0.50;

dirName = 'Best_STA_Frames';
fileType = '*.mat';

fileNames = dir(fullfile(dirName, fileType)); %get file names

% compute circle
imWidth = 30;
apertureRatioToStim = (500/1200);
[circX circY] = circle([imWidth/2 imWidth/2],(apertureRatioToStim)*imWidth/2,30);
[circX circY] = poly2cw(circX, circY) ;
circArea = polyarea( circX, circY);

for i= 1:length(fileNames)
    load(fullfile(dirName,fileNames(i).name));
    [results p] = fit_ellipses_to_rf(bestSTAIm);
    [pCW1 pCW2] = poly2cw(p(:,1), p(:,2));
    ellipseArea = polyarea(pCW1, pCW2); % get ellipse area
    % get intersected area
    [xIntersection, yIntersection] = polybool('intersection', circX, circY, p(:,1), p(:,2));
    intersectionArea = polyarea(xIntersection, yIntersection);
    if intersectionArea/ellipseArea > percentEllipseInApertureThresh 
        plot(p(:,1), p(:,2),'LineWidth',2)
        acceptRF(end+1) = intersectionArea/ellipseArea*100;
        acceptNeurons{end+1} = strrep(fileNames(i).name,'.mat','');
        
    else
        rejectRF(end+1) = intersectionArea/ellipseArea*100;
    end
end

%

% plot circle
plot(circX, circY,'k','LineWidth',2), hold on