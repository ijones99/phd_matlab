function [stimFrameInfo Settings ] = load_settings(varargin)
% [stimFrameInfo Settings ] = load_settings
%
% varargin
%   stim_no (number from below)
%       1) wn_checkerboard
%       2) moving_bars
%       3) marching_sqr
%       4) spots
%       5) spots_with_moving_grating_background
%       6) flashing_sqr

selNo = [];

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'stim_no')
            selNo = varargin{i+1};

        end
    end
end

stimNames = {'wn_checkerboard', 'moving_bars', 'marching_sqr', 'spots', ...
    'spots_with_moving_grating_background', 'flashing_sqr'};
dirName = 'settings/';
if isempty(selNo)
    % print options
    for i=1:length(stimNames)
        fprintf('%d) %s\n', i, stimNames{i});
    end
    
    selNo = input('Enter selection number >> ');
end

% get file names for data
if strcmp(stimNames{selNo}, 'moving_bars')
    fileName_stimFrameInfo = 'stimFrameInfo_movingBar_2Reps.mat';
    fileName_Settings = 'stimParams_Moving_Bars_2Reps.mat';  
elseif strcmp(stimNames{selNo}, 'spots')
     fileName_stimFrameInfo = 'stimFrameInfo_spots.mat';
     fileName_Settings = 'stimParams_Flashing_Spots.mat';
elseif strcmp(stimNames{selNo}, 'marching_sqr')
    fileName_stimFrameInfo = 'stimFrameInfo_marchingSqr.mat';
    fileName_Settings = 'stimParams_Marching_Sqr.mat';
else
    error('No valid selection.\n');
end

% full file names
fileName_SettingsFull = fullfile(dirName, fileName_Settings);
fileName_stimFrameInfoFull = fullfile(dirName, fileName_stimFrameInfo);

% load data
if ~exist(fileName_SettingsFull,'file')
    warning(sprintf('File does not exist: %s\n',fileName_SettingsFull)) 
    Settings = [];
else
    load(fileName_SettingsFull);
    fprintf('Loaded %s\n',fileName_SettingsFull)
end
if ~exist(fileName_stimFrameInfoFull,'file')
    warning(sprintf('File does not exist: %s\n',fileName_stimFrameInfoFull)) 
    stimFrameInfo = [];
else
    load(fileName_stimFrameInfoFull);
    fprintf('Loaded %s\n',fileName_stimFrameInfoFull);
end


end