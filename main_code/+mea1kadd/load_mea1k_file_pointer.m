function [f m validIdx] = load_mea1k_file_pointer(expDate, 	fileName, fileNameConfig,varargin)
% [f m validIdx] = LOAD_MEA1K_FILE_POINTER(expDate, 	fileName, fileNameConfig)
%
% varargin
%   'data_dir':
%   'config_dir':


dirData = 'data';
dirConf = 'config';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'data_dir')
            dirData = varargin{i+1};
        elseif strcmp( varargin{i}, 'conf_dir')
            dirConf = varargin{i+1};
        end
    end
end



% load data 
f = mea1k.file( fullfile('~/ln/mea1k_recordings/', expDate, dirData, fileName));
f.getH5Info;
m = mea1k.map(fullfile('~/ln/mea1k_recordings/', expDate, dirConf, fileNameConfig)  );
validIdx = find(m.mposx~=-1);




end
