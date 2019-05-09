function flistCell  = make_flist_cell(ntkFileNum,  varargin)

% make_flist(ntkFileNum, flistName, varargin)
% ARGUMENTS:
%   ntkFileNum = range of file numbers to print [ints] 
%   flistName = name of output file [string] 
% VARARGS:
%   'no_proc': do not add ../proc string
%
% ian.jones@bsse.ethz.ch 2012.01.16


% init vars
addProcDir = 1;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'no_proc')
            addProcDir = 0;
        end
    end
end


% get file names
ntkFileNames = dir('../proc/*.ntk');

% open file to write
% fid=fopen(flistName, 'w'); 

% print to command line
% fprintf('Opening: %s\n', flistName);

% % find file name indices
% fileNameInd = [];
% 
% for iNtkFileNum = 1:length(ntkFileNum)
%     for iNtkFileNames = 1:length(ntkFileNames)
%         currFileName = ntkFileNames(iNtkFileNames ).name;
%         underScoreLoc = strfind(currFileName,'_');underScoreLoc  =underScoreLoc(end);
%         scannedFileNum = str2num(strrep(currFileName(underScoreLoc+1:end),'.stream.ntk',''));
%         if scannedFileNum==ntkFileNum(iNtkFileNum);
%             fileNameInd(end+1) = iNtkFileNames;
%         end
%     end
% end

flistCell = {};

% write ntk names
if addProcDir
    for i =1:length(ntkFileNum)
        flistCell{end+1} = strcat('../proc/', ntkFileNames(ntkFileNum(i)).name );
    end
else
    for i =1:length(ntkFileNum)
        flistCell{end+1} = ntkFileNames(ntkFileNum(i)).name ;
    end
end



end