function varOut = set_orientation(varIn, orientationSel)
% function varOut = SET_ORIENTATION(varIn, orientationSel)
%
% args: 
%   varIn = value
%   orientationSel = 'row' or 'col'

if strfind(orientationSel, 'col')
    if ~iscolumn(varIn )
        varOut = varIn';
    else
        varOut = varIn;
    end

elseif strfind(orientationSel, 'row')
       if ~isrow(varIn )
        varOut = varIn';
    else
        varOut = varIn;
    end
else
    error('orientation not understood.');
end


end