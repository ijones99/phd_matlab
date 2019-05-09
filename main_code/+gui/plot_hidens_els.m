function h = plot_hidens_els(varargin)




doHoldon = 0;
chipVer = 2;
all_els = [];
markerStyle = 'k.';
doOpenNewFig = 0;
h = [];
markerSize = 4;
selColor = [];
selFaceColor = [];
doKeepWinSize = 0;


% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'hold_on')
            doHoldon = 1;
        elseif strcmp( varargin{i}, 'chip_ver')
            chipVer = varargin{i+1};
        elseif strcmp( varargin{i}, 'all_els')
            all_els = varargin{i+1};
        elseif strcmp( varargin{i}, 'marker_style')
            markerStyle = varargin{i+1};
        elseif strcmp( varargin{i}, 'marker_size')
            markerSize = varargin{i+1};
        elseif strcmp( varargin{i}, 'new_fig')
            doOpenNewFig = 1;
        elseif strcmp( varargin{i}, 'color')
            selColor = varargin{i+1};
        elseif strcmp( varargin{i}, 'facecolor')
            selFaceColor  = varargin{i+1};
        elseif strcmp( varargin{i}, 'keep_win_size')
            doKeepWinSize = 1;
        end
    end
end

if doHoldon
    hold on
end

if isempty(all_els)
    all_els=hidens_get_all_electrodes(chipVer);
end
if ~doKeepWinSize
    winSize = get(0,'ScreenSize');
    set(gcf, 'Position',  winSize.*[ 1/3*winSize(3) 1 2/3 1])
end
if ~isempty(selColor) & ~isempty(selFaceColor)
    plot(all_els.x,all_els.y,markerStyle,'MarkerSize',markerSize,'Color', ...
        selColor,'MarkerFaceColor', selFaceColor);
elseif ~isempty(selColor)
    plot(all_els.x,all_els.y,markerStyle,'MarkerSize',markerSize,'Color', selColor);
    
    

else
    plot(all_els.x,all_els.y,markerStyle,'MarkerSize',markerSize);
end
if doOpenNewFig == 1
    h = figure; hold on
end

axis square, set(gca,'YDir','reverse');
pause(0.1); % required or else the panel goes to one corner
end