function [minVal maxVal] = getminmax(values, dimension)
% function [minVal maxVal] = getminmax(values, dimension)

if nargin<2
    if isrow(values)
        dimension = 2;
    else
        dimension = 1;
    end
    
end

minVal = min(values,[],dimension);
maxVal = max(values,[],dimension);


end