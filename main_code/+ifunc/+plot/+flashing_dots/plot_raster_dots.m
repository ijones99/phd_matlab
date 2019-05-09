function plot_raster_dots(data,varargin)
% function plot_raster_dots(data,varargin)
% P.color = 'b';

P.color = {'b.', 'r.'};
P.randColor = [];
P.rasterHeightIncrement = 0.1;
P.drawStimSepLines = [];
P.stimLims = [];
P = mysort.util.parseInputs(P, varargin, 'error');
newLine = 0;
[B, index] = sortrows(data.Flashing_Dots.processed_data.stimulus,[1 2]);
hold on
for i=1:length(index)
    
    if data.Flashing_Dots.processed_data.stimulus(index(i),1)>0
        plotColorInd = 2;
    else
        plotColorInd = 1;
    end
    spikeTimes = data.Flashing_Dots.processed_data.repeatSpikeTimeTrain{index(i)}/2e4;
    
    spotDiam = data.Flashing_Dots.processed_data.stimulus(index(i),2);
    
    if ~isempty(P.drawStimSepLines)
        if i==1
            newLine = 1;
            plot([0 P.drawStimSepLines],ones(1,2)*0,'k' );
            text(-0.1, 0,num2str(spotDiam),'FontSize', 14);
        else
            if data.Flashing_Dots.processed_data.stimulus(index(i),2) ~= data.Flashing_Dots.processed_data.stimulus(index(i-1),2)
               yHeight = ((i-1)+0.5)*P.rasterHeightIncrement;
                plot([0 P.drawStimSepLines],ones(1,2)*yHeight,'k' );
               text(-0.1,yHeight,num2str(spotDiam),'FontSize', 14);
            end
        end
    end
    
    
    if ~isempty(P.randColor )
        if i==1
            randColor = {'.', 'Color', rand(1,3)};
        else
            if data.Flashing_Dots.processed_data.stimulus(index(i),2) ~= data.Flashing_Dots.processed_data.stimulus(index(i-1),2)
                randColor = {'.', 'Color', rand(1,3)};
            end
        end
        ifunc.plot.plot_raster(spikeTimes,...
            i*P.rasterHeightIncrement,'plotArgs', ...
            randColor(:)) ;  
    else
        ifunc.plot.plot_raster(spikeTimes,...
            i*P.rasterHeightIncrement,'plotArgs', ...
            P.color(plotColorInd)) ;
    end
    
    
    if ~isempty(P.stimLims)
       xlim( [P.stimLims]);
    end
    
    set(gca,'YTickLabel','');
    set(gca,'YDir','reverse');
    
end


