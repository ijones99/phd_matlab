h = figure;
uicontrol('Style', 'text', 'String', 'My Title', ...
'HorizontalAlignment', 'center', 'Units', 'normalized', ...
'Position', [0 .9 1 .05], 'BackgroundColor', [.8 .8 .8]);
h1 = subplot(3,4,1);
plot(1:10);
subplot(3,1,2);
plot(1:100);
subplot(3,1,3);
plot(1:100);