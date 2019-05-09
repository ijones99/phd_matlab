function save_matrix_to_image(frame, frameNo, dirName, formatSetting)

imwrite(frame, fullfile(dirName, sprintf('frame_%08.tif',frameNo)),formatSetting);


end