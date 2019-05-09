% get cluster numbers
uniqueVals = {}
constantClus = [];
for j=[2 4]
    for i=1:3
        
        if ~isempty(R{i,j})
            uniqueVals{i,j} = unique(R{i,j}(:,1));
            if isempty(constantClus)
                constantClus = unique(R{i,j}(:,1))';
            else
                constantClus = constantClus(find(ismember(constantClus,uniqueVals{i,j})))
                
            end
        else
            uniqueVals{i,j} =  [];
        end
    end
    
    
end

%% get st for cluster no
%  figure, gui.plot_hidens_els('marker_style', 'cx'), hold on
plotOffset = -5;
figure
gui.plot_hidens_els('marker_style', 'cx'), hold on
for iClus = length(constantClus)-2
   
    try
    flistGpNo = [1 4];
    flistIdx = a.configs(flistGpNo(2)).flistidx(flistGpNo(1));
    
    stIdx = find(R{flistGpNo(1),flistGpNo(2)}(:,1)==constantClus(iClus));
    st = R{flistGpNo(1),flistGpNo(2)}(stIdx,2);
    
    
    maxNumStForFP = 300;
    
    h5Data = load_h5_data(flist(flistIdx));
    spikeTimesSamples = st(1:min(length(st),maxNumStForFP));
    [data] = h5.extract_waveforms_from_h5(h5Data, spikeTimesSamples)
    
    
    
    plot_footprints_simple([data.x+plotOffset*100  data.y], ...
        data.average, ...
        'input_templates','hide_els_plot',...
        'plot_color',rand(1,3),'scale', 55);
    pause(0.2)
    drawnow
    catch
        warning(sprintf('Error %d\n',iClus));
    end
    plotOffset = plotOffset+1;
    progress_info(iClus, length(constantClus))
end
%% run sorter


spikesorting.felix_sorter.start_sorting(batchInfo, 6)
