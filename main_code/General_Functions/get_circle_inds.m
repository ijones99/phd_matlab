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
        elseif strcmp(varargin{i},'ring')
            
            % find difference of pixel values
            C = diff(C);
            C(:,2:end)=C(:,2:end)+C(:,1:end-1);
            C(2:end,:)=C(2:end,:)+C(1:end-1,:);
            C(end+1,:) = 0;
            C(find(abs(C)>0)) = 1;%set ring values to one
            indsSection = find(C==1);
            
        else
            disp('Error')
        end
   end
end

% change to single data type; ones in center
C = single(C);


end

