function analyzeandmergeclusters(varargin)

% ----------------- Argument settings ----------------- %

enableSaveData = 0;
electrodeOfInterest = [];
if ~isempty(varargin)
   i = 1;
   while i <= size(varargin,2)
       if strcmp('enable_save_data',varargin{i})
           enableSaveData = 1;
           fprintf('analyzeandmergeclusters: save data enabled\n');
       elseif strcmp('electrode',varargin{i})
           i = i+1;
           electrodeOfInterest = varargin{i};
           fprintf('analyzeandmergeclusters: electrode %d selected\n',electrodeOfInterest );    
       else
           fprintf('analyzeandmergeclusters: unknown argument\n');
       end
       i = i+1;
   end
end

% if isempty(electrodeOfInterest)
%     electrodeOfInterest = 5358;
%     fprintf('analyzeandmergeclusters: electrode %d selected\n',electrodeOfInterest );
% end


% ----------------- Call main functions ----------------- %
% load data needed for below functions
eval(['load clusteredEventsDataElectrode',num2str(electrodeOfInterest)])

% load data for plotting clusters (saved in pca_cluster_neuron.m)
eval(['load clusteredEventsPlotDataElectrode',num2str(electrodeOfInterest),'.mat'])

%% visualize

if 1==1%do_plot
    
    lcolor=lines(10);
    
    scrsz = get(0,'ScreenSize');
    figure('Position',[1 scrsz(4) scrsz(3)/3 scrsz(4)/2.5]);
    subplot(131)
    hold on;
    IND=min(T):max(T);
    colorMap = rand(max(T)-min(T)+1,3);
    
    for i=min(T):max(T)
        
        plot(data(T==i,1),data(T==i,2),'.','color',colorMap(i,:));%lcolor(i,:));
    end
    box on;
    title('Principal Components 1 and 2','Fontsize',18)
    set(gca,'FontSize',18);
    
    subplot(1,3,[2 3])
    hold on;
    for i=min(T):max(T)
%         plot(n1.tr_per_ts(T==i,:)','.','color',lcolor(i,:));
        plot((n1.tr_per_ts(T==i,:)')+(i*100),'color',colorMap(i,:));
        text(2,(i*110),int2str(i),'FontSize',18)  
    end
    box on;
    title('Data used for clustering','Fontsize',18)
    set(gca,'FontSize',18);
 
    if num_of_pca>=3
    figure

    IND=min(T):max(T);
    for i=min(T):max(T)
        plot3(data(T==i,1),data(T==i,2),data(T==i,3),'.','color',colorMap(i,:));
        hold on
    end
    grid on;
    title('PC 1/2/3','Fontsize',18)
    set(gca,'FontSize',18);
    end
    

    
    
    plot_neurons(splitted_for_plot,'separate_subplots','dotraces_gray','colormap',colorMap,'width',2)
    
    
    
end

%
enableInteractiveAnalyzing = 0;
enableInteractiveMerging = 1;

fprintf('analyzeandmergeclusters: analyze_and_correct_clusters\n');
if enableInteractiveAnalyzing
    sufficientlyActiveClusters=analyze_and_correct_clusters(sufficientlyActiveClusters,'interactive',1);
else
    sufficientlyActiveClusters=analyze_and_correct_clusters(sufficientlyActiveClusters);
end
    fprintf('analyzeandmergeclusters: exit analyze_and_correct_clusters\n');
% merge neurons
fprintf('analyzeandmergeclusters: enter merge_neurons\n');
if enableInteractiveMerging
    sufficientlyActiveClusters=merge_neurons(sufficientlyActiveClusters,'interactive',1,'no_isi'); 
else
    sufficientlyActiveClusters=merge_neurons(sufficientlyActiveClusters,'no_isi'); 
end
    
    
    fprintf('analyzeandmergeclusters: exit merge_neurons\n');



clear initialCluster ntk2 traceTimeStamps working eventTimeStamps
% save neuron data
eval(['save MergedClustersElectrode',num2str(electrodeOfInterest)])
end