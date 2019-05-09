function DAC = load_dac_channel_data(expDate, fileNameRec, fileNameConfig, varargin)
% DAC = LOAD_READOUT_CHANNEL_DATA(expDate, fileNameRec, varargin)
%
% Use to get data that was loaded and saved using mea1kadd.processing.save_readout_channel_data


currFileNumStr =   fileNameRec(end-14:end-7);
currFileNum = str2num(strrep(currFileNumStr,'_',''));

% load DAC
fprintf('Loading readout data...\n');
load(sprintf('analyzed_data/f%d_DAC.mat', currFileNum))

fprintf('Done.\n');
end
