function X = loadMultipleCh(f, elIdx, startFrame, chunkSize  )
% X = LOADMULTIPLECH(f, elIdx, startFrame, chunkSize  )
%
% To get f:
%   mea1k.file( 'path_to_file.raw.h5' );

if chunkSize > f.maxSamples
   warning(sprintf('Data read request exceeds length of file;/n loading %d samples',f.maxSamples)) ;
   chunkSize = f.maxSamples;
end

chunkSizeLoad = 2e4*5;

chunkSizeEpochs = [startFrame:chunkSizeLoad:chunkSize];
if chunkSizeEpochs(end) < chunkSize
    chunkSizeEpochs(end+1) = chunkSize;
end
numLoadEpoch = ceil(chunkSize/(chunkSizeLoad-startFrame+1) )+1;
% init
X = nan(chunkSize, length(elIdx));
M = cell(1,numLoadEpoch-1);


if numLoadEpoch>1
    parfor i=1:numLoadEpoch-1
        dataChunk = f.getData( chunkSizeEpochs(i), chunkSizeEpochs(i+1)-chunkSizeEpochs(i) );
        M{i} = dataChunk(:,elIdx);
        progress_info(i,numLoadEpoch)
    end
    
    for i=1:numLoadEpoch-1
        X(chunkSizeEpochs(i):chunkSizeEpochs(i+1)-1,...
            1:length(elIdx)) = M{i};
        progress_info(i,numLoadEpoch)
    end
    
else
     X = f.getData( chunkSizeEpochs, chunkSizeLoad );
end


% parfor i=1:numLoadEpoch-1
%     dataChunk = f.getData( chunkSizeEpochs(i), chunkSizeLoad );
%     X(chunkSizeEpochs(i):chunkSizeEpochs(i+1)-1,...
%         1:length(elIdx)) = dataChunk(:,elIdx);
%     progress_info(i,numLoadEpoch)
% end


end


% 
% ', ...
%     [chunkSizeLoad:chunkSizeLoad:chunkSize chunkSize]'];