function jittered_scatter(x,y,varargin)
% jittered_scatter(x,y,varargin)
%
% varargin:
%   'jitter': +/- value: defaults to a quarter of the difference between
%   consecutive x values.

if length(unique(x))>1
    jitterRange = abs(mean(diff(unique(x)))*0.25);
else
     jitterRange = 0.25;
end


faceColor = 'k';
edgeColor = 'k';
jitterAxis = 'x';

rng('shuffle');

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'jitter')
            jitterRange = varargin{i+1};
        elseif strcmp( varargin{i}, 'face_color')
            faceColor= varargin{i+1};
        elseif strcmp( varargin{i}, 'jitter_axis')
            jitterAxis = varargin{i+1};
            if jitterAxis == 'y'
                if length(unique(y))>1
                    jitterRange = abs(mean(diff(unique(y)))*0.25);
                else
                    jitterRange = 0.25;
                end

            end
        end
    end
end


% jitter
if jitterAxis == 'x'
    jitterOffsets = rand(size(x,1),size(x,2));
    if isrow(x)
        xJit = scaledata([jitterOffsets -jitterRange jitterRange],-jitterRange,jitterRange);
    else
        xJit = scaledata([jitterOffsets;-jitterRange; jitterRange],-jitterRange,jitterRange);
    end
    
    xJit(end-1:end)= [];
    
    plot(x+xJit,y,'o', 'MarkerFaceColor', faceColor, 'MarkerEdgeColor', edgeColor,'MarkerSize',15);
else
    jitterOffsets = rand(size(y,1),size(y,2));
    if isrow(y)
        yJit = scaledata([jitterOffsets -jitterRange jitterRange],-jitterRange,jitterRange);
    else
        yJit = scaledata([jitterOffsets;-jitterRange; jitterRange],-jitterRange,jitterRange);
    end
    
    yJit(end-1:end)= [];
    
    plot(x,y+yJit,'o', 'MarkerFaceColor', faceColor, 'MarkerEdgeColor', edgeColor);
    
    
    
end




end
