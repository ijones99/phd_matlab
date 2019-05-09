function mov = frames2mov(frame)
% function mov = frames2mov(frame)
% PURPOSE: convert matrix with many frames to a movie structure



nFrames = size(frame,3);
vidHeight = size(frame,1);
vidWidth = size(frame,2);
frame = uint8(frame);
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'), 'colormap', []);

for k = 1 : nFrames
    mov(k).cdata = repmat(frame(:,:,k),[1 1 3]);
end

end