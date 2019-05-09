modName = 'Dynamic_Surr_Median_Each_Frame';
loadMovieDir = strcat('/net/bs-filesvr01/export/group/hierlemann/projects', ...
'/retina_project/Natural_scenes/Mouse_Cage_Movies/Movie1/', modName);


movieFilePattern = '*.bmp';
frameCount = 294;

figure, hold on

subplot(1,2,1);

[frames frameCount frameNames originalImDims] = load_im_frames(loadMovieDir, 'set_frame_count',frameCount, ...
    'movie_file_pattern', movieFilePattern, 'spec_frame_dims_pix', [originalImDims]);

surrVals = single(frames(1,1,:));
surrVals = surrVals(:);
edges = [1:10:255];%[min(surrVals):10:max(surrVals) ];
hist(surrVals,edges);
xlabel('brightness value');
ylabel('count');
title(strrep(modName,'_',' '));



modName = 'Dynamic_Surr_Mean_Each_Frame';
loadMovieDir = strcat('/net/bs-filesvr01/export/group/hierlemann/projects', ...
'/retina_project/Natural_scenes/Mouse_Cage_Movies/Movie1/', modName);
subplot(1,2,2);
[frames frameCount frameNames originalImDims] = load_im_frames(loadMovieDir, 'set_frame_count',frameCount, ...
    'movie_file_pattern', movieFilePattern, 'spec_frame_dims_pix', [originalImDims]);

surrVals = single(frames(1,1,:));
surrVals = surrVals(:);
edges = [1:10:255];%edges = [min(surrVals):10:max(surrVals) ];
hist(surrVals,edges);
xlabel('brightness value');
ylabel('count');
title(strrep(modName,'_',' '));


