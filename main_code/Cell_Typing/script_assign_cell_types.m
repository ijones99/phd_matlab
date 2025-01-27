%% SORT
%init vars

% temp_neurons = {};
% temp_neuronsLength = length(temp_neurons)
% Go 2 - 75
close all
for iCount =1:length(temp_neurons) 
    try
        iii=iCount;
        %         for iii=1:length(temp_neurons)
        % plot data for each cluster
        cluster=iii;
        
        % plot in columns
        idx_light=(find(diff(double(ntk2.images.frameno))==1)+860);
        ts_onoff=temp_neurons{cluster}.ts;
                
        light_ts(1).pos=idx_light(1:10);
        light_ts(2).pos=idx_light(11:20);
        light_ts(3).pos=idx_light(21:30);
        light_ts(4).pos=idx_light(31:40);
        
        idx_on=[1,3,5,7,9];
        idx_off=[2,4,6,8,10];
        
        offsets=[1 5.3;7 11.3;13 17.3;19 23.3]-1;
        offsets2=[0 ;6 ;12 ;18];
        all_psth=[];
        
        
        for k=1:length(light_ts)
            
            for i=1:5
                light_ts_temp=light_ts(k).pos;
                spike(i).times=ts_onoff(ts_onoff>(light_ts_temp(idx_on(i))-10000) & ts_onoff<(light_ts_temp(idx_off(i))+37000));
                spike(i).times=spike(i).times-(light_ts_temp(idx_on(i))-10000);
            end
            
            if k==1
                scrsz = get(0,'ScreenSize');
                figure('Position',[0.9 0.9 1500 1500],'Color','w')
                
                subplot(3,3,[1 4])
            end
            hold on
            area([10000/20000 10210/20000],[offsets(k,2)-1 offsets(k,2)-1],'Facecolor',[0,0.7,0],'EdgeColor',[0,0.7,0],'basevalue',offsets(k,1)'+1);
            hold on
            area([50000/20000 50210/20000],[offsets(k,2)-1 offsets(k,2)-1],'Facecolor','r','EdgeColor','r','basevalue',offsets(k,1)'+1);
            
            
            hold on
            for i=1:length(spike)
                t=spike(i).times/20000;
                for j=1:length(spike(i).times);
                    line([t(j) t(j)],[offsets2(k)+(0.35*i)+0.01 offsets2(k)+(0.35*i)+0.2]+1,'Color', 'k','LineWidth',2);
                    hold on
                end
            end
            hold on
            
            
            width=1000;
            edges=[0:width:87000]; %define window size, 2000 samples=100ms
            psth=zeros(length(edges),1);
            
            for i=1:length(spike)
                if  isvector(spike(i).times)
                    psth_to_add=histc(spike(i).times, edges)' ;
                else
                    psth_to_add=zeros(length(edges),1);
                end
                psth = psth + psth_to_add;
            end
            psth=(psth/length(spike))/(width/20000);
            all_psth(:,k)=psth;
            
            
        end
        max_firing_rate=max(max(all_psth));
        all_psth=all_psth/max(max(all_psth));
        
        for i=1:size(all_psth,2)
            x_psth=edges/20000;
            y_psth=all_psth(:,i)'+offsets(i,2);
            plot(x_psth,y_psth,'Color', 'k','LineWidth',2)
            hold on
        end
        
        hold on
        line([2000/20000 2000/20000],[-0.1 0.9],'Color','k','LineWidth',2);
        text(3000/20000,0.2,[int2str(max_firing_rate) 'Hz'],'FontSize',10,'fontweight','b')
        
        xlim([0 87000/20000])
        ylim([-1 24.2])
        set(gca,'YTick',(offsets(:,1)')+2);
        set(gca,'YTickLabel',[0 100 200 300]);
        ylabel('Square Center Position [\mum]','Fontsize',18);
        xlabel('Time [s]','Fontsize',18)
        set(gca,'FontSize',18);
        
        
        subplot(3,3,7);
        lcolor=lines(40);
        zv=7;
        
        box on;
        set(gca,'FontSize',18);
        xlabel('PC1','Fontsize',18)
        ylabel('PC2','Fontsize',18)
        
        subplot(3,3,[2 5]);
        i = iCount;
        ViolationISIthresh = 2; %msec
        %     numViolationsThreshold = 100;
        
        ISIstamps = ((temp_neurons{i}.ts(2:end) - temp_neurons{i}.ts(1:end-1)))/20; %ms: calculate ISIs for each neuron cluster
        
        numISIsubThreshold = length(find(ISIstamps < ViolationISIthresh));
        percentSubThreshold = numISIsubThreshold/length(ISIstamps)*100;
        %     figure
        %     hist(ISIstamps(ISIstamps(ISIstamps>0)<50 ),100000)
        %     xlim([0 50])
        %     title(num2str(numISIsubThreshold))
        stdTrace = [];
        [Imax,Ymax] = max(temp_neurons{i}.template.data,[],1);
        [Imin,Ymin] = min(temp_neurons{i}.template.data,[],1);
        peak2PeakValues = (Imax-Imin);
        
        
        [I,Y] = max(peak2PeakValues);
        peak2PeakValues(Y) = [];
        [I2,Y2] = max(peak2PeakValues);
        
        clear j
        
        
        for j=size(temp_neurons{i}.trace{Y}.data,1)
            stdTrace(end+1)=std(temp_neurons{i}.trace{Y}.data(j,:));
        end
        
        stdTrace = mean(stdTrace);
        fprintf('Percent violations = %.1f Stdev = %.1f\n', percentSubThreshold, stdTrace )
        
        
        plot_neurons(temp_neurons{i},'elidx','dotraces_gray','electrodes', [temp_neurons{i}.el_idx(Y),temp_neurons{i}.el_idx(Y2)])
        
        title(strcat(num2str(i),'//',num2str(i),'/',num2str(percentSubThreshold),'/',num2str(stdTrace),'/',temp_neurons{i}.rgc_type))
        
        isi=temp_neurons{i}.ts;
        isi=diff(isi/20);
        isi=isi(isi<50);
        x=0:0.5:50;
        title(strcat('Cluster Number',num2str(iii)));
        subplot(3,3,8);hist(isi,x);
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor',lcolor(zv,:),'EdgeColor',lcolor(zv,:));
        ylabel('Counts','Fontsize',18);
        xlabel('Interspike interval [ms]','Fontsize',18)
        set(gca,'FontSize',18);
        xlim([0 50])
        
        
        
        % decide whether to save the cluster
        
        
        
        iCount
        
        assignCellType = 0;
        if assignCellType
            
            promptToSave = input('Cluster type','s');
            if isempty(promptToSave ) || promptToSave == 'u'  || promptToSave == 'o' || promptToSave == 'f'|| promptToSave == 'b'|| promptToSave == 'O'|| promptToSave == 'F'
                %delete traces, but keep templates
                %     temp_neurons{iii}.trace = [];
                %save data to one cell
                %                 temp_neurons{end+1} = temp_neurons{iii};
                %save cell type
                switch promptToSave
                    case 'o'
                        disp('on');
                        temp_neurons{iCount}.rgc_type = 'on';
                    case 'f'
                        disp('off');
                        temp_neurons{iCount}.rgc_type = 'off';
                    case 'b'
                        disp('on-off');
                        temp_neurons{iCount}.rgc_type = 'on-off';
                    case 'u'
                        disp('unidentified');
                        temp_neurons{iCount}.rgc_type = 'unidentified';
                    case 'O'
                        disp('sustained_on');
                        temp_neurons{iCount}.rgc_type = 'sustained_on';
                    case 'F'
                        disp('sustained_off');
                        temp_neurons{iCount}.rgc_type = 'sustained_off';
                end
                
                temp_neurons{iCount}.idx_light = idx_light;
                
                
            end
            
        end
        fprintf('Percent finished: %.0f\nNumber saved clusters: %d\n', iCount/length(electrode_list)*100, length(temp_neurons));
        temp_neurons
        
        % if  xx == 'y'
        %             disp('redo loop');
        %             %delete cells from last loop
        %             temp_neurons(temp_neuronsLength+1:end)=[];
        %             %revert to prev loop
        %             iCount = iCount-1;
        % end
    catch
        %   fprintf('error')
        beep();
    end
    
end