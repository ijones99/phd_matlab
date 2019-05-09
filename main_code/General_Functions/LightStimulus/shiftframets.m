function frameno = shiftframets( frameno, varargin)
% function frameno = shiftlightts( frameno, shiftLength)
% purpose: shift stimulus frame timestamps to account for delay from 
% computer to projector
% Phenomenon defined as "projector delay"


if ~isempty(varargin)
    shiftLength = varargin{1};
else 
    shiftLength = 860; % this is the amount of delay between the computer 
    ...instruction execution time and the actual appearance of the light stimulus:
end


frameno = single(frameno);
frameno(end+1:end+shiftLength) = 0;% put zeros into matrix
frameno(shiftLength+1:end) = frameno(1:end-shiftLength); % slide ts forward in time
frameno(1:shiftLength)=0;

end