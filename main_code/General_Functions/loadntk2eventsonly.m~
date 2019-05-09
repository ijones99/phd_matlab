function loadntk2eventsonly(varargin)

% ----------------- Argument settings ----------------- %
%minutes to load
minutesToLoad =30/60;
enableSaveData = 1;
electrodeOfInterest = [];
channelsToLoad = 5;
flistName = [];

if ~isempty(varargin)
    i = 1;
    while i<=length(varargin)
        if strcmp('enable_save_data',varargin{i})
            enableSaveData = 1;
            fprintf('loadntk2eventsonly: save data enabled\n');
        elseif strcmp('electrode',varargin{i})
            i = i+1;
            electrodeOfInterest = varargin{i};
            fprintf('loadntk2eventsonly: electrode %d selected\n',electrodeOfInterest );
        elseif strcmp('minutes_to_load',varargin{i})
            i = i+1;
            minutesToLoad = varargin{i};
            fprintf('loadntk2eventsonly: load %d minutes\n',minutesToLoad);
        elseif strcmp('total_channels_to_load',varargin{i})
            i = i+1;
            channelsToLoad = varargin{i};
            fprintf('loadntk2eventsonly: load %d channels\n',channelsToLoad);
        elseif strcmp('flist_name',varargin{i})
            i = i+1;
            flistName = varargin{i};
            fprintf('loadntk2eventsonly: flist %s\n',flistName);
        else
            fprintf('loadntk2eventsonly: unknown argument\n');
        end
        i = i+1;
    end
end

if isempty(flistName)
    flistName = 'flist_example';
end

if isempty(electrodeOfInterest)
    electrodeOfInterest = 5358;
    fprintf('loadntk2eventsonly: electrode %d selected\n',electrodeOfInterest );
end

% ----------------- Constant settings ----------------- %
%pretime (event) and posttime (event) in frames
preTime_ms = 0.002;
postTime_ms = 0.0015;
%# surrounding electrodes
number_els=channelsToLoad-1;
load electrode_list

flist={};
eval([flistName]); %flist
k=1; % file number

maxChunkSize = 2;
if minutesToLoad<maxChunkSize
    loadingChunkSize = minutesToLoad; %minutes
else
    loadingChunkSize = 2;
end
siz=20000*60*loadingChunkSize; % frames to load

% over-ride
% loadingChunkSize = 1;

% electrodeOfIntereeueust = 5358;

% ----------------- Option settings ----------------- %
loadAllChannels = 0 ;
doPlot          = 0 ;
comprehensiveData = 0; %include temperature, dac1, etc.?

ntk=initialize_ntkstruct(flist{k},'hpf', 500, 'lpf', 3000);

[ntk2 ntk]=ntk_load(ntk, 2); % images_v1 argument to load ts of image

%     ntk2=detect_valid_channels(ntk2,1); % remocmosmea_recordingsve bad channels and compute the noise levels
%no filtering --> [ntk2 ntk]=ntk_load(ntk, siz, 'nofiltering');
ntk2ChannelLookup.el_idx = ntk2.el_idx;
ntk2ChannelLookup.channel_nr = ntk2.channel_nr;
% save ntk2ChannelLookup ntk2ChannelLookup

% ----------------- Go through chunks of data ----------------- %
% ----------------- Load data ----------------- %
for i = 1:floor(minutesToLoad/loadingChunkSize)
    clear ntk2
    try
%         load electrode_list;
%         load ntk2ChannelLookup;
        if i==1
            ntk=initialize_ntkstruct(flist{k},'hpf', 500, 'lpf', 3000);
        end
        %use convertelectrodestochannels to determine which elecrodes to enter,
        %given one electrode of interest.
        
        
        if number_els >0
            surroundingElectrodeNtk2Position = convertelectrodestochannels(electrodeOfInterest, electrode_list, ntk2ChannelLookup, number_els)
        else
            surroundingElectrodeNtk2Position = electrodeOfInterest;
        end
        [ntk2 ntk]=ntk_load(ntk, siz, 'keep_only', ntk2ChannelLookup.channel_nr(surroundingElectrodeNtk2Position), 'images_v1');
        ntk2=detect_valid_channels(ntk2,1); % remocmosmea_recordingsve bad channels and compute the noise levels
        [B XI]=sort(ntk2.el_idx);
        ch_idx=XI;
    catch
        disp('Error loading ntk2 file');
        break
    end
    




% % hack, with this function "reextract_aligned_traces" crashes...to be fixed
% ntk2.frame_no=[];
% ntk2.frame_no=[1:length(ntk2.sig)];

%get indices for where spikes are
preTime = preTime_ms*ntk2.sr;
postTime = postTime_ms*ntk2.sr;

% ----------------- obtain the event timestamps by threshholding ----------------- %
[traceTimeStamps, eventTimeStamps] = geteventtimestamps(ntk2.sig,preTime, postTime, 20000, 4);

% ----------------- Apply trace timestamps to ----------------- %
if comprehensiveData == 1
    ntk2.temp = ntk2.temp(traceTimeStamps);
    ntk2.dc = ntk2.dc(traceTimeStamps);
    ntk2.dac1 = ntk2.dac1(traceTimeStamps);
    ntk2.dac2 = ntk2.dac2(traceTimeStamps);
    ntk2.digibits = ntk2.digibits(traceTimeStamps);
end

ntk2.sig = ntk2.sig(traceTimeStamps,:)
ntk2.frame_no= ntk2.frame_no(1,traceTimeStamps);
ntk2.eventTimeStamps = eventTimeStamps;


% ----------------- Append data to a new ntk2 structure ----------------- %
if i == 1
    ntk2Merged = ntk2;
    ntk2Merged.preTime = preTime;
    ntk2Merged.postTime = postTime;
else
    
    if comprehensiveData == 1
        ntk2Merged.temp = [ntk2Merged.temp; ntk2.temp];
        ntk2Merged.dc = [ntk2Merged.dc; ntk2.dc];
        ntk2Merged.dac1 = [ntk2Merged.dac1; ntk2.dac1];
        ntk2Merged.dac2 = [ntk2Merged.dac2; ntk2.dac2];
        ntk2Merged.digibits = [ntk2Merged.digibits; ntk2.digibits];
    end
    ntk2Merged.images.frameno = [ntk2Merged.images.frameno ntk2.images.frameno]
    ntk2Merged.images.last_frame = ntk2.images.last_frame;
    ntk2Merged.sig = [ntk2Merged.sig; ntk2.sig];
    ntk2Merged.frame_no = [ntk2Merged.frame_no, ntk2.frame_no];
    ntk2Merged.pos = ntk2.pos;
    ntk2Merged.eventTimeStamps = [ntk2Merged.eventTimeStamps, ntk2.eventTimeStamps]
    
end

end

ntk2 = ntk2Merged;

% ----------------- Separate traces ----------------- %
doCutTraces = 0;
if doCutTraces
    cutTraces = reshape(ntk2.sig(:,:),abs(preTime+postTime+1),length(ntk2.sig(:,1))/abs(preTime+postTime+1),length(ntk2.channel_nr));
end

clear ntk ntk2Merged

if enableSaveData
    eval(['save ntkLoadedDataElectrode',num2str(electrodeOfInterest)])
else
    disp('error in loadntk2eventsonly');
end


end