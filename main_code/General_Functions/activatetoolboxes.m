function activatetoolboxes(varargin)
% activatetoolboxes()
% Flags
%   'num_tries'
%   'repeat_delay'
% these commands use the toolboxes needed for spikesorting; using them once activates the license:
%   statistics_toolbox
%   signal_toolbox
numberTries = 1;
repeatDelay = 1;

if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp(varargin{i},'num_tries')
            numberTries = varargin{i+1};
        elseif strcmp(varargin{i},'repeat_delay')
           repeatDelay =  varargin{i+1};
        end
        
        
    end
end

for i=1:numberTries
    try
        geomean(3);  %statistics_toolbox
        [k,r0] = ac2rc(.1); % signal_toolbox
        disp('License obtained');
    catch
       disp('Error getting toolbox license');
    end
    pause(repeatDelay)
end

end
