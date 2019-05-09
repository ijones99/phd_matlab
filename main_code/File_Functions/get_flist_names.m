function flist = get_flist_names( varargin)
% make_flist_select(flistName, varargin)
% ARGUMENTS:
%   flistName = name of output file [string] 
% VARARGS:
%   'no_proc': do not add ../proc string
%
% ian.jones@bsse.ethz.ch 2012.01.16

% init vars
addProcDir = 1;
selByIndNum = 1;
extraDir = '';
sortByDateAscend = 1;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'no_proc')
            addProcDir = 0;  
        elseif strcmp( varargin{i}, 'add_dir')
            extraDir = varargin{i+1};
        end
    end
end

% check extraDir name for slash
if ~isempty(extraDir)
    if extraDir(end) ~= '/'
        extraDir(end+1) = '/';
    end
end
% get file names
ntkFileNames = dir(sprintf('../proc/%s*.ntk', extraDir));
ntkFileNames = sortStruct(ntkFileNames,'datenum',1);

% list all files
for i=1:length(ntkFileNames)
   fprintf('(%d) %s\n', i, ntkFileNames(i).name);   
end

fprintf('\n');


ntkFileNumStr = input('Please enter in file number: ','s');
eval(sprintf('ntkFileNum = %s', ntkFileNumStr));


if iscell(ntkFileNum)
    idChars = ntkFileNum;
    selByIndNum = 0;

end


% write ntk names
if addProcDir
    textToWriteToFlist = 'flist{end+1} = ''../proc/%s%s'';\n';
else
    textToWriteToFlist = 'flist{end+1} = ''%s%s'';\n';
end

flist = {};

if ~iscell(ntkFileNum)
    for i =1:length(ntkFileNum)
        eval(sprintf(textToWriteToFlist,...
            extraDir, ntkFileNames(ntkFileNum(i)).name ));
        
    end
else
    for i=1:length(idChars)
        fileName = dir(strcat('../proc/*', idChars{i}, '*.ntk'));
        
        eval(sprintf(textToWriteToFlist,...
            extraDir, fileName(1).name ));
        
    end  
    
end



end