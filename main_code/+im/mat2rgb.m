function rgbIm = mat2rgb(matIn)
% function rgbIm = mat2rgb(matIn)

C = colormap;  % Get the figure's colormap.
L = size(C,1);
% Scale the matrix to the range of the map.
Gs = round(interp1(linspace(min(matIn(:)),max(matIn(:)),L),1:L,matIn));
rgbIm = reshape(C(Gs,:),[size(Gs) 3]); % Make RGB image from scaled.


end