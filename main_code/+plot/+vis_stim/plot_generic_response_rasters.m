function plot_generic_response_rasters(Rall, stimChangeTs, stimFrameInfo, clusNumInput,varargin)
% function plot_moving_bars_narrow(Rall, stimChangeTs, stimFrameInfo, clusNumInput)
% 
% varargin
%   'rgb'
%   'offset_for_all'
%
%

% SETTINGS
% plot settings
xLims = [0 4];

sortField = 'angle';

fieldNames = fields(stimFrameInfo);

for i=1:length(fieldNames)
    fieldValsSel{i} = unique(getfield(stimFrameInfo, fieldNames{i}));
end

for i=1:length(fieldNames)
    fieldVals{i} = getfield(stimFrameInfo, fieldNames{i});
end

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'x_lims')
            xLims = varargin{i+1};
        elseif strcmp( varargin{i}, 'sort_field')
            sortField = varargin{i+1};
        end
    end
    % for fields
    for i=1:length(varargin)
        for iFld = 1:length(fieldNames)
            if strcmp( varargin{i}, fieldNames{iFld})
                if i+1<= length(varargin)
                    if isnumeric(varargin{i+1})
                        fieldValsSel{iFld} = varargin{i+1};
                    end
                end
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
varIdx = find(ismember(fieldVals{1}, fieldValsSel{1}));

for i=2:length(fieldNames)
    varIdx = intersect(varIdx, ...
        find(ismember(fieldVals{i}, fieldValsSel{i})));
end

% sort according to selection
sortFieldIdx = find(ismember(fieldNames, sortField));
[Y , idxSort ] = sort(fieldVals{sortFieldIdx}(varIdx));

% create idx raster
idxRaster = [allStimChsIdx(varIdx(idxSort))' allStimChsIdx(varIdx(idxSort))'+2];

plotSpcing =1;

for iClus = clusNumInput
    
    
    clusNum = unique(Rall(:,1));
    
    offSet=0;
    stCurr = spiketrains.extract_st_from_R(Rall, clusNum(iClus));
    plot.raster_series(stCurr/2e4, stimChangeTs/2e4, idxRaster);
    
    
    for i=1:length(varIdx)
        offSet = (i-1)*plotSpcing;
        
        currAngle = stimFrameInfo.angle(varIdx(idxSort(i)));
        if i==1
            line([0 4], repmat([offSet-0.5],1,2),'Color','b');
            text(1,offSet,num2str(currAngle));
        elseif i==length(varIdx)
            line([0 4], repmat([offSet+0.5],1,2),'Color','b');
        elseif stimFrameInfo.angle(varIdx(idxSort(i))) ~= stimFrameInfo.angle(varIdx(idxSort(i-1)))
            text(1,offSet,num2str(currAngle));
            line([0 4], repmat([offSet-0.5],1,2),'Color','b');
            
        end
    end
    
    offSet = (i)*plotSpcing;
    
    xlim(xLims)
end