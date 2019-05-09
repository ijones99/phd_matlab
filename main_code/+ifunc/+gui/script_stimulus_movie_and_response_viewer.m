% script_stimulus_movie_and_response_viewer


% dirNames
dirName.movies_500um = '/home/ijones/Stimuli/Natural_Movies/BiolCyb2004_movies/labelb12ariell/500umAperture/'
dirName.movie_original_500um = fullfile(dirName.movies_500um, 'Original_Movie/');
dirName.movie_original_analysed_data = '../analysed_data/profiles/Movie_Original/';
dirName.movie_stat_surr_analysed_data = '../analysed_data/profiles/Movie_Static_Surr_Median/';


frameNames = dir(fullfile(dirName.movie_original_500um,'*.bmp'));
frame = double(imread(fullfile( dirName.movie_original_500um, ...
    frameNames(1).name),'bmp'));

for i=2:900
    frame(:,:,i) = uint8(imread(fullfile( dirName.movie_original_500um, ...
        frameNames(i).name),'bmp'));
end

mov = ifunc.movie.frames2mov(frame);
%%
cd ../../13Dec2012_2/Matlab/
load neurNameMat
selNeurName = '0023n5';
neurNameRow = find(ismember(neurNameMat(:,1),selNeurName))
selCol = 4;
fileName = dir(fullfile(dirName.movie_original_analysed_data,strcat('*',neurNameMat{neurNameRow,selCol},'*')));
load(fullfile(dirName.movie_original_analysed_data,fileName.name));
repeats = data.Movie_Original.processed_data.repeatSpikeTimeTrain;

selCol = 5;
fileName = dir(fullfile(dirName.movie_stat_surr_analysed_data,strcat('*',neurNameMat{neurNameRow,selCol},'*')))
load(fullfile(dirName.movie_stat_surr_analysed_data,fileName.name));
repeats2 = data.Movie_Static_Surr_Median.processed_data.repeatSpikeTimeTrain;
% call stimulus_movie_and_response_viewer
ifunc.gui.movie_and_response_viewer_dual2(mov,repeats, repeats2)


