%% raster plot

DATA_DIR = '../analysed_data/'
flist = {};
flist_for_analysis
% get file names of files containing sorted spikes' ts
spikesFileNames = dir(fullfile(DATA_DIR,strcat('fNeur_*',flist{1}(end-21:end-11),...
    '*.mat')));

% load(fullfile('StimFiles/',strcat('Stim_Frames_',flist{1}(end-21:end-11),...
%     '.mat')))

% vars
rowSpacing = 1;
rangeLim = 0.42;
acqRate = 20000; % samples per second

% get timestamps
binWidthMs = 0.5;
[heatMap, neuronTs] = find_redundant_ts(binWidthMs,flistFileNameID);

% for i =1:length(neuronTs)
%     neuronTs{i}.ts = neuronTs{i}.ts*20000;% convert ts to frames
%
% end

%% create timestamp vectors

% -------------  variable settings -------------
doPlot = 1;

if doPlot
    fullscreen = get(0,'ScreenSize');
    figure('Position',[0 -50 fullscreen(3) fullscreen(4)])
    hold on
end

% load stimframes (light_ts)
eval(['load /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/06Dec2011/',...
    'analysed_data/T11_27_53_5/01_Pre_Spikesorting/frameno_',flist{1}(end-21:end-11),'.mat']);

% light_ts=(find(diff(double(ntk2.images.frameno))==1)+860);
stimFrames= frameno;

stimFramesShift = 860; % compensate for delay of projector
stimFrames(end:end+stimFramesShift) = 0;
stimFrames(stimFramesShift+1:end) = stimFrames(1:end-stimFramesShift);
stimFrames(1:stimFramesShift)=0;

stimFrames = double(stimFrames);
stimFramesSw = diff(stimFrames);
% stimFramesSw(end+1) = 0;
% value of one at switches
stimFramesSw(2:end)=stimFramesSw(1:end-1);

% timestapms of stimulus frames: everytimepoint is a location where  the
% parapin was switched.
stimFramesTs = find(stimFramesSw==1);

% find start and end of stimulus movements
stimFramesTsStartStop = stimFramesTs(2:end)-stimFramesTs(1:end-1);

% shift values back one position
stimFramesTsStartStop(2:end)=stimFramesTsStartStop(1:end-1);

[Y stimStartInd] = find(stimFramesTsStartStop>1*20000);
stimEndInd = find(stimFramesTsStartStop>1*20000)-1;stimEndInd = stimEndInd(find(stimEndInd>0));
stimFramesTsStartStop= stimFramesTs( [stimStartInd  stimEndInd   ]);
stimFramesTsStartStop(2:end+1) = stimFramesTsStartStop(1:end);
% add first stim frame
stimFramesTsStartStop(1) = stimFramesTs(1);
stimFramesTsStartStop = sort(stimFramesTsStartStop);

%% Create a matrix containing the important parameters and associated
% timestamp

load StimFiles/StimParams_05_Curtains.mat

paramRef = zeros(4,1);
j=1;k=1;
for iHeight = Settings.CURTAIN_HEIGHT_PX*1.7
    for iVel = Settings.CURTAIN_DRIFT_VEL_PX*1.7
        
        for iBrightness = Settings.CURTAIN_BRIGHTNESS
            for iRepeats = 1:Settings.CURTAIN_REPEATS
                paramRef(:, j) = [ iBrightness; ...
                    iVel; iHeight; ...
                    stimFramesTsStartStop(k);
                    
                    ];
                
                j=j+1;
                k=k+2;
            end
        end
    end
end

paramRef = round(paramRef);

%% Get Neurons to Compare
% figure

brightnessValues = [255 0];
thresholdValues = [0.15  ];
neuronNoToCompare = [1 43 66];
sz = get( 0, 'ScreenSize' );
h = figure('Position', [sz]), hold on

iPlot = 1;
for iNeuronNoToCompare = 1:length(neuronNoToCompare);
    
    for iThresh = 1:length(thresholdValues)
        for iBrightness = 1:length(brightnessValues)
            
            
            neuronMatchVals = heatMap(neuronNoToCompare(iNeuronNoToCompare),:);
            thrVal = thresholdValues(iThresh);
            selNeuronIndToCompare = find(neuronMatchVals >thrVal);
            
            % plot raster plot from selected conditions
            % pick stimuli
            brightness = brightnessValues(iBrightness);
            driftVel = 600;
            curtainHeight = 600;
            paramRefSelInd = intersect(find(paramRef(1,:)== brightness), find(paramRef(2,:)== driftVel));
            paramRefSelInd = intersect(paramRefSelInd, find(paramRef(3,:)== curtainHeight))
            stimNoToPlot = paramRefSelInd(1);
            
            %% subplot
            figure(h)
            subplot(length(thresholdValues)*length(brightnessValues)...
                *length(neuronNoToCompare)/2,2,iPlot), hold on
            % subplot(1,2,1)
            
            %% title plot
            title(strcat('Comparison of Neuron Timestamps (br ', num2str(brightness), ', vel ', num2str(driftVel),',height', ...
                num2str(curtainHeight),', thr ',num2str(thrVal ),' neurInd ',num2str(neuronNoToCompare(iNeuronNoToCompare)) ,' )'),'FontSize', 14);
            strcat('Comparison of Neuron Timestamps (br ', num2str(brightness), ', vel ', num2str(driftVel),',height', ...
                num2str(curtainHeight),', thr ',num2str(thrVal ),' neurInd ',num2str(neuronNoToCompare(iNeuronNoToCompare)) ,' )')
            %% ....continue
            stimulusNo =stimNoToPlot*2-1;
            neursToCompare=[ selNeuronIndToCompare];
            
            
            % Variable Settings
            acqRate = 20000;
            preTimePlot = 1;% 20*acqRate; % seconds * frames
            postTimePlot = 5;% 40*acqRate; % seconds * frames
            
            stimStartFr = stimFramesTsStartStop(stimulusNo:stimulusNo+1)/acqRate;% - paramRef(4, paramRefSelInd(1))
            stimChangeFr = stimStartFr-stimStartFr(1);
            startFrame = stimStartFr(1)-preTimePlot;
            endFrame = stimStartFr(1)+postTimePlot;
            
            
            colorMap = jet(100);
            % colorbar
            iSpacing = 1;
            
            % figure('Position', [100 100 1200 800]), hold on
            
            % get names for files
            % directory
            dirName = '../analysed_data/T11_27_53_5/03_Neuron_Selection/';
            
            % file types to open
            fileNamePattern = fullfile(dirName,'st_*mat');
            
            % obtain file names
            fileNames = dir(fileNamePattern);
            
            inputStructName_st = {};
            main_el_avg_amp= [];
            for q = 1:length(neursToCompare)
                inputStructName_st{q} = strrep(fileNames(neursToCompare(q)).name,'.mat','');
                % load struct
                
                eval(['load ',fullfile(dirName,inputStructName_st{q})]);
                %     get amplitude value
                eval(['main_el_avg_amp(',num2str(q) ,') = ', ...
                    num2str(inputStructName_st{q}), '.main_el_avg_amp;']);
                
            end
            
            % sort by amp
            [xxx indSortAmp] = sort(main_el_avg_amp, 'ascend');
            
            clear selNeurTs
            selNeurTs{1}=0;
            r = 1;
            for iNeur = neursToCompare(indSortAmp)
                % ts are calculated so that stimulus begins at zero
                selNeurTs{r} = neuronTs{iNeur}.ts(find( and(neuronTs{iNeur}.ts>= startFrame,neuronTs{iNeur}.ts<= endFrame   )))-stimStartFr(1);
                r=r+1;
            end
            
            % find common ts
            selNeurTsCommon = selNeurTs{1};
            for r=2:length(selNeurTs)
                selNeurTsCommon = intersect(selNeurTsCommon, selNeurTs{r});
                
            end
            r = 1;
            for iNeur = neursToCompare(indSortAmp)
                
                
                
                
                %                 plot ts for neuron
                plot([(selNeurTs{r}); (selNeurTs{r})],...
                    [iSpacing*rowSpacing*ones(size(selNeurTs{r}))+rangeLim; ...
                    iSpacing*rowSpacing*ones(size(selNeurTs{r}))-rangeLim], 'Color', 'r')%colorMap(round(iParamSel/3*100),:))
                
                % plot common ts
%                 plot([(selNeurTsCommon); (selNeurTsCommon)],...
%                     [iSpacing*rowSpacing*ones(size(selNeurTsCommon))+rangeLim; ...
%                     iSpacing*rowSpacing*ones(size(selNeurTsCommon))-rangeLim], 'Color', 'b')%colorMap(round(iParamSel/3*100),:))
                
                textPlacement = -preTimePlot*.80;
                
                
                
                
                % neuron id number
                neurIdNum = strrep(inputStructName_st{r},'st_','');
                
                %                 text(textPlacement, iSpacing*rowSpacing, strcat('Ind',num2str( iNeur ),'Amp', ...
                %                     num2str(round2(main_el_avg_amp(indSortAmp(r)),0.1)), 'len',num2str(length(neuronTs{iNeur}.ts))));
                text(textPlacement, iSpacing*rowSpacing, strcat('Ind',num2str( iNeur ),'Amp', ...
                    num2str(round2(main_el_avg_amp(indSortAmp(r)),0.1))));
                %     text(textPlacement, iSpacing*rowSpacing, strcat('neurInd',num2str( iNeur ),'-', 'neur',neurIdNum,'-', ...
                %         num2str( round2(heatMap(neursToCompare(1),iNeur ),.0001)),'-match',num2str(main_el_avg_amp),'-amp'));
                iSpacing = 1+iSpacing;
                r=r+1;
            end
            
            plot([0 0], [0, iSpacing*rowSpacing+rangeLim], ...
                'k');%
            xlim([-preTimePlot postTimePlot])
            
            
            % plot([stimChangeFr(2) stimChangeFr(2)], [0, iSpacing*rowSpacing+rangeLim], ...
            %     'k');
            % title info
            Settings.CURTAIN_DRIFT_VEL_UM = Settings.CURTAIN_DRIFT_VEL_PX*acqRate;
            Settings.CURTAIN_HEIGHT_UM = Settings.CURTAIN_HEIGHT_PX*acqRate;
            
            % title(strcat('Slit Experiment: Raster - (Brightness: ', num2str(paramRef(1, paramRefSelInd(iParamSel))),')',...
            %     '(Drift Velocity:',num2str(paramRef(2, paramRefSelInd(iParamSel))),' um/sec)', ...
            %     '(Slit Width:', num2str(paramRef(3, paramRefSelInd(iParamSel))),  'um)'...
            %     ),'FontSize',12);
            set(gca,'YTickLabel',{''})
            xlabel('Time (sec)');
            ylabel('Neuron Number');
            iPlot = iPlot +1;
        end
    end
    figure, plot(neuronMatchVals), title(neuronNoToCompare(iNeuronNoToCompare));
end
%% select parameters of interest for plotting moving average
for iBr = [0 ]
    for iVel = [         1200]
        for iHeight = [600.0000  ]
            
            brightness = 0;
            driftVel = 0;
            curtainHeight = 0;
            n = 1;
            paramRefSelInd = 0;
            
            brightness = 0;
            driftVel = 1200;
            curtainHeight = 600;
            
            
            % find ts of interest
            paramRefSelInd = intersect(find(paramRef(1,:)== brightness), find(paramRef(2,:)== driftVel));
            paramRefSelInd = intersect(paramRefSelInd, find(paramRef(3,:)== curtainHeight));
            
            
            % Variable Settings
            doNormalize = 0;
            plotStartStopTime = 1;
            setScaleFactor = 2;
            plotColors = ['k', 'b', 'c'];
            preTimePlot = .5*acqRate; % seconds * frames
            postTimePlot = 3*acqRate; % seconds * frames
            figure, hold on
            
            if plotStartStopTime
                line([900/driftVel(1), 900/driftVel(1)], [0   length(spikesFileNames)*rowSpacing],'Color','red');
                line([0, 0 ], [0   length(spikesFileNames)*rowSpacing],'Color','red');
            end
            
            
            
            postTimePlot = (900/driftVel)*acqRate*(1.33);
            
            for i=1:length(spikesFileNames)
                try
                    
                    load(fullfile(DATA_DIR,spikesFileNames(i).name));
                    
                    % vector: will put ones in for ever ts.
                    spikeCounts = zeros(1,length([-preTimePlot: postTimePlot ]  ) );
                    boxcarAvg =  zeros(1,length([-preTimePlot: postTimePlot ]  ) );
                    
                    
                    
                    for iParamSel=1:3
                        
                        stimStartFr = paramRef(4, paramRefSelInd(iParamSel));% - paramRef(4, paramRefSelInd{iOverlays}(1))
                        
                        startFrame = stimStartFr-preTimePlot;
                        endFrame = stimStartFr+postTimePlot;
                        
                        selNeurTs = fNeur.rec_ts(find( and(fNeur.rec_ts>= startFrame,fNeur.rec_ts<= endFrame   )));
                        
                        % adjust so that all spikes start at zero
                        selNeurTs = selNeurTs-stimStartFr+preTimePlot;
                        selNeurTs(find(selNeurTs==0))=[];
                        
                        % put ones into vector for every event
                        spikeCounts( selNeurTs) = spikeCounts( selNeurTs)+1;
                        
                        
                    end
                    text(-preTimePlot/acqRate, i*rowSpacing, num2str( i ),'Color','b');
                    
                    % do boxcar
                    boxcarWindowSize = 0.025*acqRate;
                    %     for iBox=round(boxcarWindowSize/2)+1:length(boxcarAvg)-round(boxcarWindowSize/2)-1
                    %         boxcarAvg(iBox) = mean(spikeCounts(iBox-round(boxcarWindowSize/2): ...
                    %             iBox+round(boxcarWindowSize/2)) );
                    %
                    %     end
                    
                    y = filter((1/10)*ones(1,boxcarWindowSize),1, spikeCounts);
                    y = smooth(y,101);
                    
                    if doNormalize
                        scaleFactor = 0.85*rowSpacing/max(y);
                        y = y*scaleFactor;
                    elseif setScaleFactor
                        y = y*setScaleFactor;
                    end
                    
                    
                    xAxis = -preTimePlot:postTimePlot;
                    xAxis = xAxis/acqRate;
                    
                    
                    plot(xAxis, i*rowSpacing+y, 'Color',plotColors(1));
                    % colorMap(round(iParamSel/3*100),:)
                catch
                    disp('Error: no spikes?')
                end
                
            end
            
            
            
            
            % title info
            Settings.CURTAIN_DRIFT_VEL_UM = Settings.CURTAIN_DRIFT_VEL_PX*1.7;
            Settings.CURTAIN_HEIGHT_UM = Settings.CURTAIN_HEIGHT_PX*1.7;
            
            
            title(strcat('Slit Experiment: Moving Average - (Brightness: ', num2str(paramRef(1, paramRefSelInd(iParamSel))),')',...
                '(Drift Velocity:',num2str(paramRef(2, paramRefSelInd(iParamSel))),' um/sec)', ...
                '(Slit Width:', num2str(paramRef(3, paramRefSelInd(iParamSel))),  'um)'...
                ), 'FontSize',12);
            
            set(gca,'YTickLabel',{''})
            xlabel('Time (sec)');
            ylabel('Neuron Number');
            save_plot_to_file(fNeur, 4, 'tempFigs/', [], strcat('Br_',num2str(iBr),'Vel_',num2str(iVel), 'Ht_',num2str(iHeight)))
            
        end
        
        
        
    end
end


%% plot parapin changes
%
plot([stimFramesTsStartStop/acqRate; stimFramesTsStartStop/acqRate],...
    [i*rowSpacing*ones(size(stimFramesTsStartStop))+rangeLim; ...
    zeros(size(stimFramesTsStartStop))], 'Color', 'blue')

% plot settings
set(gca,'YTickLabel',{''})
xlabel('Time (sec)');
ylabel('Neuron Number');
%
% experiment labels
text(-15, i*rowSpacing+.30, {'height';'velocity'; 'brightness'});

% k=1;
% stimFramesTsStartStop = sort(stimFramesTsStartStop);
% for j = 1:2:length(stimFramesTsStartStop)
%     text( stimFramesTsStartStop(j)/acqRate, i*rowSpacing+.3,num2str(paramRef(:,k)));
%     k=k+1;
% end

Settings.CURTAIN_DRIFT_VEL_UM = Settings.CURTAIN_DRIFT_VEL_PX*1.7;
Settings.CURTAIN_HEIGHT_UM =  Settings.CURTAIN_HEIGHT_PX*1.7;

colorMap = jet;
k=1;
for j = 1:2:length(stimFramesTsStartStop)
    %     plot( [stimFramesTsStartStop(j)/acqRate], [i-.2:i+.2 ])%, ...
    %         'Color',colorMcap(round((paramRef(1,k)/max(Settings.CURTAIN_BRIGHTNESS)*64)),:))
    line([stimFramesTsStartStop(j)/acqRate, stimFramesTsStartStop(j)/acqRate], [i+.25,i+.60], ...
        'Color', colorMap(round((paramRef(1,k)/max(Settings.CURTAIN_BRIGHTNESS)*57)+1),:),...
        'LineWidth',5);
    line([stimFramesTsStartStop(j)/acqRate, stimFramesTsStartStop(j)/acqRate], [i+.60,i+.95], ...
        'Color', colorMap(round((paramRef(2,k)/(max(Settings.CURTAIN_DRIFT_VEL_UM))*57)+1),:),...
        'LineWidth',5);
    line([stimFramesTsStartStop(j)/acqRate, stimFramesTsStartStop(j)/acqRate], [i+.95,i+1.3], ...
        'Color', colorMap(round((paramRef(3,k)/max(Settings.CURTAIN_HEIGHT_UM*1.7)*57)+1),:),...
        'LineWidth',5);
    
    
    k=k+1;
end


colorbar


%% Pick neurons

for i=1:length(neuronsCollected)
    
    fprintf('%2d: %d \t', i, length(neuronsCollected{i}.ts));
    if (i/3)==round(i/3)
        fprintf('\n');
    end
    
end
fprintf('\n');





