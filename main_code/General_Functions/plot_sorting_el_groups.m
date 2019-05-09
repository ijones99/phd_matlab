function plot_sorting_el_groups(ntk2, chGroups)
figure
hold on
plot(ntk2.x, ntk2.y, '*b')
% declare colormap
cmap = colormap('jet');

% step size in colormap
colorStepSize = ceil(length(cmap)/length(chGroups));

% find ntk2 indices for plotting x,y
for i=1:length(chGroups)
    
    % find ntk2 indices for plotting x,y
    i
    [Y chGroupsInd{i}] = ismember(chGroups{i} , ntk2.channel_nr )
    
    
     plot(ntk2.x(chGroupsInd{i}), ntk2.y(chGroupsInd{i}),'*g')%'*', 'color', cmap(i*colorStepSize,:))
pause(.5)
    
end
% 


end