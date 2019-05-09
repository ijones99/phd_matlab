subplots = get(gcf,'Children'); % Get each subplot in the figure
for i=1:length(subplots) % for each subplot
    caxis(subplots(i),[0,800]); % set the clim
end