
allMoviesDir = '/net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Natural_scenes/birds_bridge_ij/';
specificMovieDirNames = dir(fullfile(allMoviesDir,'*'));

for i = 1:length(specificMovieDirNames)
    
    % var to check for movie file existence
    aviExist = {}%dir(fullfile(allMoviesDir,'*.avi'));
    
    % if there is no movie, try to load frames
    if isempty(aviExist)
        try
            
            % load frames
            [frames frameCount frameNames] = load_im_frames(fullfile(allMoviesDir,specificMovieDirNames(i).name), ...
                'set_frame_count',30, 'movie_file_pattern', '*.bmp');
            
            %     Create a VideoWriter object by calling the VideoWriter function.
            aviobj = avifile(fullfile(allMoviesDir,specificMovieDirNames(i).name, strcat(specificMovieDirNames(i).name, ...
                '.avi')), 'fps', 30,'compression', 'RLE' );
            
            tempFrame = uint8(zeros(size(frames,1), size(frames,2), 3));
            
            % add frame
            for iFrame=1:size(frames,3)
                
                tempFrame(:,:,2:3) = cat(3,frames(:,:,iFrame), frames(:,:,iFrame));
                
                aviobj = addframe(aviobj,tempFrame);
            end
            
            % Close the file:
            aviobj = close(aviobj);
        catch
            disp('Error loading frames')
        end
    else
        disp('Movie Exists');
    end
    fprintf(strcat(['Done with ', specificMovieDirNames(i).name,'\n']));
end