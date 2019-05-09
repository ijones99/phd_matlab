function [saved_frames] = Gen_Save_WN_Frames(Num_Frames,Edge_Length, Num_Pixels_per_Sqr )
	
%GEN_SAVE_WN_FRAMES Generate the frames to be used in the white noise
%stimulus, whitenoise6
%Author: ijones

% Num_Frames = 100*20*60;
% Edge_Length = 600;
% Num_Pixels_per_Sqr = 30;
saved_frames = (zeros(Edge_Length/Num_Pixels_per_Sqr,Edge_Length/Num_Pixels_per_Sqr, Num_Frames));

for k = 1:Num_Frames
    
    saved_frames(:,:,k) = logical(randint(Edge_Length/Num_Pixels_per_Sqr));
    if(k/(Num_Frames/10) == round(k/(Num_Frames/10)))
        k/Num_Frames
        
    end
  
end
fileName = strcat('SavedFrames', datestr(now,30));
saved_frames = logical(saved_frames);
eval(['save ' fileName ' saved_frames']);

end
