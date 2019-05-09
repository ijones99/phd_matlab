function [elsInPatch chsInPatch indsInPatch] = get_electrodes_sorting_patches_overlapping(ntk2, numElsInPatch)
% function [elsInPatch chsInPatch indsInPatch] =
% get_electrodes_sorting_patches_overlapping(ntk2, numElsInPatch)
%
% this function gets all the electrode groupings for every electrode in the
% ntk2 file


PLOT_ON = 0;
sortingPatchs = {};
elsInPatch = {};
indsInPatch = {};
chsInPatch = {};
fname = ntk2.fname;
ntk2Chs = ntk2.channel_nr;

% step through all electrode numbers
for iPatchCtr = 1:length(ntk2.el_idx)
    
    % get all distances between selected electrode and other electrodesRmdr
    interElDist = sqrt((ntk2.x(iPatchCtr)-ntk2.x).^2+ (ntk2.y(iPatchCtr)-ntk2.y).^2 );
    
    % sort electrode distances from small to large
    [Y,I] = sort(interElDist);
    
    % select electrodes in patch that are closest to center electrode; get
    % electrode #s, ch #s and ind #s
    elsInPatch{end+1} = ntk2.el_idx(I(1:numElsInPatch));
    chsInPatch{end+1} = ntk2.channel_nr(I(1:numElsInPatch));
    indsInPatch{end+1} = I(1:numElsInPatch);
    
    if PLOT_ON
        if iPatchCtr == 1
            figure
            hold on
        end
        
        %     plot(ntk2.x, ntk2.y, '*k')
        %     plot(ntk2.x(indsInPatch{iPatchCtr}), ntk2.y(indsInPatch{iPatchCtr}), '*r')
        plot(ntk2.x(indsInPatch{iPatchCtr}(1)), ntk2.y(indsInPatch{iPatchCtr}(1)), '*g')       
        pause(.3)
    end
    
end

end