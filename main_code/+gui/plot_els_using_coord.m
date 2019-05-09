function h = plot_els_using_coord(x,y,varargin)




doHoldon = 0;
all_els = [];
markerStyle = 'k.';
doOpenNewFig = 0;
h = [];
markerSize = 4;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'hold_on')
            doHoldon = 1;

        elseif strcmp( varargin{i}, 'marker_style')
            markerStyle = varargin{i+1};
        elseif strcmp( varargin{i}, 'marker_size')
            markerSize = varargin{i+1};
        elseif strcmp( varargin{i}, 'new_fig')
            doOpenNewFig = 1;
            
        end
    end
end

if doHoldon
    hold on
end


winSize = get(0,'ScreenSize');
set(gcf, 'Position',  winSize.*[ 1/3*winSize(3) 1 2/3 1])
plot(x,y,markerStyle,'MarkerSize',markerSize);

if doOpenNewFig == 1
    h = figure; hold on
end

axis square, set(gca,'YDir','reverse');
pause(0.1); % required or else the panel goes to one corner
end