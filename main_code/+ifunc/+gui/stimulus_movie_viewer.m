function stimulus_movie_viewer(frames, motionVector)
% Example code for uicontrol reference page
% get figure & screen sizes
% [left bottom width height]
scrSize = get(0,'ScreenSize');
winSize = [0 0 scrSize(3)*1/2 scrSize(4)*1/2];

% setup figure
h = figure;
set(h,'Position', winSize);
hax = axes('Units','pixels');


% stimulus frames
numFrames = size(frames,3);
axis square
imagesc(frames(:,:,1))
colormap(gray)
axis square

% Create a uicontrol object to let users change the colormap
% with a pop-up menu. Supply a function handle as the object's
% Callback:

% Add a different uicontrol. Create a push button that clears
% the current axes when pressed. Position the button inside
% the axes at the lower left. All uicontrols have default units
% of pixels. In this example, the axes does as well.
uicontrol('Style', 'pushbutton', 'String', 'Clear',...
    'Position', [20 20 50 20],...
    'Callback', 'cla');        % Pushbutton string callback
% that calls a MATLAB function


% Add a slider uicontrol to control the vertical scaling of the
% surface object. Position it under the Clear button.
% add slider
slider1=uicontrol(h,...
   'Style','slider',...
   'Min' ,1,'Max',numFrames, ...
   'Position',[0,0,winSize(3),20], ...
   'Value', numFrames,...
   'SliderStep',[1/(numFrames-1) 1], ...
   'BackgroundColor',[0.8,0.8,0.8],...
   'CallBack', {@surfzlim,hax});
% Slider function handle callback
% Implemented as a local function


function setmap(hObj,event) %#ok<INUSD>
% Called when user activates popup menu
val = get(hObj,'Value');
if val ==1
    colormap(jet)
elseif val == 2
    colormap(hsv)
elseif val == 3
    colormap(hot)
elseif val == 4
    colormap(cool)
elseif val == 5
    colormap(gray)
end
end

function surfzlim(hObj,event,ax) %#ok<INUSL>
% Called to set zlim of surface in figure axes
% when user moves the slider control
val = get(hObj,'Value');
% zlim(ax,[-val val]);

imagesc(frames(:,:,round(val)))
hold on
if val > 1
    plot(motionVector(val-1,1),motionVector(val-1,2),'*');
    plot(375, 375,'*r');
end
title(sprintf('Frame %d\n',val),'FontSize',18);
axis square
colormap(gray)
end
end