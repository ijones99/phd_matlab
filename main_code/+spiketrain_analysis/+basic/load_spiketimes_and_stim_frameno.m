function [spikeTrains stimChangeTs allTs ] = load_spiketimes_and_stim_frameno(flistName, elNo, clusNo,varargin )
% Function [spikeTrains frameno allTs ] = LOAD_SPIKETIMES_AND_STIM_FRAMENO(flistName, elNo, clusNo,varargin )
% 
% Purpose: load spiketrains and light timestamps for light stimuli. This
% data is generated with the ultra mega spikesorter.
%
% Varargin
%   'parapin_pulse_intervals': interval between parapin pulses (in order to
%   obtain light timestamps

framenoSeparationTimeSec = 0.5;
flistNo = 1;
flist = {};
flistName = '';
stimType = '';
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'parapin_pulse_intervals')
            framenoSeparationTimeSec = varargin{i+1};
        elseif strcmp( varargin{i}, 'flist_no')
                flistNo = varargin{i+1};        
        elseif strcmp( varargin{i}, 'flist')
                flist = varargin{i+1};
        elseif strcmp( varargin{i}, 'flist_name')
            flistName = varargin{i+1};
            elseif strcmp( varargin{i}, 'stim_type')
            stimType = varargin{i+1};
        end
    end
end




suffixName = strrep(flistName,'flist','');

if length(flist) > 1
    flistNew = flist{1};
    clear flist;
    flist = flistNew;
elseif iscell(flist)
    flistNew = flist{1};
    clear flist;
    flist = flistNew;
end

fprintf('flist = %s. \n', flist);
flistFileNameID = get_flist_file_id(flist, suffixName);

dirName = sprintf('../analysed_data/%s/',flistFileNameID);
fileName.frameno = sprintf('frameno_%s.mat', flistFileNameID);
% load framenos

    frameno.marchSqr_movBars = load(fullfile(dirName,fileName.frameno));


frameno.marchSqr_movBars  = frameno.marchSqr_movBars.frameno;
% load st_ file
fileName.marchSqr_movBars = sprintf('st_%dn%d',elNo, clusNo );
load(fullfile(dirName,'03_Neuron_Selection',fileName.marchSqr_movBars));
% get switch times

stimChangeTs = get_stim_start_stop_ts2(frameno.marchSqr_movBars,framenoSeparationTimeSec); 
% get location data
allTs = eval(sprintf('%s.ts;',fileName.marchSqr_movBars));
eval(sprintf('spikeTrainsConcatenated = round(%s.ts*2e4);',fileName.marchSqr_movBars));
adjustToZero = 1;
spikeTrains = extract_spiketrain_repeats_to_cell(spikeTrainsConcatenated, ...
    stimChangeTs,adjustToZero);


end