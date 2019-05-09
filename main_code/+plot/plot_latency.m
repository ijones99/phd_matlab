function plot_latency(wfsCtr,x,y, varargin)
% function plot_peak2peak_amplitudes(wfsCtr,x,y, varargin)
%
% varargin
%   xy_res: [# #] to specify resolution of plot
%   'sig_thresh_mult_of_std'
%   'xy_res'
%   'sig_thresh_mult_of_std'
%

Fs = 2e4;
xyRes = [100 100];
hFig = [];
nContourLines = 40;
sigThreshMultStd = 5;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'xy_res')
            xyRes = varargin{i+1};        
        elseif strcmp( varargin{i}, 'h_fig')
            hFig = varargin{i+1};
        elseif strcmp( varargin{i}, 'n_contour_lines')
            nContourLines = varargin{i+1};
        elseif strcmp( varargin{i}, 'sig_thresh_mult_of_std')
            sigThreshMultStd = varargin{i+1};
        end
    end
end

xres = xyRes(1);
yres = xyRes(2);



zThresh = wfsCtr; %[ch x samples]

I = nan(1,size(wfsCtr,1));

for i=1:size(wfsCtr,1) % note, must invert for findpeaks()
    
    stdSig= abs(std(wfsCtr(i,1:10)));
    
    [pks,currLoc] = findpeaks( ...
        -wfsCtr(i,:) ,'minpeakheight',stdSig*sigThreshMultStd,'npeaks',1);
    if ~isempty(currLoc)
        I(i) = currLoc;
    end
end



z = double((I-min(I))*1/(Fs/1e3));


plot.plotc(x,y,z,'s');

end