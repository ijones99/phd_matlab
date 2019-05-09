function out = isfactorof(numIn, divisorIn)
% out = isfactorof(numIn, divisorIn)
out = 0
if numIn/divisorIn == round(numIn/divisorIn);
    out = 1;
end

end