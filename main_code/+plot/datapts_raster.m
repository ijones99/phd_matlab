function datapts_raster(t, varargin)

% DATAPTS_RASTER(t, varargin)
lineHeight = 2;
lineOffset = 0;
yLimSizeTimesLineHt = 2;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
%         if strcmp( varargin{i}, 'sample_int')
%             sampleInt = varargin{i+1};

    end
end



nspikes   = numel(t); % number of elemebts / spikes

linePos = [-lineHeight/2 lineHeight/2]+lineOffset ;

for ii = 1:nspikes % for every spike
    line([t(ii) t(ii)],linePos,'Color','k'); % draw a black vertical line at time t (x) and at trial 180 (y)
end

% yLim
yLim = yLimSizeTimesLineHt*[-lineHeight/2 lineHeight/2]+lineOffset;
ylim(yLim)


end