% script calculate stats on 
numParamsVals = 5;

paramClusNo = unique(idxAssigns);
numParamClus = length(paramClusNo);

paramClusCell = {};
paramMean = zeros(numParamClus,numParamsVals );
paramStd =  zeros(numParamClus,numParamsVals );

for i=1:numParamClus
    
    currIdx = find(idxAssigns==paramClusNo(i));
    paramClusCell{i} = paraOutputMat.params(currIdx,:);
    paramMean(i,:) = mean(paraOutputMat.params(currIdx,1:numParamsVals),1);
    paramStd(i,:) = std(paraOutputMat.params(currIdx,1:numParamsVals),1);
    
end

%%
nclass=numParamClus;

colorMats = graphics.distinguishable_colors(nclass,[1 1 1]);

fontSize = 10;
h=figure, hold on

for i=1:length(C)
    subplot(2,5,i), hold on
    figureHandle = gcf;
    %# make all text in the figure to size 14 and bold
    set(findall(figureHandle,'type','text'),'fontSize',fontSize); %,'fontWeight','bold'

    scatter(paramMean(:,C(i,1)),paramMean(:,C(i,2)),[],colorMats,'Filled')
        
    
    
    title(sprintf('%s vs %s', headingNames{C(i,1)},headingNames{C(i,2)}));
    xlabel(upper(headingNames{C(i,1)}));
    ylabel(upper(headingNames{C(i,2)}));
    %     xlim(xLims(i,:));
    if strcmp(doLims,'y')
        set(gca,'XTick',linspace(xLims(i,1),xLims(i,2),2)); xlim([xLims(i,:)])
        ylim(yLims(i,:));
    else
        axis auto
    end
    axis square
    set(gca,'FontSize',fontSize)
    
    set(findall(gcf,'type','text'),'FontSize',fontSize)
    
    
end


suptitle('Means of Parameters By Cluster')



