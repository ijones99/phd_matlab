function movie_and_response_viewer_dual2(mov, repeats,repeats2)
% Example code for uicontrol reference page
% get figure & screen sizes
% [left bottom width height]
% scrSize = get(0,'ScreenSize');
winSize = [482          53        1124        1081];
global val
global scrollIterationNum
global autoScrollSpeed
val = 1;
scrollIterationNum = 50;
autoScrollSpeed = 1/40;
% settings for rasters
acqRate=2e4;
binSize = 1/40; %Sec
spikeWinSize = 2;
periFrameTime = spikeWinSize/2;

% spiketrain info
repeatsSec = gdivide(repeats,acqRate); % change to seconds
spikeMat = ifunc.cell.cell2nanmat(repeatsSec); % create spike matrix
repeatsSec2 = gdivide(repeats2,acqRate); % change to seconds
spikeMat2 = ifunc.cell.cell2nanmat(repeatsSec2); % create spike matrix

% circle
circCtr = [round(size(mov(1).cdata,1)/2) round(size(mov(1).cdata,2)/2)];
circRad = round((500/1.6)/2);

% middle line
frameLocLine = [-36 36];

% setup figure
h = figure; hold on,
set(h,'Position', winSize);
hax = axes('Units','pixels');


% stimulus frames
numFrames = size(mov,2);

% timestamps for each frame
frameTimeStamps = [0:binSize:numFrames*binSize-binSize];

subplot(5,1,1:3)
xlim([0 size(mov(1).cdata,1)]);
ylim([0 size(mov(1).cdata,2)]);
colormap(gray)


image(mov(1).cdata);
imageHandle = get(gca,'Children');
draw_frame_and_raster(1),  ylim([-36 36])



% Create a uicontrol object to let users change the colormap
% with a pop-up menu. Supply a function handle as the object's
% Callback:

button1 = uicontrol('Style', 'pushbutton', 'String', 'Scroll_Forwards',...
    'Position', [20 20 100 20],...
    'Callback', {@autoscroll,hax});        

edit1 = uicontrol('Style', 'edit', 'Position', [150 20 100 20],...
    'Callback', {@scroll_iterations,hax}); 

edit2 = uicontrol('Style', 'edit', 'Position', [260 20 50 20],...
    'Callback', {@auto_scroll_speed,hax},'String','speed'); 



% add slider
slider1=uicontrol(h,...
    'Style','slider',...
    'Min' ,1,'Max',numFrames, ...
    'Position',[0,0,winSize(3),20], ...
    'Value', 1,...
    'SliderStep',[1/(numFrames-1) 1], ...
    'BackgroundColor',[0.8,0.8,0.8],...
    'CallBack', {@surfzlim,hax});
% Slider function handle callback
% Implemented as a local function

    function scroll_iterations(hObj,event,ax)
        scrollIterationNum = str2num(get(hObj,'String'));
        for i=val:val+scrollIterationNum;
            draw_frame_and_raster(i);
            set(slider1,'Value',i);
            pause(autoScrollSpeed);
        end
        val =val+scrollIterationNum;
    end
  function auto_scroll_speed(hObj,event,ax)
      autoScrollSpeed = 1/str2num(get(hObj,'String'));
      
  end
    function autoscroll(hObj,event,ax)
        for i=val:val+scrollIterationNum;
            draw_frame_and_raster(i);
            set(slider1,'Value',i);
            pause(autoScrollSpeed);
        end
        val =val+scrollIterationNum;
    end

    function surfzlim(hObj,event,ax) %#ok<INUSL>
        % Called to set zlim of surface in figure axes
        % when user moves the slider control
        val = round(get(hObj,'Value'));
        % zlim(ax,[-val val]);
        draw_frame_and_raster(val)
    end

    function draw_frame_and_raster(val)
        
        subplot(5,1,1:3)
        currFrame = mov(val).cdata;
        set(imageHandle ,'CData',currFrame);
%         drawnow;
        hold on
        circle(circCtr,circRad,40,'k-',3);
        title(sprintf('Frame %d (%2.3f sec)',val,frameTimeStamps(val)),'FontSize',18);
        axis square
        
        subplot(5,1,4:5,'replace');
        hold on
        ifunc.plot.movie.plot_raster_in_sel_time_window(val, ...
            numFrames,  spikeMat, acqRate, binSize, periFrameTime,frameTimeStamps);
        ifunc.plot.movie.plot_raster_in_sel_time_window(val, ...
            numFrames,  spikeMat2, acqRate, binSize, periFrameTime,frameTimeStamps,'.r',-35);
        ylim([-36 36])
        
        plot([0;0], [-36 36],'LineWidth',1,'Color','k')
        
    end

end