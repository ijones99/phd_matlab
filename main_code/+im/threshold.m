function imageOut= threshold(imageIn, varargin)
% imageOut= THRESHOLD(imageIn, varargin)
%
% varargin: 
%   'thresh_val' = absolute threshold

timesRms = [];
threshVal = [];
baselineMode = 'median';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'times_rms')
            timesRms  = varargin{i+1};
        elseif strcmp( varargin{i}, 'thresh_val')
            threshVal  = varargin{i+1};
        elseif strcmp( varargin{i}, 'baseline_mode')
            baselineMode  = varargin{i+1}; 
    end
end

imageOut = zeros(size(imageIn,1),size(imageIn,2));

if ~isempty(threshVal)
   I = find( imageIn > threshVal );
   imageOut(I) = 1;
    
end



end