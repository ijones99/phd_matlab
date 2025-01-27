function basic_sorting_batch_single_neur_wn_h5(neursToProcess, flistName)
% basic_sorting_batch_single_neur(neursToProcess)
% neursToProcess: pick the neurons that will be loaded and processed

% Settings
index_recordings=1;
flistNo = 1;
TIME_TO_LOAD = 30%minutes

% --- get file names ---
% get names for files
% directory
dirName = '../analysed_data/T11_27_53_5/03_Neuron_Selection/';

% file types to open
fileNamePattern = fullfile(dirName,'st_*mat');

% obtain file names
fileNames = dir(fileNamePattern);

% ID number for file
flistFileNameID = flistName(end-21:end-11);

% ---------- Dirs ----------
% main directory for this file
FILE_DIR = strcat('../analysed_data/', flistFileNameID,'/');

%create directory
if ~exist(FILE_DIR,'dir')
    mkdir(FILE_DIR);
end

% dir in which to put output files
OUTPUT_DIR = strcat(FILE_DIR, '00_Spike_Isolation/');
%create directory
if ~exist(OUTPUT_DIR,'dir')
    mkdir(OUTPUT_DIR);
end

% init for ntk2
siz=5;
ntk=initialize_ntkstruct(flistName,'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');

% get primary electrode numbers that belong to each neuron; #'s are based
% ... on data from sorting of all neurons
elsInPatch = {};
chsInPatch = {};
indsInPatch = {};

% calculate channels in patch for each neuron
for iNeur=neursToProcess
    
    load(fullfile(dirName,fileNames(iNeur).name ));
    %     chsInPatch{end+1} = [eval([fileNames(iNeur).name(1:end-4),'.channel_nr'])];
    elsInPatch{end+1} = [eval([fileNames(iNeur).name(1:end-4),'.elidx'])];
    [chsInPatch{end+1} indsInPatch{end+1}] = els2chs(elsInPatch{length(elsInPatch)}, ntk2);
end

% load the data
TIME_TO_LOAD = 50;
siz=TIME_TO_LOAD*60*2e4;


% go through each neuron
for iNeursToProcess=1:length(neursToProcess)
    clear data spikes
    
    %     ntk=initialize_ntkstruct(flistName,'hpf', 500, 'lpf', 3000);
    %
    %     ntk2.sig = single(0);
    %     [ntk2 ntk]=ntk_load(ntk, siz, 'keep_only',  chsInPatch{iNeursToProcess}, 'images_v1');
    %     clear ntk
    %
    %     % trace name
    %     trace_name=ntk2.fname;
    % frequency sampling
    %     Fs=ntk2.sr;
    Fs = 20000;
    %     % light time stamps
    %     light_ts=single((find(diff(double(ntk2.images.frameno))==1)+860));
    %
    
    tic
    close all
    
    % channels to be analyzed
    %     data=ntk2.sig;
    %     clear ntk2;
    
     % create parameters
    spikes = [];
    spikes = ss_default_params(Fs);
    % add additional info
    spikes.elidx = elsInPatch{iNeursToProcess};
    spikes.channel_nr = chsInPatch{iNeursToProcess};
    spikes.fname = flistName;
    
    spikes.clus_of_interest=[];
    spikes.template_of_interest=[];
    
    
    % h5 part
    if 1
        clear mea
        clear mysort.mea.CMOSMEA
    end
    
    fstr = 'Trace_id843_2011-12-06T11_27_53_7.stream.h5';
    mea = mysort.mea.CMOSMEA(fstr);
    
    [nC nT ] = size(mea);
    chunkSize = 500000;
    
    % For test purposes
        nT = 2e4*60*2;
        chunkSize = 100000;
    
    chunker = mysort.util.Chunker(nT, 'overlap', 0, ...
        'chunkSize', chunkSize,...
        'progressDisplay', 'console');
    
    while chunker.hasNextChunk()
        [chunk_overlap chunk chunkLen] = chunker.getNextChunk();
        X = mea( 1:nC, chunk);
        spikes = ss_detect(X,spikes);
    end
    
    
    
    
    
    
    % detect spikes
    
    % align spikes
    spikes = ss_align(spikes);
    % cluster spikes
    spikes = ss_kmeans(spikes);
    spikes = ss_energy(spikes);
    spikes = ss_aggregate(spikes);
    
    eval(['el_',num2str(spikes.elidx(1)),'=spikes;'])
    
    save(strcat(OUTPUT_DIR, 'el_',num2str(spikes.elidx(1))), strcat('el_',num2str(spikes.elidx(1))) );
    fprintf('-----------------------------------------------------')
    toc
    %     catch
    %
    %         disp('error');
    %     end
end
fprintf('Finished Processing %s\n', flistName);

end
