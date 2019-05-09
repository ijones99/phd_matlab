function framenoNew = correct_repeat_stimulus_frameno(frameno,acqFreq, movieRepeatInterval, stimInt )
% [framenoNew] = correct_repeat_stimulus_frameno(frameno)
% This function takes the parapin changes and adjusts them so that each
% sweep provides the correct image frame indices.


% get frame change locations
frChangeLoc = get_stimulus_frame_change(frameno);
% get movie repeat locations
movRepeatInd = find(and(diff(frChangeLoc)>stimInt*1.10, diff(frChangeLoc)<movieRepeatInterval*1.10))+1;
movRepeatFrLoc = frChangeLoc(movRepeatInd);

% %% plot frame info
% figure, plot(frameno(1:200*2e4)), hold on
% 
% plot([movRepeatFrLoc(1:10); movRepeatFrLoc(1:10)], [ones(1,10); ones(1,10)*6e3],'r')

% normalize to frame numbers
framenoNew = frameno;
for i=1:length(movRepeatFrLoc)-1
    clear frameValues
    frameValues = framenoNew(movRepeatFrLoc(i):movRepeatFrLoc(i+1)-1);
    framenoNew(movRepeatFrLoc(i):movRepeatFrLoc(i+1)-1) = frameValues - min(frameValues)+1;
end
frameValues = framenoNew(movRepeatFrLoc(i+1):end);
framenoNew(movRepeatFrLoc(i+1):end) = frameValues - min(frameValues)+1;


end