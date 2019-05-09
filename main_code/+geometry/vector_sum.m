function sumOut = vector_sum(angleIn, lengthsIn,varargin) 
% sumOut = VECTOR_SUM(angleIn, lengthsIn) 

doNorm=0;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'normalize')
            doNorm=1;
        elseif strcmp( varargin{i}, 'file_name')
            name2 = varargin{i+1};
        end
    end
end

if doNorm
    angleIn = angleIn/max(angleIn);
end

xy = geometry.angle2xy(angleIn, lengthsIn);


sumOut = sum(xy,1);



end
