function [xOut yOut  ] = scale_xy_pt(x_in, y_in, rangeX_in, rangeY_in, rangeX_out, rangeY_out, varargin)
% [xOut yOut  ] = SCALE_XY_PT(x_in, y_in, rangeX_in, rangeY_in, rangeX_out, rangeY_out)
%
% varargin
%   'y_axis_rev': 

yDirRev = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'y_axis_rev')
            yDirRev = 1;
            
        end
    end
end

if abs(rangeX_in(1))-abs(rangeX_in(2)) || abs(rangeY_in(1))-abs(rangeY_in(2)) 
    error('Not implemented.')
end


xOut = x_in*(diff(rangeX_out))/(diff(rangeX_in));

yOut = y_in*(diff(rangeY_out))/(diff(rangeY_in));

if yDirRev
    yOut=-yOut;
end



end