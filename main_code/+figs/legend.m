function plot_legend(txtStr,colorMap, xyLoc,varargin)
% PLOT_LEGEND(txtStr,colorMap, xyLoc)

markerStyle = 's-';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'marker_style')
            markerStyle  = varargin{i+1};
         end
    end
end

if isstruct(xyLoc)
    if ~isfield(xyLoc,'x') & ~isfield(xyLoc,'y')
        error('must have x and y');
    else
        selXYLoc(:,1) = xyLoc.x;
        selXYLoc(:,2) = xyLoc.y;
    end
elseif ismatrix(xyLoc)
    selXYLoc = xyLoc;
end

repMatX = repmat(selXYLoc(1),2,size(colorMap,1));
repMatY = repmat(selXYLoc(2),2,size(colorMap,1));
colormap(colorMap)
plot(repMatX,repMatY,markerStyle)




legend(mats.set_orientation(txtStr,'col'))

end