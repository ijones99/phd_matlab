function points(t,varargin)
% POINTS(t)
    

ptsOffset = 0;
plotColor = 'k';
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'color')
            plotColor = varargin{i+1};
        elseif strcmp( varargin{i}, 'offset')
            ptsOffset = varargin{i+1};
        end
    end
end



ptsPos = ptsOffset*ones(1,numel(t));

plot([t],ptsPos,'.','Color',plotColor ); % draw a black vertical line at time t (x) and at trial 180 (y)



end