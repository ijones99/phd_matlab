
%% try for a range of q values
clear meanCost; clear stdCost
meanCost = cell(X.M,1); stdCost = cell(X.M,1);
qValuesLabel = {};
costVals = cell(X.M,1);
qExp = [-5:6];

qValues = [ 10.^qExp ]

for iQValue = qValues
    iQValue
    % Calculate costs
    % compare when only # spikes used
    opts.shift_cost =  iQValue; % seconds
    Y = metric(X, opts)
    qValuesLabel{end+1} = strcat([ num2str(log10(iQValue))]) ;
    % for number of categories
    for iCat = 1:X.M
        
        % get cost values
        costVals{iCat} = Y.d(1:numTrialsUsed,1+((iCat-1)*numTrialsUsed):numTrialsUsed*iCat);
        % remove zeros
        costVals{iCat} = costVals{iCat}(find(costVals{iCat}>0))/avgNumSpikes;
        % calculated values
        meanCost{iCat}(end+1) = mean(costVals{iCat});
        stdCost{iCat}(end+1) = std(costVals{iCat});
    end
end
%% 
% scale costs
costScaleFactor = 100/max(meanCost);
meanCost = meanCost*costScaleFactor;
stdCost = stdCost*costScaleFactor;
%%
%% compare self and with other
% Calculate costs
% compare when only # spikes used 
costValuesLabel = {};
opts.shift_cost =  0.02; % seconds
Y = metric(X, opts)
costValuesLabel{end+1} = strcat(['shift cost=', num2str(opts.shift_cost )]) ;
% get cost values
costValsAuto = Y.d(1:numTrialsUsed,1:numTrialsUsed); 
costValsCross = Y.d(1:numTrialsUsed,numTrialsUsed+1:numTrialsUsed*2);
% remove zeros
costValsAuto = costValsAuto(find(costValsAuto>0));
costValsCross = costValsCross(find(costValsCross>0));
% calculated values
meanCost = mean(costValsAuto);
meanCost(end+1) = mean(costValsCross);
stdCost = std(costValsAuto);
stdCost(end+1) = std(costValsCross);

%plot
figure, hold on 
errorbar(meanCost,stdCost,'.')
bar(meanCost)
% axis([.75 4.25 0 55])
set(gca, 'XTick', 1:2, 'XTickLabel', {'Auto Cost', 'Cross Cost'})
title(strcat(['Cost Based Analysis of Spiketrains - ', X.sites.label]));
ylabel('Total Cost')
