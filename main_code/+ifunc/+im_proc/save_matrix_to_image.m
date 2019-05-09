function save_matrix_to_image(frame, frameNo, dirName, formatSetting)
% function save_matrix_to_image(frame, frameNo, dirName, formatSetting)

imwrite(frame, fullfile(dirName, sprintf('frame_%08d.tif',frameNo)),formatSetting);


end