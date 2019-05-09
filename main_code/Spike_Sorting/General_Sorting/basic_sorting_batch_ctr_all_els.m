function basic_sorting_batch_ctr_all_els(flistName ,TIME_TO_LOAD, elsInPatch, numKmeansReps, varargin )

% flistName = filename (e.g. flist{flistNoForWaveforms}; % name of file ...
... to sort for waveform shapes
    % TIME_TO_LOAD = [] (e.g.20); time to load in minutes
% elsInPatch = [...]: electrodes that constitute the middle patch

% The purpose of this file is to obtain all neuron waveform shapes within a
% patch.
% Selects file based on "flist_for_analysis.mat"
selPatchbyElNumber = 0;
selPatchNumber = [];
idNameStartLocation = strfind(flistName{1},'T');idNameStartLocation(1)=[];
idNameEndLocation = strfind(flistName{1},'.stream.ntk')-1;
flistFileNameID = flistName{1}(idNameStartLocation:idNameEndLocation);
thrValue = 3.5;
chunkSize = 20000*60*3; % chunk size for data loading
DATA_DIR = '../analysed_data/';
FILE_DIR = strcat('../analysed_data/', flistFileNameID,'/');
% if user would like to start at a different patch number
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp(varargin{i},'sel_patch_number')
            selPatchNumber = varargin{i+1};
            fprintf('>>>>>>>>> Computing for patches the following electrode groups\n');
            fprintf('%d\n', selPatchNumber);
            pause(1);
        elseif strcmp(varargin{i},'sel_by_el_number') 
              selPatchbyElNumber = varargin{i+1};
        elseif strcmp(varargin{i},'add_dir_suffix')
            flistFileNameID = strcat(flistName{1}(idNameStartLocation:idNameEndLocation),varargin{i+1});
            
            clear FILE_DIR
            FILE_DIR = strcat('../analysed_data/', flistFileNameID,'_plus_others/');
        elseif strcmp(varargin{i},'set_threshold')
            thrValue = varargin{i+1};
        end
    end
end


% determine whether there are multiple files
if length(flistName) > 1
    multipleFilesDetected = 1;
else
    multipleFilesDetected = 0;
end

close all

% notify user what will be loaded
for i=1:length(flistName)
    fprintf('Loading %d mins of data from file %s\n ', TIME_TO_LOAD, flistName{i}) ;
end
% noteToUser = input( '(press enter)' );

% ID number for file, extracted from flist name (e.g. T11_27_53_1)
% flistFileNameID = flistName{1}(end-21:end-11);

% specify that there are multiple files
% if multipleFilesDetected
%     flistFileNameID = strcat(flistFileNameID,'_plus_others_2');
% end

% ---------- Dirs ----------


%create directory if not existing
if ~exist(FILE_DIR,'dir')
    mkdir(FILE_DIR);
end

% dir in which to put output files
OUTPUT_DIR = strcat(FILE_DIR, '01_Pre_Spikesorting/');

%create directory if not existing
if ~exist(OUTPUT_DIR,'dir')
    mkdir(OUTPUT_DIR);
end
% --------------------------

% get ntk2 data field values by loading 1 frame of the data
siz_init=1;
ntk_init=initialize_ntkstruct(flistName{1},'hpf', 500, 'lpf', 3000);

% plot_electrode_map(ntk2_init, 'el_idx')

% number of frames to load
siz=TIME_TO_LOAD*60*2e4;
% init ntk for main load
[ntk2_init ntk_init]=ntk_load(ntk_init, siz_init, 'images_v1');

% convert electrode numbers to channels from loaded init data
[  chsInPatch] = convert_elidx_to_chs(ntk2_init,elsInPatch, 0);


% remove noisy channels and flat channels
% ntk2=detect_valid_channels(ntk2,1);
% trace name
% trace_name=ntk2_init.fname;
% frequency sampling
Fs=ntk2_init.sr;

% reload only selected data
siz_init=2e4;
ntk_init=initialize_ntkstruct(flistName{1},'hpf', 500, 'lpf', 3000);
[ntk2_init ntk_init]=ntk_load(ntk_init, siz_init, 'images_v1','keep_only', chsInPatch);
% [ntk2_init ntk_init]=ntk_load(ntk_init, siz_init, 'images_v1');
% get electrode groupings
[elsInPatch chsInPatch  indsInPatch] = get_electrodes_sorting_patches_overlapping(ntk2_init, 7);

ntk_init=initialize_ntkstruct(flistName{1},'hpf', 500, 'lpf', 3000);
[ntk2_init ntk_init]=ntk_load(ntk_init, siz_init);

for j = 1:length(elsInPatch)
    for k=1:length(elsInPatch{j})
        
        chsInPatch{j}(k)=ntk2_init.channel_nr(find(ntk2_init.el_idx == elsInPatch{j}(k)));
        indsInPatch{j}(k)=find(ntk2_init.el_idx == elsInPatch{j}(k));
    end
    
end



% save data
% save(fullfile(FILE_DIR, 'Overlapping_Patches_Data.mat'), ...
%     'elsInPatch', 'chsInPatch', 'indsInPatch');

%% SPIKE SORTING


if sum(selPatchbyElNumber)
    tempAllElsInPatches = cat(1,elsInPatch{:});
    tempFirstElsInPatches = tempAllElsInPatches(:,1);
    selPatchNumber = find(ismember(tempFirstElsInPatches, selPatchbyElNumber)>0)';
    
elseif isempty(selPatchNumber)
    selPatchNumber = [1:length(indsInPatch)];
end
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')


for i=selPatchNumber
    tic
    close all
    clear data spikes
    spikes = [];
    spikes = ss_default_params(Fs);
    thrValue
    %     modify threshold
    spikes.params.thresh = thrValue;
    % add additional info
    
    
    
    spikes.elidx = elsInPatch{i};
    spikes.channel_nr = chsInPatch{i};
    
    % give file names to spike struct
    spikes.fname = flistName{1};
    if multipleFilesDetected
        for k=2:length(flistName)
            spikes.fname = strcat([spikes.fname, ', ', flistName{k}]);
        end
    end
    
    spikes.clus_of_interest=[];
    spikes.template_of_interest=[];
    
    % detect spikes
    
    spikes.last_read_ts = 0;
    spikes.file_switch_ts = 0;
    frameno = double([]);
    
    for iFileCounter = 1:length(flistName)
        ntk=initialize_ntkstruct(flistName{iFileCounter},'hpf', 500, 'lpf', 3000);
        for iChunk=1:ceil(siz/chunkSize)
            iChunk
            % if there are more than one chunks
            if iChunk > 1
                % load data and put into ss_detect if not yet at end of
                % file
                if ntk2.eof == 0
                    [ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1', 'keep_only',  chsInPatch{i});
                    
                    data = {ntk2.sig};
                    
                    spikes = ss_detect(data,spikes);
                    spikes.last_read_ts = spikes.last_read_ts + length(ntk2.sig);
                    if i==selPatchNumber(1) % only collect light framenumbers for first patch; the rest would be redundant
                        % light time stamps
                        frameno = [frameno double(ntk2.images.frameno)];
                    end
                end
                %if there is only one chunk, load data
            else
                [ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1', 'keep_only',  chsInPatch{i});
                
                data = {ntk2.sig};
                
                spikes = ss_detect(data,spikes);
                spikes.last_read_ts = spikes.last_read_ts + length(ntk2.sig);
                if i==selPatchNumber(1) % only collect light framenumbers for first patch; the rest would be redundant
                    % light time stamps
                    frameno = [frameno double(ntk2.images.frameno)];
                end
            end
            
            
        end
        % mark the ts where the file was changed
        if multipleFilesDetected & iFileCounter<length(flistName)
            spikes.file_switch_ts(end+1) = spikes.last_read_ts+1;
        end
    end
    
    saveFrameNo=0;
    if saveFrameNo
        if i==selPatchNumber(1)
            
            % save light frameno info
            if multipleFilesDetected
                save(strcat(FILE_DIR,'frameno_', flistFileNameID,'_plus_others.mat'), 'frameno');
            else
                save(strcat(FILE_DIR,'frameno_', flistFileNameID,'.mat'), 'frameno');
            end
        end
        
    end
    clear ntk2
    
    %     try
    % align spikes
    
    errorCount = 1;
    spikes = ss_align(spikes);
    % cluster spikes
    options.reps = numKmeansReps;
    options.progress = 0;
    errorCount = 2;
    spikes = ss_kmeans(spikes, options);
    errorCount = 3;
    spikes = ss_energy(spikes);
    errorCount = 4;
    spikes = ss_aggregate(spikes,'hide_figure');
    errorCount = 5;
    ctrElNoStr = num2str(elsInPatch{i}(1));
    errorCount = 6;
    eval(['el_', ctrElNoStr,'=spikes;']);
    %     save(strcat(OUTPUT_DIR,'spikes_', ctrElNoStr,'.mat'),
    %     strcat('spikes_', ctrElNoStr) );
%     save(strcat(OUTPUT_DIR,'el_', ctrElNoStr,'.mat'), strcat('el_', ctrElNoStr));
    save(strcat(OUTPUT_DIR,'el_', ctrElNoStr,'.mat'), strcat('el_', ctrElNoStr));
    fprintf('-----------------------------------------------------')
    toc
    %     catch
%     save(strcat(OUTPUT_DIR,'error_',num2str(errorCount),'.txt'));
    %     end
end

end
