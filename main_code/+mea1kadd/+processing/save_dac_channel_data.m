function [ DAC] = save_dac_channel_data(expDate, fileNameRec, fileNameConfig, varargin)
% [DAC] = SAVE_DAC_CHANNEL_DATA(expDate, fileNameRec, varargin)
%
% Descr. can be used to load data for a batch
% one file is required.
%
% varargin:
%   force_reload;
%

numFrLoad = 2e4*60;
numCPUs = 7;

% init vars
forceReloadStr = '';

if ~iscell(fileNameRec)
   fileNameRecNew{1}= fileNameRec;
   clear fileNameRec 
   fileNameRec = fileNameRecNew;
   clear fileNameRecNew 
end

if ~iscell(fileNameConfig)
   fileNameConfigNew{1}= fileNameConfig;
   clear fileNameConfig 
   fileNameConfig = fileNameConfigNew;
   clear fileNameConfigNew 
end

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'force_reload')
            forceReloadStr ='force_reload';
        elseif strcmp( varargin{i}, 'num_cpus')
            numCPUs =varargin{i+1};
        end
    end
end

cpu.open_matlabpool(numCPUs);
%parfor
parfor iFile = 1:length(fileNameRec)
    
    mea1kadd.processing.save_dac_channel_data_single(expDate, fileNameRec{iFile}, fileNameConfig{iFile},forceReloadStr);
    
    progress_info(iFile, length(fileNameRec))
end

if length(fileNameRec) > 1
    DAC= [];
end

fprintf('Done\n')

end
