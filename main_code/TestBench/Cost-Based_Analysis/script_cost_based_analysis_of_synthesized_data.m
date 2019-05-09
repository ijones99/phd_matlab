%% create synthesized dataset
% create dataset
repeatNum = 100;
mu = 0; % distribution settings
% load Data/spikeTrainBase; % load data
spikeTrainBase = ([1:1200:150*1200]);
numSpikes = length(spikeTrainBase); % number spikes
sigmaValsJitter = 0.001*[1e-10 0.5 1 2 5 10 50 100 500 1e3 2e3 5e3 10e3 100e3 500e3]; %in seconds
synthData = create_synth_spiketrains(spikeTrainBase, repeatNum, sigmaValsJitter);


%% calculate cost-based analysis for varied sigma
figure, hold on
cmap = hsv(length(synthData)); % colormap
i=1;
progress_bar(0.0001,[],'computing')
for iSigma = 1:length(synthData)
    % q values are arbitrary and can be set; otherwise, they are set in
    % code. t_2 - t_1 = 2/q in seconds.
    [qValues meanCost stdCost] = do_cost_based_analysis(synthData{iSigma} );
    errorbar(log10(qValues),meanCost,stdCost,'-','LineWidth', 1,'Color',cmap(iSigma,:))
    synthData{iSigma}.qValues = qValues;
    synthData{iSigma}.meanCost = meanCost;
    synthData{iSigma}.stdCost = stdCost;
    fprintf('--------------Finished Loop %d--------------\n',i);pause(1);
    progress_bar(i/length(synthData),[],'computing')
    i=i+1;
    
end

% set legend & title, etc.
% title(['Cost Based Analysis of Spiketrains - ', X.sites.label, ' Sigma=', num2str(sigmaValues(iSigma))]);
title(['Cost Based Analysis of Spiketrains for Synthesized Data, 100 repeats'])
ylim([-0.1 2.2]);
% make legend
legendNames = num2str(sigmaValsJitter');
legend(legendNames)
ylabel('Total Cost/Spike (log q)')
xlabel('Log of Cost of Shifting Rel to Adding or Deleting Spike');
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',15) ;

%% plot cost-based analysis for varied sigma
figure, hold on
cmap = hsv(length(synthData)); % colormap
% load data.....
for iSigma = 1:length(synthData)
    
    errorbar(log10(synthData{iSigma}.qValues),synthData{iSigma}.meanCost, ...
        synthData{iSigma}.stdCost,'-','LineWidth', 2,'Color',cmap(iSigma,:));
    
end

% set legend & title, etc.
% title(['Cost Based Analysis of Spiketrains - ', X.sites.label, ' Sigma=', num2str(sigmaValues(iSigma))]);
title(['Cost Based Analysis of Spiketrains for Synthesized Data, 100 repeats'])
ylim([-0.1 2.2]);
% make legend
legendNames = num2str(sigmaValsJitter');
legend(legendNames)
ylabel('Total Cost/Spike')
xlabel('Log of Cost of Shifting Rel to Adding or Deleting Spike');
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',15) ;
%% determine precision
plateauQ = [];
plateauQLog = [];
sigmaValues = [];

for i=1:length(synthData)
    % get q value of 95% (plateau)
    [Y plateauInd] = find(synthData{i}.meanCost>=0.95*max(synthData{i}.meanCost),1,'first');
    plateauQ(i) = synthData{i}.qValues(plateauInd); % obtain qvalue at plateau
     
    precisionValues(i) = 2/plateauQ(i); % in seconds
    sigmaValues(i) = (synthData{i}.sigma);
end
x = sigmaValues(1:end-1);
y = ( precisionValues(1:end-1));

[a b yEst] = fit_line_least_squares(x,y);
figure, plot(x,yEst,'r','LineWidth',2); hold on
plot(x,y,'*','LineWidth',2);
xlabel('Sigma Values (One Standard Dev of Guassian Jitter Function) [sec]')
ylabel('Precision Values (2/q) [sec]')
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',15) ;
title('Precision vs. First Std. of Synthesized Jitter (Plateau at 95% Max Plot)')

%% plot zoom in
figure, plot((((1000*sigmaValues(1:end-1)))), 1000*( precisionValues(1:end-1)),'*-','LineWidth',1.5);
xlabel('Sigma Values (One Standard Dev of Guassian Jitter Function) [msec]')
ylabel('Precision Values (2/q) [msec]')
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',15) ;
title('Precision vs. First Std. of Synthesized Jitter (Plateau at 95% Max Plot)')

%% fit data from cost-based analysis 
figure

plot((((sigmaValues(1:end-1)))), 1000*( precisionValues(1:end-1)),'*-','LineWidth',1.5);
hold on
% fitobject = fit((1000*sigmaValues(1:end-1)'),1000*( precisionValues(1:end-1))','poly1')


% textLocRangeX = xlim;
% textLocRangeY = ylim;
% textLocX = (textLocRangeX(2)-textLocRangeX(1))*0.75+textLocRangeX(1);
% textLocY = (textLocRangeY(2)-textLocRangeY(1))*0.75+textLocRangeY(1);
% 
% % plot formula
% text(textLocX,textLocY,['f(x) = p1*x^2 + p2*x + p3',10, ...
%     'p1 = ',num2str(fitobject.p1),10, 'p2

% fittedData = fitobject.p1*sigmaValues.^2 ...
%     + fitobject.p2.*sigmaValues + fitobject.p3;

fittedData = fitobject.p1*sigmaValues(1:end-1).^2 ...
     + fitobject.p2;

plot(sigmaValues(1:end-1),fittedData,'r*-');

%% settings to remove spikes from dataset
clear synthData
% spikeTrainBase = [1:1200:150*1200];
percentSpikesToRemove = [0 5 10 25 50 75 90];
numSpikesInTrain = length(spikeTrainBase); %num spikes in spike train
repeatNum = 100;

%% create dataset with same ts in every repeat

for i = 1:length(percentSpikesToRemove)
    for iRepeatNum = 1:repeatNum
        synthData{i}.ts{iRepeatNum} = spikeTrainBase;
    end
end

%% create dataset with one sigma variation value
sigmaValsJitter = 0.005%0.020%0.001*[1e-10 0.5 1 2 5 10 50 100 500 1e3 2e3 5e3 10e3 100e3 500e3];
for i = 1:length(percentSpikesToRemove)
    synthData(i) = create_synth_spiketrains(spikeTrainBase, repeatNum, sigmaValsJitter);
    
end

%% apply spike removal

for i = 1:length(percentSpikesToRemove) % go through all percents removal

   % num spikes to remove
    numSpikesToRemove = round((percentSpikesToRemove(i)/100)*numSpikesInTrain); 
    
    for iRepeatNum = 1:repeatNum % go through all of the repeats in each group
        if percentSpikesToRemove(i) ~= 0 % if some spikes are to be removed, then remove them
            R = randperm(numSpikesInTrain);%generate random numbers
            spikeIndsToRem = R(1:numSpikesToRemove);%pick the first 1-n numbers          
            synthData{i}.ts{iRepeatNum}(spikeIndsToRem) = [];
        end
    end
    synthData{i}.percentSpikesRemoved = percentSpikesToRemove(i);  
    
end


    
%% calc cost-based analysis 
figure, hold on
cmap = hsv(length(synthData)); % colormap
for iPercentDel = 1:length(synthData)
    [qValues meanCost stdCost] = do_cost_based_analysis(synthData{iPercentDel} );
%     errorbar(log10(qValues),meanCost,stdCost,'-','LineWidth', 1,'Color',cmap(iPercentDel,:))
    synthData{iPercentDel}.qValues = qValues;
    synthData{iPercentDel}.meanCost = meanCost;
    synthData{iPercentDel}.stdCost = stdCost;
end
    

    
%% plot data from cost-based analysis 
figure, hold on
cmap = hsv(length(synthData)); % colormap
percentSpikesToRemove = [];
clear sigmaValues

for i = 1:length(synthData)
    sigmaValsJitter(i) = (synthData{i}.sigma);
    percentSpikesToRemove(i) = synthData{i}.percentSpikesRemoved;
end
for i = 1:length(synthData)
    errorbar(log10(synthData{i}.qValues),synthData{i}.meanCost, ...
        synthData{i}.stdCost,'-','LineWidth', 2,'Color',cmap(i,:))
end
% set legend & title, etc.
% title(['Cost Based Analysis of Spiketrains - ', X.sites.label, ' Sigma=', num2str(sigmaValues(iSigma))]);

ylim([-0.1 2.2]);
% make legend
legendNames = num2str(percentSpikesToRemove');
legend(legendNames)
% set(gca,'FontSize',14)
xlabel('Sigma Values (One Standard Dev of Guassian Jitter Function) [msec]')
ylabel('Total Cost/Spike')
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',15) ;
title(['Cost-Based Analysis of Spiketrains for Synthesized Data, Varying # Missing Spikes, sigma=', ...
    num2str(sigmaValsJitter(1))  ,', 100 repeats'])

%% determine precision
plateauQ = [];
plateauQLog = [];
sigmaValues = [];
precisionValues = [];
for i=1:length(synthData)
    % get q value of 95% (plateau)
    [Y plateauInd] = find(synthData{i}.meanCost>=0.95*max(synthData{i}.meanCost),1,'first');
    plateauQ(i) = synthData{i}.qValues(plateauInd); % qvalue at plateau
     
    precisionValues(i) = 2/plateauQ(i);
    sigmaValues(i) = (synthData{i}.sigma);
end
figure, plot((((percentSpikesToRemove))), ( precisionValues),'*-','LineWidth',2);
xlabel('Percent Missing Spikes')
ylabel('Precision Values (2/q) [sec]')
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',15) ;
title('Precision vs. Percent Missing Spikes (Plateau at 95% Max Plot)')
ylim([0 max(precisionValues)*1.1])

%% ratio of spike count side to precision side

for i=1:length(synthData)
    % get q value of 95% (plateau)
    [Y plateauUpperInd] = find(synthData{i}.meanCost>=0.95*max(synthData{i}.meanCost),1,'first');
    plateauUpperValInd = round(plateauUpperInd+(length(synthData{i}.meanCost)-plateauUpperInd)/2);
    meanCostUpper = synthData{i}.meanCost(plateauUpperValInd);
    [Y plateauLowerInd] = find(synthData{i}.meanCost>=0.05*max(synthData{i}.meanCost),1,'first');
    plateauLowerValInd = round(plateauLowerInd/2);
    meanCostLower = synthData{i}.meanCost(plateauLowerValInd);
    
%     countToPrecisionRatio(i) = meanCostLower/2;
    stdInfo(i)                               = synthData{i}.stdCost(plateauLowerValInd);
    precisionValues(i) = 2/plateauQ(i);
    sigmaValues(i) = (synthData{i}.sigma);
end

