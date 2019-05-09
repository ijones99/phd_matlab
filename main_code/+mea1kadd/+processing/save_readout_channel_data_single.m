function [Xread DAC] = save_readout_channel_data_single(expDate, fileNameRec, fileNameConfig, readoutEls, varargin)
% [Xread DAC] = SAVE_READOUT_CHANNEL_DATA_SINGLE(expDate, fileNameRec, readoutEls, varargin)
%
% Descr. can be used to load data for a batch, or if the Xread and DAC for
% one file is required.
%
% varargin:
%   force_reload;

numFrLoad = 2e4*90;


% init vars
doForceReload = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'force_reload')
            doForceReload =1;
        elseif strcmp( varargin{i}, 'num_frames')
            numFrLoad =varargin{i+1};
        end
    end
end



currFileNumStr =  fileNameRec(end-14:end-7);
currFileNum = str2num(strrep(currFileNumStr,'_',''));

if ~exist(sprintf('analyzed_data/f%d_X_read_el%d.mat',currFileNum, readoutEls(1) ),'file') | doForceReload
    
    warning('Forcing reload...')
    
    [f_stim m_stim validIdx] = ...
        mea1kadd.load_mea1k_file_pointer(expDate, fileNameRec, fileNameConfig);
    
    currElIdx = multifind(m_stim.elNo,readoutEls,'J');
    
    % load channel
    fprintf('Loading readout data...\n');
    Xread = mea1kadd.loadMultipleCh(f_stim, currElIdx, 1, numFrLoad );
    if isempty(Xread)
        error('No data in channel.')
    end
    fprintf('Saving readout data...\n');
    save(sprintf('analyzed_data/f%d_X_read_el%d.mat',currFileNum, readoutEls(1) ),'Xread')
    
else
    
    load(sprintf('analyzed_data/f%d_X_read_el%d.mat',currFileNum, readoutEls(1) ));
    
end
if ~exist(sprintf('analyzed_data/f%d_DAC.mat', currFileNum))
    % DAC
    fprintf('Loading DAC data...\n');
    DAC =f_stim.getDAC;
    fprintf('Saving DAC data...\n');
    save(sprintf('analyzed_data/f%d_DAC.mat', currFileNum),'DAC')
else
    
    load(sprintf('analyzed_data/f%d_DAC.mat', currFileNum))
    
end


end
