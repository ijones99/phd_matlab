function plot_moving_DS(Rall, stimChangeTs, stimFrameInfo, clusNumInput,varargin)
% function plot_moving_bars_narrow(Rall, stimChangeTs, stimFrameInfo, clusNumInput)
% 
% varargin
%   'rgb'
%   'offset_for_all'
%
%

% init vars
% stim param var sel
valRGBIdx = 1;
valOffsetIdx =3;



% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'rgb')
            valRGBIdx = varargin{i+1};
        elseif strcmp( varargin{i}, 'offset_for_all')
            valOffsetIdx = varargin{i+1};
        end
    end
end



if iscell(Rall)
    RallNew = Rall{1};
    clear Rall;
    Rall = RallNew;
    clear RallNew;
end

if iscell(stimChangeTs)
    stimChangeTsNew = stimChangeTs{1};
    clear stimChangeTs;
    stimChangeTs = stimChangeTsNew;
    clear stimChangeTsNew;
end

% stimFrameinfo check
fieldNames = fields(stimFrameInfo);
parapinChanges = length(getfield(stimFrameInfo,fieldNames{1}));
if length(stimChangeTs)/2 ~= parapinChanges
   warning('!!!wrong stimChangeTs');
end

%% SETTINGS
% plot settings
xLims = [-0.25 4];

% stim param vars
valRGB = unique(stimFrameInfo.rgb);
valAngle = unique(stimFrameInfo.angle);
valOffset = unique(stimFrameInfo.offset);

% get stim onset timestamps
allStimChsIdx = 1:2:length(stimChangeTs);

% indices of specific combination of settings
varIdx = intersect(intersect(find(ismember(stimFrameInfo.angle,valAngle)),...
    find(stimFrameInfo.rgb==valRGB(valRGBIdx) & stimFrameInfo.offset==valOffset(valOffsetIdx)),find(stimFrameInfo.speed==600)));

% sort according to angle
[Y , angleIdxSort ] = sort(stimFrameInfo.angle(varIdx));

% create idx raster
idxRaster = [allStimChsIdx(varIdx(angleIdxSort))' allStimChsIdx(varIdx(angleIdxSort))'+2];

plotSpcing =1;

for iClus = clusNumInput
    
    
    clusNum = unique(Rall(:,1));
    
    offSet=0;
    stCurr = spiketrains.extract_st_from_R(Rall, iClus);
    plot.raster_series(stCurr/2e4, stimChangeTs/2e4, idxRaster);
    
    
    for i=1:length(varIdx)
        offSet = (i-1)*plotSpcing;
        
        currAngle = stimFrameInfo.angle(varIdx(angleIdxSort(i)));
        if i==1
            line([0 4], repmat([offSet-0.5],1,2),'Color','b');
            text(1,offSet,num2str(currAngle));
        elseif i==length(varIdx)
            line([0 4], repmat([offSet+0.5],1,2),'Color','b');
        elseif stimFrameInfo.angle(varIdx(angleIdxSort(i))) ~= stimFrameInfo.angle(varIdx(angleIdxSort(i-1)))
            text(1,offSet,num2str(currAngle));
            line([0 4], repmat([offSet-0.5],1,2),'Color','b');
            
        end
    end
    
    offSet = (i)*plotSpcing;
    
    xlim(xLims)
end