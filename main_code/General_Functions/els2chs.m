function [chsInPatch indsInPatch] = els2chs(elsInPatch, ntk2)
% function [chsInPatch indsInPatch] = els2chs(elsInPatch, ntk2)

indsInPatch = zeros(1,length(elsInPatch));
for i=1:length(elsInPatch)
    indsInPatch(i) = find(elsInPatch(i) == ntk2.el_idx);
    
    
end

chsInPatch = ntk2.channel_nr([indsInPatch]);
% indsInPatch
% chsInPatch
% i
end