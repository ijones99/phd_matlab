function table(tableData, varargin)
% TABLE(tableData)
%
% Function: create table in plot
%
% varargin
%   'hide_nans'
%
%
%
txtAdjPos = -0.75;
hideNans = 0;
decPlaces = '2.1';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'hide_nans')
            hideNans = 1;
        elseif strcmp( varargin{i}, 'dec_places')
            decPlaces = varargin{i+1};
        end
    end
end


rowDim = size(tableData,1);
colDim = size(tableData,2);

xlim([0 colDim]);
ylim([0 rowDim]);

lineSpecsX = repmat(0:colDim,2,1);
lineSpecsY = repmat([0 rowDim]',1,colDim+1);

line(lineSpecsY, lineSpecsX,'Color','k'), hold on
line(lineSpecsX, lineSpecsY,'Color','k'), hold on


for i=1:size(tableData,1)
    for j=1:size(tableData,2)
        if hideNans == 1 % do hide nans
            if ~isnan(tableData(i,j)) % only print if not nan
                eval(['currNumStr = sprintf(''%',decPlaces,'f'',tableData(i,j))']);
                text(i+txtAdjPos,j+txtAdjPos,currNumStr);
            end
        else
            eval(['currNumStr = sprintf(''%',decPlaces,'f'',tableData(i,j))']);
            text(i+txtAdjPos,j+txtAdjPos,currNumStr);
        end
    end
end

figs.ticksoff('x','y');

end