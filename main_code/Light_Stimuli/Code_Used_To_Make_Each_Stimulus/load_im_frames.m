function [frames frameCount frameNames origImDims] = load_im_frames(movieDir, varargin)
% [FRAMES FRAMECOUNT FRAMENAMES] = LOAD_IM_FRAMES(MOVIEDIR, VARARGIN)
% Function loads the frames of a movie from a specified directory
% MOVIEDIR: directory where movie is stored
% varargin options:
% 'ROT_AND_FLIP': rotate and flip im for projection onto chip
% 'SPEC_FRAME_DIMS_PIX': resize the image frames. specify [height width]


% option for flipping frame images for projection
rotAndFlipFrame = 0;
% specify number of pixels
SPEC_FRAME_DIM_PIXELS = [];
% init frame count
frameCount = [];
% movie file pattern
movieFilePattern = '*.bmp';

if ~isempty(varargin)
    for i=1:length(varargin)
        % rotate and flip image frames
        if strcmp(varargin{i},'rot_and_flip')
            rotAndFlipFrame = 1;
            % change frame dimensions
        elseif strcmp(varargin{i},'spec_frame_dims_pix')
            SPEC_FRAME_DIM_PIXELS = varargin{i+1};
            
        elseif strcmp(varargin{i},'set_frame_count')
            frameCount = varargin{i+1};
        
        elseif strcmp(varargin{i},'movie_file_pattern')
            movieFilePattern = varargin{i+1};
        end
    end
end


% movie loading chunk size, in frames
chunkSize = 600;

% maximum number of frames allowed
maxNumberFrames = 1200;

%load the file names of frames of the movie
if ~strcmp(movieDir(end), '/')
    % add slash at end if necessary
    movieDir(end+1) = '/';
end

strcat(movieDir,movieFilePattern)
frameNames = dir(strcat(movieDir,movieFilePattern));
frameNames
% number of frames
if isempty(frameCount)
    frameCount = length(frameNames);
end


% number of frames cannot exceed a certain limit
if frameCount > maxNumberFrames
    frameCount = maxNumberFrames;
end


tempFrame = imread(strcat(movieDir, frameNames(1).name ),'bmp');
% `save dimension info
origImDims = size( tempFrame);


if isempty(SPEC_FRAME_DIM_PIXELS)

    if frameCount <= chunkSize

        % init frames var
        frames = uint8(zeros(origImDims(1),origImDims(2),frameCount ));

        % load data
        % alter for projection?
        if rotAndFlipFrame
            for i=1:frameCount
                frames(:,:,i) = flipud(imrotate(imread(strcat(movieDir, frameNames(i).name ),'bmp'),90));
            end
            
        else
            for i=1:frameCount
                frames(:,:,i) = imread(strcat(movieDir, frameNames(i).name ),'bmp');
            end
        end
        
    elseif and(frameCount > chunkSize, frameCount <= 1200)

        % init frames var

        %         frames = uint8(zeros(SPEC_FRAME_DIM_PIXELS(1),SPEC_FRAME_DIM_PIXELS(2),chunkSize ));
        %         frames2 = uint8(zeros(SPEC_FRAME_DIM_PIXELS(1),SPEC_FRAME_DIM_PIXELS(2),frameCount-chunkSize ));
        % init frames var
        frames = uint8(zeros(origImDims(1),origImDims(2),frameCount ));
        % load data
        if rotAndFlipFrame
            for i=1:chunkSize
%                 i
%                 strcat(movieDir, frameNames(i).name )
                frames(:,:,i) = flipud(imrotate(imread(strcat(movieDir, frameNames(i).name ),'bmp'),90));
            end
            %must load separately, otherwise loading is very slow
            for i=1:frameCount-chunkSize
                frames2(:,:,i) = flipud(imrotate(imread(strcat(movieDir, frameNames(i+chunkSize).name ),'bmp'),90));
            end

        else
            % load data
            for i=1:chunkSize
                frames(:,:,i) = imread(strcat(movieDir, frameNames(i).name ),'bmp');
            end
            %must load separately, otherwise loading is very slow
            for i=1:frameCount-chunkSize
                frames2(:,:,i) = imread(strcat(movieDir, frameNames(i+chunkSize).name ),'bmp');
            end
        end
        % put all frames into one variable
        frames(:,:,chunkSize+1:frameCount) = frames2;

    end

else
    % using resize of frames
    if frameCount <= chunkSize

        % load data
        % alter for projection?
        if rotAndFlipFrame
            pixH = SPEC_FRAME_DIM_PIXELS(2);
            pixW = SPEC_FRAME_DIM_PIXELS(1);

            % init frames var
            frames = uint8(zeros(pixH,pixW,frameCount ));
            for i=1:frameCount
                frames(:,:,i) = imresize(flipud(imrotate(imread(strcat(movieDir,...
                    frameNames(i).name ),'bmp'),90)),[pixH pixW]);
            end
        else
            pixH = SPEC_FRAME_DIM_PIXELS(1);
            pixW = SPEC_FRAME_DIM_PIXELS(2);

            % init frames var
            frames = uint8(zeros(pixH,pixW,frameCount ));
            for i=1:frameCount
                frames(:,:,i) = imresize(imread(strcat(movieDir, ...
                    frameNames(i).name ),'bmp'),[pixH pixW]);
            end
        end

    elseif and(frameCount > chunkSize, frameCount <= 1200)

        % load data
        if rotAndFlipFrame
            pixH = SPEC_FRAME_DIM_PIXELS(2);
            pixW = SPEC_FRAME_DIM_PIXELS(1);

            % init frames var
            frames = uint8(zeros(pixH,pixW,chunkSize ));
            frames2 = uint8(zeros(pixH,pixW,frameCount-chunkSize ));
            for i=1:chunkSize
                frames(:,:,i) = imresize(flipud(imrotate(imread(strcat(movieDir,...
                    frameNames(i).name ),'bmp'),90)),[pixH pixW]);
            end
            %must load separately, otherwise loading is very slow
            for i=1:frameCount-chunkSize
                frames2(:,:,i) = imresize(flipud(imrotate(imread(strcat(movieDir, ...
                    frameNames(i+chunkSize).name ),'bmp'),90)),[pixH pixW]);
            end

        else
            pixH = SPEC_FRAME_DIM_PIXELS(1);
            pixW = SPEC_FRAME_DIM_PIXELS(2);

            % init frames var
            frames = uint8(zeros(pixH,pixW,chunkSize ));
            frames2 = uint8(zeros(pixH,pixW,frameCount-chunkSize ));
            % load data
            for i=1:chunkSize
                frames(:,:,i) = imresize(imread(strcat(movieDir,...
                    frameNames(i).name ),'bmp'),[pixH pixW]);
            end
            %must load separately, otherwise loading is very slow
            for i=1:frameCount-chunkSize
                frames2(:,:,i) = imresize(imread(strcat(movieDir,...
                    frameNames(i+chunkSize).name ),'bmp'),[pixH pixW]);
            end
        end
        % put all frames into one variable
        frames(:,:,chunkSize+1:frameCount) = frames2;

    end
end

end