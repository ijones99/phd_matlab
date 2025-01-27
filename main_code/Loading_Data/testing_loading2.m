if 1
    clear mea
    clear mysort.mea.CMOSMEA
end

fstr = '../proc/Trace_id843_2011-12-06T11_27_53_5.stream.h5';
mea = mysort.mea.CMOSMEA(fstr);

[nT  nC  ] = size(mea);
chunkSize = 500000;

% For test purposes
nT = 500000;
chunkSize = 100000;

% while chunker.hasNextChunk()
    [chunk_overlap chunk chunkLen] = chunker.getNextChunk();
    X = mea( chunk, 1:nC);
% end

%%
tic
siz_init=1;
ntk_init=initialize_ntkstruct(strcat(fstr(1:end-2),'ntk'),'hpf', 500, 'lpf', 3000);
[ntk2_init ntk_init]=ntk_load(ntk_init, nT);
toc