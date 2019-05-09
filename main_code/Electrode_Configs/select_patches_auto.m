function selectedPatches = select_patches_auto(numEls, elConfigInfo )
% FUNCTION SELECTEDPATCHES = SELECT_PATCHES_MANUALLY(NUMELS, NUMPATCHES ).
% Plots electrode configuration from nrk
% file
%

doPlot = 1;

% save var
elConfigInfoOrig = elConfigInfo;

% init vars
selectedPatches = {};

if doPlot
    % set up figure
    fullscreen = get(0,'ScreenSize');
    figure('Position',[0 -50 fullscreen(3) fullscreen(4)])
    hold on
    
    % plot electrodes
    plot(elConfigInfo.elX,elConfigInfo.elY,'*')
    set(gca,'YDir','reverse')
    text(elConfigInfo.elX+0.5, elConfigInfo.elY,num2str([elConfigInfo.selElNos']));
    title('Electrode Number')
end

while length(elConfigInfo.selElNos)>0
    
    % find starting point
    xUniqueVals = sort(unique(elConfigInfo.elX));
    yUniqueVals = sort(unique(elConfigInfo.elY));
    if and(length(xUniqueVals)>1,length(yUniqueVals)>1)
        xStartVal = xUniqueVals(2);
    else
        xStartVal = xUniqueVals(1);
    end  % these are the coordinates for the starting point
    
    % find all els where xStartVal is the start value
    xStartCoordInd = find(elConfigInfo.elX == xStartVal);
    % get associated y values
    sortedYCoordsWithXStartCoord = sort(elConfigInfo.elY(xStartCoordInd));
    
    if length(sortedYCoordsWithXStartCoord) > 1 % select the y coordinate value
        selectedYCoordVal = sortedYCoordsWithXStartCoord(2);
    else
        selectedYCoordVal = sortedYCoordsWithXStartCoord(1);
    end
    
    numberOfxStartCoordInd = find(elConfigInfo.elY(xStartCoordInd)==selectedYCoordVal);
    electrodeInd = xStartCoordInd(numberOfxStartCoordInd);
    
    
    if length(elConfigInfo.selElNos) >= numEls;
        [elsInPatch elsNumberInList]=get_closest_electrodes(elConfigInfo.selElNos(electrodeInd), elConfigInfo, numEls);
        selectedPatches{end+1}.selElNos = elsInPatch;
        selectedPatches{end}.elOrderNo = elsNumberInList;
        selectedPatches{end}.chNumbers = convert_elnos_to_chnos(elConfigInfo, selectedPatches{end}.selElNos);
        
        if doPlot
            plot(elConfigInfo.elX(elsNumberInList),elConfigInfo.elY(elsNumberInList ),'*', 'Color',[rand(1,3)],'LineWidth',2)
        end
        
        elConfigInfo = rm_element_of_elconfiginfo(elConfigInfo, elsInPatch);
    else
        return
    end
end


% find closest electrodes
[elsInPatch elsNumberInList]=get_closest_electrodes(elConfigInfo.selElNos(minInd), elConfigInfo, numEls)
[x,y] = ginput(1); % get input
[Y,minInd] = min(sqrt((elConfigInfo.elX-x).^2+(elConfigInfo.elY-y).^2)); % find closest electrode ind
% find closest electrodes
numEls = 7;
[elsInPatch elsNumberInList]=get_closest_electrodes(elConfigInfo.selElNos(minInd), elConfigInfo, numEls)
% plot selected in diff color
plot(elConfigInfo.elX(elsNumberInList),elConfigInfo.elY(elsNumberInList ),'*', 'Color',[rand(1,3)],'LineWidth',2)
% save to cell
selectedPatches{i}.selElNos = elsInPatch;
selectedPatches{i}.elOrderNo = elsNumberInList;
% find channel numbers


selectedPatches{i}.chNumbers = convert_elnos_to_chnos(elConfigInfo, elsInPatch);
% save file
mkdir('GenFiles');
elPatchFileNames = dir(fullfile('GenFiles','Selected_Patches*'));
if length(elPatchFileNames)~=0
    oldName = elPatchFileNames(end).name;
    newName = oldName
    newName(end-4) = oldName(end-4)+1;
    save(fullfile('GenFiles',newName), 'selectedPatches');
else
    save(fullfile('GenFiles','Selected_Patches_0.mat'), 'selectedPatches');
    
end
end