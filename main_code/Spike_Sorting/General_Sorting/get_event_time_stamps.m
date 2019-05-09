
function [spikeTimes, spikesPerChannel] = get_event_time_stamps(ntk2,preTime, postTime, acquisitionRate, thresholdMultiplier)
%   get_event_time_stamps: input signal vector; output vector with timestamps
%   for all spike traces from all channels. These timestamps range from
%   -preTime to +postTime for each event (i.e. spike)


% function [traceTimeStamps, eventTimeStamps] = geteventtimestamps(ntk2,preTime (frames), postTime (frames), acquisitionRate, thresholdMultiplier)
% 
% author ijones
%


inputSignal=ntk2.sig;
%rms value of inputSignal
    for i = 1:size(inputSignal,2)
        signalRMS(i) = rms(inputSignal(:,i));
        i/size(inputSignal,2);
    end
    
    %calculate threshold value
    thresholdValue = -1*thresholdMultiplier*signalRMS;

    % collect exceeded threshold timestamps from each channel and combine them.
for o=1:size(inputSignal,2)
    o/size(inputSignal,2)
    %get timestamps where inputSignal exceeds threshold
    pointsExceedingThreshold = inputSignal(:,o) < thresholdValue(o);
    
    %timepoints where threshold is crossed
    spikeTimes{o} = zeros(1,size(pointsExceedingThreshold,1));
    spikeTimes{o}(2:end) = pointsExceedingThreshold(2:end)-pointsExceedingThreshold(1:end-1);
    
    %remove negative ones
    spikeTimes{o}(spikeTimes{o}<0)=0;
    
    %remove spikes at begining and end
    spikeTimes{o}(1:preTime) = 0;
    spikeTimes{o}(end-postTime:end) = 0;
    spikesPerChannel(o) = length(find(spikeTimes{o}==1));
end




% glob_idx=0;
% loc_idx=1;
% plot_all=0;
% show_heat_map = 1;
% 
% 
% v=2;
% if plot_all
%     el=hidens_get_all_electrodes(v);
%     plot(el.x,el.y,'b.','Markersize',1)
% end
% axis ij
% axis equal
% xlabel( 'x [um]')
% ylabel( 'y [um]')
% % box on
% hold on
% % plot(ntk2.x,ntk2.y,'r.') % do plot
% 
% heatMapMatrixX = round(max(ntk2.x)+border - min(ntk2.x)-border );
% heatMapMatrixY = round(max(ntk2.y)+border - min(ntk2.y)-border );
% 
% 
% 
% heatMapMatrix = ones(heatMapMatrixY, heatMapMatrixX)*mean(spikesPerChannel);
% 
% for j=1:length(ntk2.el_idx)
%     if glob_idx
%         textl=ntk2.el_idx(j);
%         text(ntk2.x(j),ntk2.y(j),num2str(textl), 'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Bottom', 'FontSize', 9, 'Color', [0.2 0.2 0.2]);
%     elseif loc_idx
%         textl=j;
%         text(ntk2.x(j),ntk2.y(j),num2str(textl), 'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Bottom', 'FontSize', 9, 'Color', [0.2 0.2 0.2]);
%     end
%         
%     
%         heatMapMatrix(round(ntk2.y(j))-min(heatMapMatrixConstraintsY),round(ntk2.x(j))-min(heatMapMatrixConstraintsX)) = spikesPerChannel(j);
%  
%     
% end
% 
% if ~plot_all
%     border=11.3583;                         % adjust to like plot_neurons (?)
%     xlim([min(ntk2.x)-border max(ntk2.x)+border])
%     ylim([min(ntk2.y)-border max(ntk2.y)+border])
% end
% 


end
