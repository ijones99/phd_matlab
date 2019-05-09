function fprintf(myCell, varargin)
% FPRINTF(myCell)
% varargin
%   'show_index'

doPrintIdx = 0;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'show_index')
            doPrintIdx = 1;
        end
    end
end

if doPrintIdx 
    for i=1:length(myCell)
        fprintf('%02.0f) %s\n',i, myCell{i})
    end 
else
    for i=1:length(myCell)
        fprintf('%s\n',myCell{i})
    end
end


end