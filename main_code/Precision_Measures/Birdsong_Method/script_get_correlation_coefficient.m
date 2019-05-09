
% load ../analysed_data/T11_10_23_6_orig_stat_surr_med_plus_others/selNeuronInds.mat;
selNeuronInds = sort(selNeuronInds);

% file id info
idNameStartLocation = strfind(flist{1},'T');idNameStartLocation(1)=[];
idNameEndLocation = strfind(flist{1},'.stream.ntk')-1;
flistFileNameID = strcat(flist{1}(idNameStartLocation:idNameEndLocation),'_orig_stat_surr_med_plus_others');
recDir = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/';
genDataDir = fullfile(recDir,'/25Apr2012/analysed_data/');
specDataDir = fullfile(genDataDir, flistFileNameID);
framenoFileName = strcat('frameno_', flistFileNameID, '.mat');

% load light timestamp framenos
load(fullfile(genDataDir,flistFileNameID,framenoFileName));

% shift timestamps for stimulus frames
frameno = shiftframets(frameno);

% tsmatrix
tsMatrix = load_spiketrains(flistFileNameID);

% selecting spikes
CC = single(zeros(2, length(selNeuronInds)));iCC =1;
for iNeuron = selNeuronInds(1:end)%1:length(tsMatrix)
    for iStimNum = 1:2
        stimNum = iStimNum;
        acqRate = 2e4;
        % iNeuron = 50;
        % all spikes for this neur
        spiketrainEntire = tsMatrix{iNeuron}.ts;
        
        % start time indices for stimulus
        numStimStartIndPerCluster = 35;
        numStimStartIndsToDrop = 5;
        indStimIndStartFirst = (stimNum-1)*(numStimStartIndPerCluster*2+1)+1;
        indStimIndStarts = repmat(indStimIndStartFirst,1,numStimStartIndPerCluster)+[0:2:numStimStartIndPerCluster*2-2];
        
        % get stop and start times
        interStimIntervalSec=.2;
        stimFramesTsStartStop = get_stim_start_stop_ts(frameno, interStimIntervalSec);
        
        selSpikes = {};stimDurSec = {};
        for iRep = numStimStartIndsToDrop+1:numStimStartIndPerCluster
            
            stimStartTs = stimFramesTsStartStop(indStimIndStarts(iRep))/acqRate;
            stimStopTs = stimFramesTsStartStop(indStimIndStarts(iRep)+1)/acqRate;
            
            selSpikes{end+1} = double(get_selected_spikes(spiketrainEntire, stimStartTs, stimStopTs, 'align_to_zero'));
            stimDurSec{end+1} = (stimStopTs-stimStartTs);
        end
        %% get spike rate
        %         figure, hold on
        spikeRate = {};spikeRateInds={}; precision=0.0001;binningInterval = 0.01;
        for i=1:length(selSpikes)
            
            % get spiking rate for each spiketrain
            %     spikeRate{i} = get_psth(selSpikes{i},0 ,stimDurSec{end}, 0, stimDurSec{end}, ...
            %         binningInterval)/binningInterval;
            tt = [0:binningInterval :stimDurSec{end} ];
            
            
            spikeRate{i} = instantfr(selSpikes{i}, tt);
            %         plot(tt, spikeRate{i});
        end
        %% Guassian convolution
        sigma = 0.01; %Standard deviation of the kernel = 15 ms
        edges=[-3*sigma:precision:3*sigma]; %Time ranges form -3*st. dev. to 3*st. dev.
        kernel = normpdf(edges,0,sigma); %Evaluate the Gaussian kernel
        kernel = kernel*binningInterval; %Multiply by bin width so the probabilities sum to 1
        
        %         figure, hold on
        convolvedSpikes = {};
        
        for i=1:length(spikeRate)
            convolvedSpikes{i}=conv(double(spikeRate{i}),	kernel ,	'same');
            convolvedSpikes{i}=convolvedSpikes{i}-mean(convolvedSpikes{i});
            %         plot(convolvedSpikes{i});
        end
        
        %% calculate corr. coeff. CC
        % all poss pairs
        combos = combntns(1:length(spikeRate),2);
        CC_ij = [];
        for i=1:length(combos)
            %             siz = min(length(convolvedSpikes{combos(i,1)}),length(convolvedSpikes{combos(i,2)}));
            %             CC_ij(i) = corr2(convolvedSpikes{combos(i,1)}(1:siz),convolvedSpikes{combos(i,2)}(1:siz));
            frCorrCoef = corrcoef(convolvedSpikes{combos(i,1)}, convolvedSpikes{combos(i,2)});
            CC_ij(i) = frCorrCoef(1,2);
           
        end
        
        CC(iCC,iStimNum) = (1/length(combos))*nansum(CC_ij);
        
    end
    iCC = iCC+1;
    iCC/length(selNeuronInds)
end

%% plot data
figure, hold on
x = 1:length(selNeuronInds);
plot(x,CC(:,1)*100+100,'o','LineWidth',2)
plot(x,CC(:,2)*100+100,'or','LineWidth',2)
% set(gca,'MarkerWidth',2)
%%
title('Correlation Coefficient Per Neuron Per 30-Count Repetition of Movie Stimulus','FontSize',16)
% xlabel('Neuron Index');
ylabel('Corr. Coeff.','FontSize',16);
legend('Original', 'Static Surround');

neurLabels = cell(1,length(selNeuronInds)) ;
for iLabel = 1:length(selNeuronInds)
   neurLabels{iLabel} = strrep(tsMatrix{selNeuronInds(iLabel)}.name,'_', '-'); 
end


set(gca,'XTick',1:length(selNeuronInds));
set(gca,'XTickLabel',neurLabels);
set(gca,'FontSize',16);
rotateticklabel(gca,45)

doSave = 0;
if doSave
    exportfig(gcf,fullfile('Figs/', 'Spike_Count_and_Corr_Coeff_Orig_and_Stat_Surr'), ...
        'width',6, 'fontmode','fixed', 'fontsize',8,'Color', 'cmyk');
end
