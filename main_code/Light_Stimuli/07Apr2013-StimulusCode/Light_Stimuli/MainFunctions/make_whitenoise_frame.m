function frame = make_whitenoise_frame(brightness, contrast, edgeLengthSize, numPixelsEdge)
% Function: create whitenoise frame with norm dist'n
% Input:
%   brightness: value [0...255]
%   contrast: value [0...255]
%   edgeLengthSize: length of one edge of square
%   numPixelsEdge: how many pixels make up white noise

% Create square frame with the desired random distribution
frame = round(normrnd(brightness,contrast,numPixelsEdge, numPixelsEdge));

% clip top and bottom if specified

frame(find(frame>255))=255;
frame(find(frame<0))=0;


% expand frame
frame = uint8(kron(frame,ones(round(edgeLengthSize/numPixelsEdge))));


end