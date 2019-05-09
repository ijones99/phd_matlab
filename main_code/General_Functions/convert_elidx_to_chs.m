function [  chsInPatch] = convert_elidx_to_chs(ntk2,elsInPatch, PLOT_ELS )
% function [  chsInPatch] = convert_elidx_to_chs(ntk2,elsInPatch, PLOT_ELS )
%
%load data



sortingPatchs = {};
fname = ntk2.fname;

ntk2Chs = ntk2.channel_nr;

if PLOT_ELS
    plot(ntk2.x, ntk2.y, '*b'), hold on
    % reverse y-axis plotting
    set(gca,'YDir', 'reverse');
    % declare colormap
    cmap = colormap('jet');
    
    % step size in colormap
    colorStepSize = ceil(length(cmap)/20);
end


clear I




chsInPatch = zeros(1,length(elsInPatch));
elidx = [];


for i=1:length(elsInPatch)
    
    
    elidx(i) = find(ntk2.el_idx == elsInPatch(i));
    chsInPatch(i) = ntk2.channel_nr(elidx(i));
    
    
end




%
if PLOT_ELS
    % STATUS: right comp
    plot(ntk2.x(elidx), ntk2.y(elidx), '*r')
    plot(ntk2.x(elidx(1)), ntk2.y(elidx(1)), '*g')
end



end