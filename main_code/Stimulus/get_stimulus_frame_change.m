function FrChangeLoc = ...
    get_stimulus_frame_change(frameno)

binaryFrameChange = (diff(frameno));
FrChangeLoc = find(binaryFrameChange~=0)+1;




end