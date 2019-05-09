function plot_els_from_el_idx(selElIdx,varargin)
% plot the all electrodes in blue plus electrodes in ntk2 electrode config
% in red.
% function PLOT_ELS_FROM_EL_IDX(selElIdx,varargin)
% varargin
%   'text_only'
%   'all_els'
%   'marker_style'
%   'h_fig'
%   'markers_only'
%   'marker_face_color'
%   'marker_edge_color'

chipVerNo = 2;
plotElMarkers = 1;
markerStyle = [];
markerFaceColor = 'r';
markerEdgeColor = 'k';
plotText = 1;

% % check for arguments
hFig = [];
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'text_only')
            plotElMarkers = 0;
        elseif strcmp( varargin{i}, 'markers_only')
            plotText = 0;
        elseif strcmp( varargin{i}, 'all_els')
            all_els = varargin{i+1};
        elseif strcmp( varargin{i}, 'marker_style')
            markerStyle = varargin{i+1};   
        elseif strcmp( varargin{i}, 'h_fig')
            hFig = varargin{i+1};
        elseif strcmp( varargin{i}, 'marker_face_color')
            markerFaceColor = varargin{i+1};
        elseif strcmp( varargin{i}, 'marker_edge_color')
            markerEdgeColor = varargin{i+1};
        end
    end
end

if ~exist('all_els','var')
    all_els=hidens_get_all_electrodes(chipVerNo );
end

[junk, selElIdxLocalInds] = ismember(selElIdx, all_els.el_idx);
x = all_els.x(selElIdxLocalInds);
y = all_els.y(selElIdxLocalInds);

if ~isempty(hFig)
   figure(hFig); 
end

if plotElMarkers
    if isempty(markerStyle)
        
       plot(x,y,'s', 'MarkerEdgeColor',markerEdgeColor, ...
           'MarkerFaceColor',markerFaceColor)
    else
        plot(x,y,'s', markerStyle)
    end
end
% text(elConfigInfo.elX, elConfigInfo.elY,num2str([1:length(elConfigInfo.selElNumbers)]'))
if plotText
text(x+2,y-3, ...
    num2str(all_els.el_idx(selElIdxLocalInds)'),'FontWeight','bold',...
'Color','r')
end



end