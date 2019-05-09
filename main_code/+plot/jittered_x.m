function jittered_x(meanX, y,varargin)
% jittered_x(meanX,y,varargin)
%
% varargin:
%   'jitter': +/- value: defaults to a quarter of the difference between
%   consecutive x values.


jitterRange = 0.25;


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
x = meanX*ones(size(y,1),size(y,2));
jitterOffsets = rand(size(y,1),size(y,2));
if isrow(x)
    xJit = scaledata([jitterOffsets -jitterRange jitterRange],-jitterRange,jitterRange);
else
    xJit = scaledata([jitterOffsets;-jitterRange; jitterRange],-jitterRange,jitterRange);
end

xJit(end-1:end)= [];

plot(x+xJit,y,'o', 'MarkerFaceColor', faceColor, 'MarkerEdgeColor', edgeColor,'MarkerSize',15);





end
