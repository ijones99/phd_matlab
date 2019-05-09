function apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i, varargin)

% apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i)
% Function: applies transfer function to pixels and saves image to file
% Arguments: 
%   tempFrame: input matrix to save
%   specificMovieDir: directory of this movie 
%   allMoviesDir: directory for all movie file collections
%   p: polynomial transfer function
%   i: loop number
% Flags:
%   'resize_im': enter [height width] dims of image to save

resizeImageDims = []; 

% resize image option
if ~isempty(varargin)
    for j=1:length(varargin)
        if strcmp(varargin{j},'resize_im')
            resizeImageDims = varargin{j+1};

        end
        
        
    end
end

% apply transfer function
tempFrame = uint8(apply_projector_transfer_function(single(tempFrame),p));

% resize image
if ~isempty(resizeImageDims)
    tempFrame = imresize(tempFrame, [resizeImageDims]);
end

% make directory if it doesn't exist
if ~exist(fullfile(allMoviesDir,specificMovieDir),'dir')
    mkdir(fullfile(allMoviesDir,specificMovieDir));
end
% name of file:
fileNamePrefix = strcat(specificMovieDir, '_');
% write frames to disk
imwrite(tempFrame,fullfile(allMoviesDir,specificMovieDir, strcat(fileNamePrefix, ...
    num2str(1e4+i),'.bmp'  )), 'bmp') ;

end