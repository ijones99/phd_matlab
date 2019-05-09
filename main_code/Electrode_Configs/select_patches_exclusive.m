function selectedPatches = select_patches_exclusive(numEls, elConfigInfo , varargin)
% FUNCTION SELECTEDPATCHES = SELECT_PATCHES_EXCLUSIVE(NUMELS, NUMPATCHES ).
% Selects patches for a quick scan of the electrodes (non-overlapping
% patches)

doPlot = 0;
outputPos = 0;

if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp(varargin{i},'do_plot')
            doPlot = 1;
        elseif strcmp(varargin{i},'xy_pos')
            outputPos = 1;
            
        end
    end
end
if outputPos
    all_els=hidens_get_all_electrodes(2);
end


% save var
elConfigInfoOrig = elConfigInfo;

% init vars
selectedPatches = {};

% set up figure
if doPlot
    fullscreen = get(0,'ScreenSize');
    figure('Position',[0 -50 fullscreen(3) fullscreen(4)])
    hold on
    
    % plot electrodes
    plot(elConfigInfo.elX,elConfigInfo.elY,'*')
    set(gca,'YDir','reverse')
    text(elConfigInfo.elX+0.5, elConfigInfo.elY,num2str([elConfigInfo.selElNos']));
    title('Electrode Number')
end
% get unique coordinates
uniqueXCoords = sort(unique(elConfigInfo.elX));uniqueYCoords = sort(unique(elConfigInfo.elY));
selectedPatches = {};

for ix = 2:3:length(uniqueXCoords)
    indsSelX = find( elConfigInfo.elX == uniqueXCoords(ix));
    
    for iy = length(uniqueYCoords)-2-mod(ix,2):-6:1 % takes into account whether ix is odd or even (with mod())
        
        
        indsSelY = find( elConfigInfo.elY == uniqueYCoords(iy));
        
        try
            mainElInd = intersect(indsSelX,indsSelY);
            [selectedPatches{end+1}.selElNos selectedPatches{end+1}.elOrderNo ]= ...
                get_closest_electrodes(elConfigInfo.selElNos(mainElInd), elConfigInfo, numEls);
            selectedPatches{end}.chNumbers = convert_elnos_to_chnos(elConfigInfo, selectedPatches{end}.selElNos);
            if outputPos
                posInfo = el2pos(selectedPatches{end}.selElNos, all_els);
                selectedPatches{end}.x = posInfo.x;
                selectedPatches{end}.y = posInfo.y;
            end
            
            if doPlot
                plot(elConfigInfo.elX(selectedPatches{end}.elOrderNo),elConfigInfo.elY(selectedPatches{end}.elOrderNo ),'*', 'Color',[rand(1,3)],'LineWidth',2)
                pause(.2)
            end
        end
        
    end
    
end


doContinue = 0;
if doContinue
    
    
    for iMainEl = 1: length(elConfigInfo.selElNos)
        
        [selectedPatches{iMainEl}.selElNos selectedPatches{iMainEl}.elOrderNo ]= ...
            get_closest_electrodes(elConfigInfo.selElNos(iMainEl), elConfigInfo, numEls);
        
        plot(elConfigInfo.elX(selectedPatches{iMainEl}.elOrderNo),elConfigInfo.elY(selectedPatches{iMainEl}.elOrderNo ),'*', 'Color',[rand(1,3)],'LineWidth',2)
        pause(.2)
        
    end
    
    % find closest electrodes
    [elsInPatch elsNumberInList]=get_closest_electrodes(elConfigInfo.selElNos(minInd), elConfigInfo, numEls)
    [x,y] = ginput(1); % get input
    [Y,minInd] = min(sqrt((elConfigInfo.elX-x).^2+(elConfigInfo.elY-y).^2)); % find closest electrode ind
    % find closest electrodes
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
else
    disp('Not finished with function...');
end
end