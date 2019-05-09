function function(varargin)

% init vars
name1='Configs/'; name2={};

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'file_dir')
            name1 = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_name')
            name2 = varargin{i+1};
        end
    end
end


% OR
P.x = 'test';

P = mysort.util.parseInputs(P, varargin, 'error');
