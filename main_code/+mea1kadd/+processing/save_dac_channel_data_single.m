function save_dac_channel_data_single(expDate, fileNameRec, fileNameConfig, varargin)
% SAVE_DAC_CHANNEL_DATA_SINGLE(expDate, fileNameRec, varargin)
%
% Descr. can be used to load data for a batch, or if the DAC for
% one file is required.
%
% varargin:
%   force_reload;

numFrLoad = 2e4*60;


% init vars
doForceReload = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'force_reload')
            doForceReload =1;
        end
    end
end

currFileNumStr =  fileNameRec(end-14:end-7);
currFileNum = str2num(strrep(currFileNumStr,'_',''));

[f_stim m_stim validIdx] = ...
    mea1kadd.load_mea1k_file_pointer(expDate, fileNameRec, fileNameConfig);



if ~exist(sprintf('analyzed_data/f%d_DAC.mat', currFileNum)) | doForceReload
    % DAC
    fprintf('Loading DAC data...\n');
    DAC =f_stim.getDAC;
    fprintf('Saving DAC data...\n');
    save(sprintf('analyzed_data/f%d_DAC.mat', currFileNum),'DAC')
    
end


end
