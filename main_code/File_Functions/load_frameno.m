function [frameno] = load_frameno(dirName )
% [frameno] = load_frameno(dirName )


framenoInfo.name = dirName; % T directory name


if strfind(framenoInfo.name,'../analysed_data/')
     framenoName = dir(fullfile(framenoInfo.name,'frameno*shift860*' ));
     load(fullfile(framenoInfo.name, framenoName.name));% load the frameno
 
else
    framenoName = dir(fullfile('../analysed_data/',framenoInfo.name,'frameno*shift860*' ));
    load(fullfile('../analysed_data/',framenoInfo.name, framenoName.name));% load the frameno
    
end


end