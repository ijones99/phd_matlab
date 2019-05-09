function selFrames = get_specific_movie_frames(frameNums, dirName)

for i=1:length(frameNums)
    if exist(fullfile(dirName,sprintf('frame_%08d.mat',frameNums(i))))
        load(fullfile(dirName,sprintf('frame_%08d.mat',frameNums(i))));
        if exist('selFrames')
            selFrames(:,:,end+1) = frame;
        else
            selFrames = frame;
        end
    end
end




end