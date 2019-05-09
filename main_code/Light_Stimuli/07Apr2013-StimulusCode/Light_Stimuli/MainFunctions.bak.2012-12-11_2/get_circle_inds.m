function [indsSection C] = get_circle_inds(frameEdgeLength, circleDiameterPix, varargin)
% [INDSSECTION] = GET_CIRCLE_INDS(FRAMEEDGELENGTH, VARARGIN)
% Purpose: get indices for either the center or surround of an image
% FRAMEEDGELENGTH: edge length of frame in pixels
% type of output: choose 'center' or 'surround'

% create circle in center; center has ones and surround has zeros
[rr cc] = meshgrid(1:frameEdgeLength);
C = sqrt((rr-round(frameEdgeLength/2)).^2+ ... 
    (cc-round(frameEdgeLength/2)).^2)<=round(circleDiameterPix/2);

if ~isempty(varargin)
   for i=1:length(varargin )
        if strcmp(varargin{i},'center')
            % get indices for center
            indsSection = find(C==1);
            
        elseif strcmp(varargin{i},'surround')
       
            % get indices for surround
            indsSection = find(C==0);
        else
            disp('Error')
        end
   end
end

% change to single data type; ones in center
C = single(C);

end

