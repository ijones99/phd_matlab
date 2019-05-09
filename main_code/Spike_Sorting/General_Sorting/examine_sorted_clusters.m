%% plot best electrode from each cluster
% check how many neurons have > 10% violations 
% config # is k
k = 1;
% close all

ISIstamps = [];
for i=1:length(neuronsCollected)
    i
    ViolationISIthresh = 2; %msec
%     numViolationsThreshold = 100;
    
    ISIstamps = ((neuronsCollected{i}.ts(2:end) - neuronsCollected{i}.ts(1:end-1)))/20; %ms: calculate ISIs for each neuron cluster
        
    numISIsubThreshold = length(find(ISIstamps < ViolationISIthresh));
    percentSubThreshold = numISIsubThreshold/length(ISIstamps)*100;
%     figure
%     hist(ISIstamps(ISIstamps(ISIstamps>0)<50 ),100000)
%     xlim([0 50])
%     title(num2str(numISIsubThreshold))
    stdTrace = [];
    [Imax,Ymax] = max(neuronsCollected{i}.template.data,[],1);
    [Imin,Ymin] = min(neuronsCollected{i}.template.data,[],1);
    peak2PeakValues = (Imax-Imin);
        
    [I,Y] = max(peak2PeakValues);
    peak2PeakValues(Y) = [];
    [I2,Y2] = max(peak2PeakValues);
    
    clear j
    

    for j=size(neuronsCollected{i}.trace{Y}.data,1)
        stdTrace(end+1)=std(neuronsCollected{i}.trace{Y}.data(j,:));
    end
    
    stdTrace = mean(stdTrace);
    fprintf('Percent violations = %.1f Stdev = %.1f\n', percentSubThreshold, stdTrace )

    
    if percentSubThreshold >= 0
        
        figure, plot_neurons(neuronsCollected{i},'elidx','dotraces_gray','electrodes', [neuronsCollected{i}.el_idx(Y),neuronsCollected{i}.el_idx(Y2)])
        
%             title(strcat(num2str(i),'//',num2str(i),'/',num2str(percentSubThreshold),'/',num2str(stdTrace),'/',neuronsCollected{i}.rgc_type))
title(strcat(num2str(i),'//',num2str(i),'/',num2str(percentSubThreshold),'/',num2str(stdTrace)))
%          figure, plot_neurons(neuronsCollected{i},'elidx')   
            
    end
    
%     qualityOfSpikes = input('Enter quality info about spikes; keep[k], discard[d], recluster[r]','s');
%     
%                 if isempty(qualityOfSpikes ) || qualityOfSpikes == 'k'  || qualityOfSpikes == 'd' || qualityOfSpikes == 'r'
%                 %delete traces, but keep templates
%                 %     splitted2{iii}.trace = [];
%                 %save data to one cell
%                
%                 %save cell type
%                 if isempty(qualityOfSpikes ) 
%                     qualityOfSpikes = 'k';
%                 end
%                 
%                 
%                 switch qualityOfSpikes
%               
%                     case 'k'
%                         disp('keep');
%                         neuronsCollected{end}.quality = 'keep';
%                     case 'd'
%                         disp('discard');
%                         neuronsCollected{end}.quality = 'discard';
%                     case 'r'
%                         disp('recluster');
%                         neuronsCollected{end}.quality = 'recluster';
%                    
%                 end              
%                 
%                
%             end
    
end
    
% plot 'dotraces_gray' for all neurons with > 10% violations

%% plot best electrode from each cluster all on same page

% check how many neurons have > 10% violations 
% config # is k
k = 1;
% close all

% get dims of subplot
%%
oneSide = ceil(sqrt(length(neuronsCollected)));



ISIstamps = [];
for i=1:length(neuronsCollected)
    i
    ViolationISIthresh = 2; %msec
%     numViolationsThreshold = 100;
    
    ISIstamps = ((neuronsCollected{i}.ts(2:end) - neuronsCollected{i}.ts(1:end-1)))/20; %ms: calculate ISIs for each neuron cluster
        
    numISIsubThreshold = length(find(ISIstamps < ViolationISIthresh));
    percentSubThreshold = numISIsubThreshold/length(ISIstamps)*100;
%     figure
%     hist(ISIstamps(ISIstamps(ISIstamps>0)<50 ),100000)
%     xlim([0 50])
%     title(num2str(numISIsubThreshold))
    stdTrace = [];
    [Imax,Ymax] = max(neuronsCollected{i}.template.data,[],1);
    [Imin,Ymin] = min(neuronsCollected{i}.template.data,[],1);
    peak2PeakValues = (Imax-Imin);
    
    
    [I,Y] = max(peak2PeakValues);
    peak2PeakValues(Y) = [];
    [I2,Y2] = max(peak2PeakValues);
    
    clear j
    

    for j=size(neuronsCollected{i}.trace{Y}.data,1)
        stdTrace(end+1)=std(neuronsCollected{i}.trace{Y}.data(j,:));
    end
    
    stdTrace = mean(stdTrace);
    fprintf('Percent violations = %.1f Stdev = %.1f\n', percentSubThreshold, stdTrace )

    
    
    
    if percentSubThreshold >= 0
        
        subplot(oneSide,oneSide,i), plot_neurons(neuronsCollected{i},'elidx','dotraces_gray','electrodes', [neuronsCollected{i}.el_idx(Y),neuronsCollected{i}.el_idx(Y2)])
%                     title(strcat(num2str(i),'//',num2str(i),'/',num2str(percentSubThreshold),'/',num2str(stdTrace),'/',neuronsCollected{i}.rgc_type))
            title(strcat(num2str(i),'//',num2str(i),'/',num2str(percentSubThreshold),'/',num2str(stdTrace))
%          figure, plot_neurons(neuronsCollected{i},'elidx')   
            
    end
    
%     editingClusters = input('Edit Clusters [d=delete, m=merge, r=resort]','s')
     
%     switch editingClusters
%         
%         case 'm'
%             disp('merge');
%             mergeNo1 = input('merge #1','s');
%             mergeNo2 = input('merge #2','s');
%             
%         case 'd'
%             disp('discard');
%             discardNumber = input('discard #','s');
%             neuronsCollected(str2num(discardNumber+1):end) = neuronsCollected(str2num(discardNumber):end-1)
%         case 'r'
%             disp('recluster');
%             
%     end
                
    
    
end

