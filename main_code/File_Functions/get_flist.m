function flist = get_flist( flistName, varargin)
% make_flist(ntkFileNum, flistName, varargin)
% ARGUMENTS:
%   ntkFileNum = range of file numbers to print [ints] or strings in cells
%   {'34_2_5'; '35_3_5'}
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
flist = {};
for i=1:length(ntkFileNames)
   fprintf('(%d) %s\n', i, ntkFileNames(i).name);   
   flist{i} = ntkFileNames(i).name;
end

% open file to write
fid=fopen(flistName, 'w'); 

% print to command line
fprintf('Opening: %s\n', flistName);

% list all files to write as comment at end of file
fileDetails = ls(sprintf('../proc/%s*ntk',extraDir),'-rltH');
phraseLocAll = strfind(fileDetails,'bsse-hierlemann');

while ~isempty( strfind(fileDetails,'bsse-hierlemann'))
    phraseLoc = strfind(fileDetails,'bsse-hierlemann'); phraseLoc = phraseLoc(1);
    strDel = fileDetails(phraseLoc-20:phraseLoc+15);
    fileDetails = strrep(fileDetails,strDel,'% ');
end

newLineLoc = strfind(fileDetails,'% ');
for i=1:length(newLineLoc)
    newLineLoc = strfind(fileDetails,'% ');
    fileDetails = strcat(fileDetails(1:newLineLoc(i)),' (',num2str(i),')',...
        fileDetails(newLineLoc(i)+1:end));


end

fprintf(fid,'\n%s\n',fileDetails);



% close file
fclose(fid);



end