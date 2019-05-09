function [ elsInPatch chsInPatch] = convert_inds_to_chs(ntk2,indsInPatch, PLOT_ELS )
% function get_electrode_list(directoryName,flistName)
%
%load data



sortingPatchs = {};
fname = ntk2.fname;

ntk2Chs = ntk2.channel_nr;

if PLOT_ELS
    plot(ntk2.x, ntk2.y, '*b'), hold on
end
% reverse y-axis plotting
set(gca,'YDir', 'reverse');
% declare colormap
cmap = colormap('jet');

% step size in colormap
colorStepSize = ceil(length(cmap)/20);
clear I






    
    chsInPatch = ntk2.channel_nr(indsInPatch{1});
    
    elsInPatch = ntk2.el_idx(indsInPatch{1});
    if PLOT_ELS
        % STATUS: right comp
        plot(ntk2.x(indsInPatch{1}), ntk2.y(indsInPatch{1}), '*r')
        plot(ntk2.x(indsInPatch{1}(1)), ntk2.y(indsInPatch{1}(1)), '*g')
    end
        


end