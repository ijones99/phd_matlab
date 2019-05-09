function framenoOut = get_framenos(flist, siz)

% flistName = filename (e.g. flist{flistNoForWaveforms}; % name of file ...
... to sort for waveform shapes
    % TIME_TO_LOAD = [] (e.g.20); time to load in minutes
% elsInPatch = [...]: electrodes that constitute the middle patch

if nargin < 2
    siz = [];
else
    fprintf('Size to load no longer required.\n');
end

chunkSize = 20000*60*20; % chunk size for data loading

% --------------------------
% init frameno var


if ~iscell(flist)
    flistCell = flist;
    clear flist;
    flist{1} = flistCell;
end

for iFileCounter = 1:length(flist)
    % init data
    frameno = single([]);
    ntk=initialize_ntkstruct(strrep(flist{iFileCounter},'../proc/',''),'hpf', 500, 'lpf', 3000);
    iChunk= 1;
    ntk2.eof = 0;
    while ntk2.eof ~= 1
     
         fprintf('file %d of %d\n', iFileCounter, length(flist));
        [ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1', 'keep_only',  1);
        frameno = [frameno single(ntk2.images.frameno)];

        iChunk = iChunk+1;
    end
    framenoOut{iFileCounter} = frameno;
    progress_info(iFileCounter,length(flist));
   
end

end

