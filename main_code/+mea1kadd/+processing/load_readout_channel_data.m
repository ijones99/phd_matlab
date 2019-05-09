function [Xread DAC ] = load_readout_channel_data(expDate, fileNameRec, fileNameConfig, readoutEls, varargin)
% [Xread DAC ] = LOAD_READOUT_CHANNEL_DATA(expDate, fileNameRec, readoutEls, varargin)
%
% Use to get data that was loaded and saved using mea1kadd.processing.save_readout_channel_data

numFrLoad = 2e4*60;

currFileNumStr =   fileNameRec(end-14:end-7);
currFileNum = str2num(strrep(currFileNumStr,'_',''));

% load data
fprintf('Loading recorded data...\n');
load(sprintf('analyzed_data/f%d_X_read_el%d.mat',currFileNum, readoutEls(1) ))

% load DAC
fprintf('Loading readout data...\n');
load(sprintf('analyzed_data/f%d_DAC.mat', currFileNum))

if size(Xread,2) ~= length(readoutEls)   
    error('Number of electrodes loaded does not equal number specified or channel empty.\n');
end
fprintf('Done.\n');
end
