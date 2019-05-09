function [Xread DAC] = save_readout_channel_data(expDate, fileNameRec, fileNameConfig, readoutEls, varargin)
% [Xread DAC] = SAVE_READOUT_CHANNEL_DATA(expDate, fileNameRec, readoutEls, varargin)
%
% Descr. can be used to load data for a batch, or if the Xread and DAC for
% one file is required.
%
% varargin:
%   force_reload;
%   'num_frames' (to load)

numFrLoad = 2e4*88;
numCPUs = 7;


% init vars
forceReloadStr = '';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'force_reload')
            forceReloadStr ='force_reload';
        elseif strcmp( varargin{i}, 'num_frames')
            numFrLoad =varargin{i+1};
        end
    end
end

%parfor

parfor iFile = 1:length(fileNameRec)
    
    
    [Xread DAC] = mea1kadd.processing.save_readout_channel_data_single(...
        expDate, fileNameRec{iFile}, fileNameConfig{iFile}, readoutEls{iFile},...
        forceReloadStr, 'num_frames', numFrLoad);
    
    %     currFileNumStr =   fileNameRec{iFile}(end-14:end-7);
    %     currFileNum = str2num(strrep(currFileNumStr,'_',''));
    %
    %     if ~exist(sprintf('analyzed_data/f%d_X_read_el%d.mat',currFileNum, readoutEls{iFile}(1) ),'file')
    %
    %         [f_stim m_stim validIdx] = ...
    %             mea1kadd.load_mea1k_file_pointer(expDate, fileNameRec{iFile}, fileNameConfig{iFile});
    %
    %         currElIdx = find(m_stim.elNo==readoutEls{iFile});
    %
    %         % load channel
    %         fprintf('Loading readout data...\n');
    %         Xread = mea1kadd.loadMultipleCh(f_stim, currElIdx, 1, numFrLoad );
    %         if isempty(Xread)
    %             error('No data in channel.')
    %         end
    %         fprintf('Saving readout data...\n');
    %         save(sprintf('analyzed_data/f%d_X_read_el%d.mat',currFileNum, readoutEls{iFile}(1) ),'Xread')
    %
    %     end
    %     if ~exist(sprintf('analyzed_data/f%d_DAC.mat', currFileNum))
    %         % DAC
    %         fprintf('Loading DAC data...\n');
    %         DAC =f_stim.getDAC;
    %         fprintf('Saving DAC data...\n');
    %         save(sprintf('analyzed_data/f%d_DAC.mat', currFileNum),'DAC')
    %     end
    progress_info(iFile, length(fileNameRec))
end

if length(fileNameRec) > 1
    Xread = [];
    DAC= [];
end

fprintf('Done\n')

end
