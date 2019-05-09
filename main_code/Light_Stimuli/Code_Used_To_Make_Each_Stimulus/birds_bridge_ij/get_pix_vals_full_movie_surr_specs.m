function pixelValues = get_pix_vals_full_movie_surr_specs(allSurrValues, frameCount)
% function pixelValues = get_pix_vals_full_movie_surr_specs(allSurrValues, frameCount)
% Function: input all the pixel values found in the surround of a number (frameCount) of
% frames. Output is a normalized vector of values that has the same spread
% characteristics as the entire series of frames 

% remove NaNs
allSurrValues(find(isnan(allSurrValues)==1)) = [];

% reshape vector
allSurrValues = single(reshape(allSurrValues, 1,prod(size(allSurrValues))));

% pix value count
binnedValues = round(histc(allSurrValues,[0:255])/frameCount);

% sorted surround values
valueRange = [0:255];

pixelValues = [];
for i=1:length( binnedValues )
    
    pixelValues = [pixelValues repmat(valueRange(i),1,binnedValues(i))];
end

end