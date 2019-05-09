function movie_and_response_viewer2(mov, repeats)
% Example code for uicontrol reference page
% get figure & screen sizes
% [left bottom width height]
% scrSize = get(0,'ScreenSize');
winSize = [482          53        1124        1081];

% settings for rasters
acqRate=2e4;
binSize = 0.0333; %Sec
spikeWinSize = 1;
periFrameTime = spikeWinSize/2;

% spiketrain info
repeatsSec = gdivide(repeats,acqRate); % change to seconds
spikeMat = ifunc.cell.cell2nanmat(repeatsSec); % create spike matrix

% circle
circCtr = [round(size(mov(1).cdata,1)/2) round(size(mov(1).cdata,2)/2)];
circRad = round((500/1.6)/2);

% setup figure
h = figure; hold on,
set(h,'Position', winSize);
hax = axes('Units','pixels');


% stimulus frames
numFrames = size(mov,2);

subplot(2,1,1)
image(mov(1).cdata);
imageHandle = get(gca,'Children');
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
val = round(get(hObj,'Value'));
% zlim(ax,[-val val]);

subplot(2,1,1)
currFrame = mov(val).cdata;
set(imageHandle ,'CData',currFrame);
drawnow;
hold on
circle(circCtr,circRad,40,'k--',3);
title(sprintf('Frame %d\n',val),'FontSize',18);
axis square

subplot(2,1,2,'replace');

ifunc.plot.movie.plot_raster_in_sel_time_window(val, ...
    numFrames,  spikeMat, acqRate, binSize, periFrameTime);

end
end