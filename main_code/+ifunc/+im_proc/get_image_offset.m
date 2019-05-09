function offsetXY = get_image_offset(baseIm, smallImToAlign)
% FUNCTION offsetXY = get_image_offset(baseIm, smallImToAlign)
% PURPOSE: obtain offset values for a small image as compared to a larger
% image in which the smaller image should exist.

c = normxcorr2(smallImToAlign, baseIm);
% figure, imagesc(c);
% offset found by correlation
[max_c, imax] = max(abs(c(:)));
[corrPeak(2), corrPeak(1)] = ind2sub(size(c),imax(1));
offsetXY = -((corrPeak-750/2-150)+1);


end