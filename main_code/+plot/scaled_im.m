function myImInterp = scaled_im(myIm, scaleVal, varargin)
% myImInterp = SCALED_IM(myIm, scaleVal, varargin)

yDirRev = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'y_axis_rev')
            yDirRev = 1;

        end
    end
end



myImInterp = double(interp2(myIm, scaleVal));

imagesc(myImInterp);

if yDirRev
    set(gca,'YDir','reverse');
end

end

