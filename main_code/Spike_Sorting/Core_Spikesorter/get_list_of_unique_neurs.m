function neuronIndsToCompare = get_list_of_unique_neurs(thrVal, flistName, varargin)
% get_list_of_unique_neurs(thrVal)
doPlot = 0;
locOfT = strfind(flistName{1},'T');locOfT = locOfT(2);
flistFileNameID = flistName{1}(locOfT:end-11);
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp(varargin{i}, 'do_plot')
            doPlot = 1;
        elseif strcmp(varargin{i}, 'add_dir_suffix')
            flistFileNameID = strcat(flistName{1}(locOfT:end-11),varargin{i+1} );
        end
        
        
        
    end
end

if ~isempty(varargin)
   for i=1:length(varargin)

       
   end
    
end

% - thrVal: enter decimal [0.0 - 1.0]
% determine if there are multiple files
% if length(flistName) > 1
%     % ID number for files
%     flistFileNameID = strcat(flistName{1}(end-21:end-11),'_plus_others');
% else
%     % ID number for files
%     flistFileNameID = flistName{1}(end-21:end-11);
% end

%% raster plot
% flistFileNameID = flistName(end-21:end-11);

DATA_DIR = '../analysed_data/';
FILE_DIR = strcat(DATA_DIR, flistFileNameID,'/');
flist = {};
flist_for_analysis;

% vars
rowSpacing = 1;
rangeLim = 0.42;
acqRate = 20000; % samples per second

% get timestamps
binWidthMs = 0.5; % bin size for matching spikes

% create heatmap of matching ts.
[heatMap, neuronTs] = get_heatmap_of_matching_ts(binWidthMs,flistFileNameID);

%% create timestamp vectors

% -------------  variable settings -------------


% if doPlot
%     fullscreen = get(0,'ScreenSize');
%     figure('Position',[0 -50 fullscreen(3) fullscreen(4)])
%     hold on
% end

% load stimframes (light_ts)
eval(['load ', FILE_DIR,...
    'frameno_',flistFileNameID,'.mat']);

% light_ts=(find(diff(double(ntk2.images.frameno))==1)+860);
stimFrames= frameno;

stimFramesShift = 860; % compensate for delay of projector
stimFrames(end:end+stimFramesShift) = 0;% put zeros into matrix
stimFrames(stimFramesShift+1:end) = stimFrames(1:end-stimFramesShift); % slide ts forward in time
stimFrames(1:stimFramesShift)=0;%put zeros where first 860 frames were

stimFrames = double(stimFrames);
stimFramesSw = diff(stimFrames);

% value of one at switches
stimFramesSw(2:end)=stimFramesSw(1:end-1);

% timestapms of stimulus frames: everytimepoint is a location where  the
% parapin was switched.
stimFramesTs = find(stimFramesSw==1);

% find start and end of stimulus movements
stimFramesTsStartStop = stimFramesTs(2:end)-stimFramesTs(1:end-1);

% shift values back one position
stimFramesTsStartStop(2:end)=stimFramesTsStartStop(1:end-1);

% find locations where stimulus starts (where there is a break of >1
% second)
[Y stimStartInd] = find(stimFramesTsStartStop>1*20000);
stimEndInd = find(stimFramesTsStartStop>1*20000)-1;stimEndInd = stimEndInd(find(stimEndInd>0));
stimFramesTsStartStop= stimFramesTs( [stimStartInd  stimEndInd   ]);
stimFramesTsStartStop(2:end+1) = stimFramesTsStartStop(1:end);
% add first stim frame
stimFramesTsStartStop(1) = stimFramesTs(1);
stimFramesTsStartStop = sort(stimFramesTsStartStop);

% stimFramesTsStartStop contains all locations where stimulus started and
% stopped; odd values are the start points and even values are the end
% points

%% Create a matrix containing the important parameters and associated
% timestamp

if doPlot

load StimFiles/StimParams_Bars.mat

% approx value
Settings.ifi = 1/60;

paramRef = zeros(4,1);
j=1;k=1;

for iHeight = Settings.BAR_HEIGHT_PX
    for iVel = Settings.BAR_DRIFT_VEL_PX
        for iBrightness = 1:length(Settings.BAR_BRIGHTNESS)
            % Translate requested speed of the grating (in cycles per second) into
            % a shift value in "pixels per frame", for given waitduration: This is
            % the amount of pixels to shift our srcRect "aperture" in horizontal
            % directionat each redraw:
            shiftperframe= iVel * Settings.ifi;
            
            for iRepeats = 1:Settings.BAR_REPEATS
                
                
                paramRef(:, j) = [ double( Settings.BAR_BRIGHTNESS(iBrightness)); ...
                    double(iVel); double(iHeight); ...
                    double(stimFramesTsStartStop(k)) ...
                    
                    ];
                
                j=j+1;
                k=k+2;
            end
        end
    end
end

paramRef = round(paramRef);
end


%% Get Unique Neurons
% figure

% list of all neuron inds; is reduced as neurs are eliminated
neurIndsToCompare = 1:size(heatMap,1);

% init unique neur id's
uniqueNeurInds = [];

% -- load all amplitudes & load number of ts per neur ind --

% init vars
inputStructName_st = {};
main_el_avg_amp= [];

colorMap = jet(100);
% colorbar


% get names for files
% directory
dirName = strcat('../analysed_data/', flistFileNameID,'/03_Neuron_Selection/');

% file types to open
fileNamePattern = fullfile(dirName,'st_*mat');

% obtain file names
fileNames = dir(fileNamePattern);

for q = 1:size(heatMap,1)
    
    inputStructName_st{q} = strrep(fileNames(neurIndsToCompare(q)).name,'.mat','');
    % load struct
    eval(['load ',fullfile(dirName,inputStructName_st{q})]);
    %     get amplitude value
    eval(['main_el_avg_amp(',num2str(q) ,') = ', ...
        num2str(inputStructName_st{q}), '.main_el_avg_amp;']);
        %     get # ts
    eval(['main_el_avg_tslength(',num2str(q) ,') = length(', ...
        num2str(inputStructName_st{q}), '.ts);']);
end

while length(neurIndsToCompare) > 0
            % define neuron to compare to rest
            mainNeurIndToCompare = neurIndsToCompare(1);
             
            % find neuron inds that have a matching value greater than the threshold
            matchNeurInds = find(heatMap(mainNeurIndToCompare,:)>thrVal);
            
            % ensure that neuron inds have not already been eliminated
            matchNeurInds = intersect(matchNeurInds, neurIndsToCompare);
            
            % if there are values to rank...
            if ~isempty(matchNeurInds )
                
                % -- find "best" of selected neuron inds --
                % multiply neur amp by number ts
                neurRankVal = main_el_avg_amp([matchNeurInds]);
                            
                % assign neuron ind with max rank value to list
                uniqueNeurInds(end+1) = matchNeurInds(find(neurRankVal==max(neurRankVal),1));
                
                % remove examined neuron inds from list
                neurIndsToCompare(find(ismember(neurIndsToCompare,  matchNeurInds)>0)) = [];
            end
            
end
neuronIndsToCompare = [uniqueNeurInds];
%% Get Neurons to Compare
% figure
if doPlot
brightnessValues = [Settings.BAR_BRIGHTNESS(1) Settings.BAR_BRIGHTNESS(2) ];            

driftVel = 349;
curtainHeight = 349;
thresholdValues = [0.15  ];
sz = get( 0, 'ScreenSize' );
h = figure('Position', [sz]); hold on
% Variable Settings
acqRate = 20000;
preTimePlot = 1;% 20*acqRate; % seconds * frames
postTimePlot = 5;% 40*acqRate; % seconds * frames
iPlot = 1;
inputStructName_st = {};
main_el_avg_amp= [];

iPlot = 1;
iSpacing = 1;

for iNeuronIndsToCompare = 1:length(neuronIndsToCompare)
    
    for iThresh = 1:length(thresholdValues)
        for iBrightness = 1:length(brightnessValues)
            
            neuronMatchVals = heatMap(neuronIndsToCompare(iNeuronIndsToCompare),:);
            thrVal = thresholdValues(iThresh);
            selNeuronIndToCompare = find(neuronMatchVals >thrVal);
            
            % plot raster plot from selected conditions
            % pick stimuli
            brightness = brightnessValues(iBrightness);

            paramRefSelInd = intersect(find(paramRef(1,:)== brightness), find(paramRef(2,:)== driftVel));
            paramRefSelInd = intersect(paramRefSelInd, find(paramRef(3,:)== curtainHeight));
            stimNoToPlot = paramRefSelInd(1);
            
             for xxx=1
                if iNeuronIndsToCompare==1
                    % subplot
                    figure(h)
                    subplot(1,2,iBrightness); hold on
                    
                    % title plot
                    title(strcat('Comparison of Neuron Timestamps (br ', num2str(brightness), ', vel ', num2str(driftVel),',height', ...
                        num2str(curtainHeight),', thr ',num2str(thrVal ),' neurInd ',num2str(iNeuronIndsToCompare) ,' )'),'FontSize', 14);
                    strcat('Comparison of Neuron Timestamps (br ', num2str(brightness), ', vel ', num2str(driftVel),',height', ...
                        num2str(curtainHeight),', thr ',num2str(thrVal ),' neurInd ',num2str(iNeuronIndsToCompare) ,' )')
                end
            end
            figure(h)
            set(gca,'FontSize',16)
            subplot(1,2,iBrightness); hold on
            
            stimulusNo =stimNoToPlot*2-1;
                  
            stimStartFr = stimFramesTsStartStop(stimulusNo:stimulusNo+1)/acqRate;% - paramRef(4, paramRefSelInd(1))
            stimEndFr = stimStartFr(2); % in seconds
            stimChangeFr = stimStartFr-stimStartFr(1);
            startFrame = stimStartFr(1)-preTimePlot;
            endFrame = stimStartFr(1)+postTimePlot;
            

            
            % ts are calculated so that stimulus begins at zero
            selNeurTs = neuronTs{iNeuronIndsToCompare}.ts(find( and(neuronTs{iNeuronIndsToCompare}.ts>= ...
                startFrame,neuronTs{iNeuronIndsToCompare}.ts<= endFrame   )))-stimStartFr(1);
           
            %  plot ts for neuron
            plot([(selNeurTs); (selNeurTs)],...
                [iSpacing*rowSpacing*ones(size(selNeurTs))+rangeLim; ...
                iSpacing*rowSpacing*ones(size(selNeurTs))-rangeLim], 'Color', 'r')%colorMap(round(iParamSel/3*100),:))
            
            textPlacement = -preTimePlot*.80;
            
%             neurIdNum = strrep(inputStructName_st{iSpacing},'st_','');
            text(textPlacement, iSpacing*rowSpacing, strcat('Ind',num2str( neuronIndsToCompare(iNeuronIndsToCompare ))),'FontSize', 16);
            
            plot([0 0], [0, iSpacing*rowSpacing+rangeLim], ...
                'k');%
            plot([stimEndFr-stimStartFr(1) stimEndFr-stimStartFr(1) ], [0, iSpacing*rowSpacing+rangeLim], ...
                'k');%
            xlim([-preTimePlot postTimePlot])
    
            Settings.BAR_DRIFT_VEL_UM = Settings.BAR_DRIFT_VEL_PX*acqRate;
            Settings.BAR_HEIGHT_UM = Settings.BAR_HEIGHT_PX*acqRate;
            
            set(gca,'YTickLabel',{''})
            xlabel('Time (sec)');
            ylabel('Neuron Number');
            iPlot = iPlot +1;
        end
        iSpacing = 1+iSpacing;
        end
end
end
end