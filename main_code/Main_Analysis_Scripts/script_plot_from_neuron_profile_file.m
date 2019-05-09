%% plot data
h = figure('Position', [1 1 1000 1200] ); % [left bottom width height]....get(0,'ScreenSize')  [1 1 1920 1200]                                                                                    
set(gcf,'color',[1 1 1])

setSpacing = 0.015;
setPadding = 0.015;
setMargin = 0.017;
subplotsVert = 5;
% length(neuronsList{2}.neuron_names) ;
subplotsHor = 4;

hold on
for i=1
    iNeuron = i;
    plotInd = (i-1);
    resultsData = load_results_files(strcat(neuronsList{2}.date,'_', neuronsList{2}.neuron_names{iNeuron}));
    % plot polar -------------------------------------
    subaxis(subplotsVert,subplotsHor,1+plotInd, 'Spacing', setSpacing, 'Padding', ...
        setPadding, 'Margin', setMargin);
    
    stimGroupNo = 10;
    plot_polar_for_ds(resultsData{stimGroupNo}.bar_directions, resultsData{stimGroupNo}.mean_fr)
    title(neuronsList{2}.neuron_names{iNeuron},'FontWeight','bold');
    xlabh = get(gca,'Title'); set(xlabh,'Position',get(xlabh,'Position') - [0 1 0]);
    % ------------------------------------------------%
    % plot RF sizes ----------------------------------
    subaxis(subplotsVert,subplotsHor,2+plotInd, 'Spacing', setSpacing, 'Padding', ...
        setPadding, 'Margin', setMargin);
    stimGroupNo = 9;
    peakFr = max(frAvg,[],2);
    plot(resultsData{stimGroupNo}.settings.DOT_DIAMETERS,resultsData{stimGroupNo}.fr_peak(1:end/2),'b*-','LineWidth',2), hold on
    plot(resultsData{stimGroupNo}.settings.DOT_DIAMETERS,resultsData{stimGroupNo}.fr_peak(end/2+1:end),'r*-','LineWidth',2)
    xlabel('Dot Diameter (microns)'), ylabel('Firing Rate')
    if i==1, title('RF Sizes','FontWeight','bold'), end

    % plot STA ---------------------------------------
    subaxis(subplotsVert,subplotsHor,3+plotInd, 'Spacing', setSpacing, 'Padding', ...
        setPadding, 'Margin', setMargin);
    stimGroupNo = 1;                                                                
    plot(resultsData{stimGroupNo}.x_axis, resultsData{stimGroupNo}.STA,'LineWidth',2,'Color',[0 0.5 0]);
    
    if i==1, title('STA','FontWeight','bold'), end
    xlabel('Time (msec)'), ylabel('Pixels');

    
    % plot PSTH of dot stim ---------------------------------------------
    subaxis(subplotsVert,subplotsHor,4+plotInd, 'Spacing', setSpacing, 'Padding', ...
        setPadding, 'Margin', setMargin);
    stimGroupNo = 9;
    plot([0:0.025:1], resultsData{stimGroupNo}.meanPsthSmoothed,'k','LineWidth',2);
    if i==1, title('PSTH for Dot','FontWeight','bold'), end
    xlabel('Time (sec)'), ylabel('Firing Rate')
    
end