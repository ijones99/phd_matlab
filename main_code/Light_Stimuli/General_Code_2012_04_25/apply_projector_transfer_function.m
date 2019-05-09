function inputPixelVals = apply_projector_transfer_function(outputPixelVals,p)
% function inputPixelVals =
% apply_projector_transfer_function(outputPixelVals,p)

% Function: transform the output pixel vals to the required input values.
% Used when projecting a stimulus to the retina

% polyfit function located in the following directory:
% /home/ijones/Matlab/Light_Stimuli/Projector

inputPixelVals = uint8(polyval(p,outputPixelVals));

end