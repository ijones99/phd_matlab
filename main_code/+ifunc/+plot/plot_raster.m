function plot_raster(timestamps, yPosition, varargin)
% plot_raster(timestamps, yPosition, varargin)
% P.plotArgs= {'.b'}; NOTE: must be a cell!

P.plotArgs= {'.b'};
P = mysort.util.parseInputs(P, varargin, 'error');
if ~iscell(P.plotArgs)
   temp = {P.plotArgs  }; clear P.plotArgs; P.plotArgs = temp;clear temp;
end

plot(timestamps, yPosition*ones(1,length(timestamps)),P.plotArgs{:})


end