function [ctrX ctrY] = center_of_config(m, idx ) 
% [ctrX ctrY] = CENTER_OF_CONFIG(m, idx ) 
%
%
%

uniqueX = unique(m.mposx(idx));
uniqueY = unique(m.mposy(idx));

ctrX = mean(uniqueX );
ctrY = mean(uniqueY );



end
