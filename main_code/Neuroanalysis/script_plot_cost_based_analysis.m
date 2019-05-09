figure, hold on 
errorbar(meanCost{1},stdCost{1},'-','LineWidth', 2)
% bar(meanCost)
% axis([.75 4.25 0 55])
set(gca, 'XTick', 1:length(qValuesLabel), 'XTickLabel', qValuesLabel,'FontSize', 15,'LineWidth', 2)
hold on
% plot
errorbar(meanCost{2},stdCost{2},'r','LineWidth', 2)
% set legend & title, etc.
title(strcat(['Cost Based Analysis of Spiketrains - ', X.sites.label, ' ']));
legend('orig', 'stat surround', 'dyn med surr', 'dyn med surr shuffled')
ylabel('Total Cost/Spike')
xlabel('Log of Cost of Shifting Rel to Adding or Deleting Spike');
%% Plot Spike Count
figure
errorbar(avgNumSpikesAll,stdNumSpikesAll,'-','LineWidth', 2)

stimTypes = {'orig', 'stat surround', 'dyn med surr', 'dyn med surr shuffled'};
set(gca, 'XTick', 1:length(stimTypes), 'XTickLabel', stimTypes,'FontSize', 15,'LineWidth', 2)
title(strcat(['Spike Counts ', X.sites.label, ' ']));
ylabel('Average Number Spikes Per Trial (Spikes/~30 Seconds)')
xlabel('Stimulus Type');


%% plot spiketrain metrics: heat map
% OPTS.shift_cost: The cost of shifting a spike per unit time
%          relative to inserting or deleting a spike. This option may
%          be a vector of such values. The default is
%          1/(end_time-start_time).

% shift cost of 0;
opts.shift_cost = 0;
Y = metric(X, opts)
figure, imagesc(Y.d), title(strcat(X.sites.label,' (Shift Cost = ', num2str(opts.shift_cost),')' ));

startTime = X.categories(1).trials(1).start_time;
endTime = X.categories(1).trials(1).end_time;

% shift cost is 1;
opts.shift_cost = .02;
Y = metric(X, opts)
figure, imagesc(Y.d), title(strcat(X.sites.label,' (Shift Cost = ', num2str(opts.shift_cost),')' ));


% shift cost is length of recording;
opts.shift_cost = 1/(endTime - startTime);
Y = metric(X, opts)
figure, imagesc(Y.d), title(strcat(X.sites.label,' (Shift Cost = ', num2str(opts.shift_cost),')' ));


% figure, staraster(X)
