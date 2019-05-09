function [saved_frames] = genframes(Num_Frames,Edge_Length, Num_Pixels_per_Sqr, Orientation )
	
%GEN_SAVE_WN_FRAMES Generate the frames to be used in the white noise
%stimulus, whitenoise6
%Author: ijones

% Num_Frames = 100*20*60;
% Edge_Length = 600;
% Num_Pixels_per_Sqr = 30;
saved_frames = (zeros(Edge_Length/Num_Pixels_per_Sqr,Edge_Length/Num_Pixels_per_Sqr, Num_Frames));

if Orientation == 'v'
    for k = 1:Num_Frames

        saved_frames(1,:,k) = logical(randint(1,Edge_Length/Num_Pixels_per_Sqr));
        saved_frames(:,:,k) = repmat(saved_frames(1,:,k),size(saved_frames,1),1);
        if(k/(Num_Frames/10) == round(k/(Num_Frames/10)))
            k/Num_Frames

        end
  	k
    end
elseif Orientation == 'h'
    for k = 1:Num_Frames

    saved_frames(:,1,k) = logical(randint(Edge_Length/Num_Pixels_per_Sqr,1));
    saved_frames(:,:,k) = repmat(saved_frames(:,1,k),1,size(saved_frames,1));
    if(k/(Num_Frames/10) == round(k/(Num_Frames/10)))
        k/Num_Frames

    end
  k
end 
else
   beep()
   disp('No orientation specified');
end


fileName = strcat('SavedFrames', datestr(now,30));
saved_frames = logical(saved_frames);
eval(['save ' fileName ' saved_frames']);

end
