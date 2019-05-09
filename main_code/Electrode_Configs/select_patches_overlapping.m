function selectedPatches = select_patches_overlapping(numEls, elConfigInfo )
% FUNCTION SELECTEDPATCHES = SELECT_PATCHES_MANUALLY(NUMELS, NUMPATCHES ).
% Plots electrode configuration from nrk
% file
%
doPlot = 0;
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
for iMainEl = 1: length(elConfigInfo.selElNos)
    
    [selectedPatches{iMainEl}.selElNos selectedPatches{iMainEl}.elOrderNo ]= ...
        get_closest_electrodes(elConfigInfo.selElNos(iMainEl), elConfigInfo, numEls);
    selectedPatches{iMainEl}.chNumbers = convert_elnos_to_chnos(elConfigInfo, selectedPatches{iMainEl}.selElNos);
    plot(elConfigInfo.elX(selectedPatches{iMainEl}.elOrderNo),elConfigInfo.elY(selectedPatches{iMainEl}.elOrderNo ),'*', 'Color',[rand(1,3)],'LineWidth',2)
%    pause(.2) 
    
end

doContinue = 0;
if doContinue
% find closest electrodes

[elsInPatch elsNumberInList]=get_closest_electrodes(elConfigInfo.selElNos(minInd), elConfigInfo, numEls)
[x,y] = ginput(1); % get input
[Y,minInd] = min(sqrt((elConfigInfo.elX-x).^2+(elConfigInfo.elY-y).^2)); % find closest electrode ind
% find closest electrodes

[elsInPatch elsNumberInList]=get_closest_electrodes(elConfigInfo.selElNos(minInd), elConfigInfo, numEls)
if doPlot
    % plot selected in diff color
    plot(elConfigInfo.elX(elsNumberInList),elConfigInfo.elY(elsNumberInList ),'*', 'Color',[rand(1,3)],'LineWidth',2)
end
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
else
   disp('Not finished with function...'); 
end
end