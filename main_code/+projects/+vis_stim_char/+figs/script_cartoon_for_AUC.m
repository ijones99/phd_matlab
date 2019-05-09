%% cartoon for area under curve
dirNames = projects.vis_stim_char.analysis.load_dir_names;
dirName = fullfile(dirNames.common.figs,'length_test/');
fileName = 'length_test_calculation_for_AUC';
ca
figure
x = 0:0.01:1;
y = gaussmf(x,[.2 .5]);

area(x,y,'FaceColor','k'), hold on
plot(x,y,'k','LineWidth', 2)
axis square
xlabel('Normalized Bar Length')
xlabel('Normalized Bar Length')

set(gca,'XTick',[0 1])
set(gca,'YTick',[0 1])

figs.format_for_pub('font_size', 8,'font_name','Times',...
'title', 'Calculation of AUC', 'plot_dims', [2 2])
figs.save_for_pub(fullfile(dirName,fileName));

%% cartoon for preferred speed
ca
figure
x = 0:0.01:1;
y = gaussmf(x,[.2 .5]);

area(x,y,'FaceColor','k'), hold on
plot(x,y,'k','LineWidth', 2)
xlabel('gaussmf, P=[2 5]')

set(gca,'XTick',[0 1])
set(gca,'YTick',[0 1])



shg