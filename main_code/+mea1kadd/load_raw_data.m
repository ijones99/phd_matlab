function [f m X Xfilt validIdx] = load_raw_data(expDate, fileNameSpont, ...
    fileNameConfig,elNums, numFr,varargin)
%  [f m X Xfilt validIdx] = LOAD_RAW_DATA(expDate, fileNameSpont, fileNameConfig,elNums, numFr)
% arguments
%   elNums: use "[]" for all

% filter settings
hpf = 100;
lpf= 900;
Fs = 2e4;
osf = 1;
dataDir = 'data';
confDir = 'config';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'data_dir')
            dataDir = varargin{i+1};
        elseif strcmp( varargin{i}, 'conf_dir')
            confDir = varargin{i+1};
        end
    end
end


% load data 
f = mea1k.file( fullfile('~/ln/mea1k_recordings/', expDate, dataDir, fileNameSpont));
f.getH5Info;
m = mea1k.map(fullfile('~/ln/mea1k_recordings/', expDate, confDir, fileNameConfig)  )
validIdx = find(m.mposx~=-1);

% sel channels for sorting:
if isempty(elNums)
     chIdx = find(~ismember(m.elNo,-1));
else
    chIdx = find(ismember(m.elNo,elNums));
end
% load data
X = mea1kadd.loadMultipleCh(f, chIdx, 1, numFr );

% filter data
hpf = 100;
lpf= 900;
Fs = 2e4;
osf = 1;
bp=fdesign.bandpass('n,f3dB1,f3dB2', 2, hpf, lpf, Fs*1);
filters.bbp=butter(bp);
% fvtool(filters.bbp);
Xfilt = filter(filters.bbp,X);



end
