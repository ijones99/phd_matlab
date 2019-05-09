function plot_moving_bars_spatialtemporal_tuning(Rall, stimChangeTs, stimFrameInfo, clusNumInput,varargin)
% function plot_moving_bars_narrow(Rall, stimChangeTs, stimFrameInfo, clusNumInput)
% 
% varargin
%   'rgb'
%   'offset_for_all'
%
%

% SETTINGS
% plot settings
xLims = [0 10];

sortField = 'angle';

fieldNames = fields(stimFrameInfo);

for i=1:length(fieldNames)
    fieldValsUniqueVals{i} = unique(getfield(stimFrameInfo, fieldNames{i}));
end

for i=1:length(fieldNames)
    fieldVals{i} = getfield(stimFrameInfo, fieldNames{i});
end

% check for arguments
if ~isempty(varargin)
    % for fields
    for i=1:length(varargin)
        for iFld = 1:length(fieldNames)
            if strcmp( varargin{i}, fieldNames{iFld})
                 fieldValsUniqueVals{iFld} = varargin{i+1};
            end
            
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

% get stim onset timestamps
allStimChsIdx = 1:2:length(stimChangeTs);

% indices of specific combination of settings
varIdx = find(ismember(fieldVals{1}, fieldValsUniqueVals{1}));
for i=2:length(fieldNames)
    varIdx = intersect(varIdx, ...
        find(ismember(fieldVals{i}, fieldValsUniqueVals{i})));
end

% sort according to selection
sortFieldIdx = find(ismember(fieldNames, sortField));
[Y , idxSort ] = sort(fieldVals{sortFieldIdx}(varIdx));

% create idx raster
idxRaster = [allStimChsIdx(varIdx(idxSort))' allStimChsIdx(varIdx(idxSort))'+2];

plotSpcing =1;

for iClus = 1:length(clusNumInput)
    
    
    clusNum = clusNumInput;
    numStimChangeTs = length(stimChangeTs);
    
    % to protect against missing timechange idxs
    idxInvalidStimChangeIdx = find(idxRaster>numStimChangeTs);
    if ~isempty(idxInvalidStimChangeIdx)
        idxRaster(idxInvalidStimChangeIdx) = numStimChangeTs;
        warning('Invalid stim change idx values.');
    end
    
    meanDuration = mean(diff(stimChangeTs(idxRaster),[], 2)/2e4);
    xLims = [0 meanDuration];
    offSet=0;
    stCurr = spiketrains.extract_st_from_R(Rall, clusNum(iClus));
    plot.raster_series(stCurr/2e4, stimChangeTs/2e4, idxRaster);
 
    
    xOffsetText = -2;
    
    for i=1:length(varIdx)
        offSet = (i-1)*plotSpcing;
        
        currAngle = stimFrameInfo.angle(varIdx(idxSort(i)));
        if i==1
            line(xLims, repmat([offSet-0.5],1,2),'Color','b');
            text(xOffsetText,offSet,num2str(currAngle));
        elseif i==length(varIdx)
            line(xLims, repmat([offSet+0.5],1,2),'Color','b');
        elseif stimFrameInfo.angle(varIdx(idxSort(i))) ~= stimFrameInfo.angle(varIdx(idxSort(i-1)))
            text(xOffsetText,offSet,num2str(currAngle));
            line(xLims, repmat([offSet-0.5],1,2),'Color','b');
            
        end
    end
    
    offSet = (i)*plotSpcing;
    % plot settings    
    set(gca, 'YTickLabel','');
    xlim(xLims)
    xlabel('time (seconds)');
end