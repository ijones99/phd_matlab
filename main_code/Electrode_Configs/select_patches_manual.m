function selectedPatches = select_patches_manual(numEls, numPatches, elConfigInfo )
% FUNCTION SELECTEDPATCHES = SELECT_PATCHES_MANUALLY(NUMELS, NUMPATCHES, elConfigInfo ). 
% Plots electrode configuration from nrk
% file
% 

% init vars
selectedPatches = {};

% set up figure
fullscreen = get(0,'ScreenSize');
figure('Position',[0 -50 fullscreen(3) fullscreen(4)])
hold on

plot(elConfigInfo.elX,elConfigInfo.elY,'*')
set(gca,'YDir','reverse')
text(elConfigInfo.elX+0.5, elConfigInfo.elY,num2str([elConfigInfo.selElNos']));
title('Electrode Number')

% select patches
for i=1:numPatches
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
end

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