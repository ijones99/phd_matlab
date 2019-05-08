function R=load_R_data(varargin)
% R=load_R_data()
%
% varargin
%   col_no
%   r_idx
%

colNo = [];
Ridx = [];
specDir = '';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'col_no')
            colNo = varargin{i+1};
        elseif strcmp( varargin{i}, 'r_idx')
            Ridx = varargin{i+1};
        elseif strcmp( varargin{i}, 'dir')
            specDir = varargin{i+1};
        end
    end
end

expName = get_dir_date;

if ~isempty(specDir)
   if specDir(1) ~= '/'
       specDir(2:end+1) = specDir;
       specDir = '/';
   end
end

load(sprintf(...
    '/net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut%s/%s_resultsForIan',...
    specDir, expName));

fprintf(...
    'loaded /net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut%s/%s_resultsForIan\n',...
    specDir, expName);


if ~isempty(colNo)
    R = R{:,colNo};
end

if ~isempty(Ridx)
     R = R{Ridx,:};
end


end