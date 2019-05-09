function [fpOffset offsetVal ] = footprint_apply_offset(fp,varargin)
% [fpOffset offsetVal ] = FOOTPRINT_APPLY_OFFSET(fp)
%
% fp must be: [samples x channels];
%
%

baselineIdxRange = [1,8];
doTranspose = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'offset_sample_range')
            baselineIdxRange = varargin{i+1};
        elseif strcmp( varargin{i}, 'transpose')
            doTranspose = 1;
        end
    end
end

if ~doTranspose
    offsetVal = median(fp(end-baselineIdxRange(2):end,:),1);
    offsetMat = repmat(offsetVal, size(fp,1),1);
else
    offsetVal = median(fp(end-baselineIdxRange(2):end,:),1);
    offsetMat = repmat(offsetVal, size(fp,2),1);
end
fpOffset = fp-offsetMat;


end