function make_flist(ntkFileNum, flistName, varargin)
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

if isstr(ntkFileNum)
   if strcmp(ntkFileNum,'all')
       clear ntkFileNum; ntkFileNum = 1:length(ntkFileNames);
   end
else
    fprintf('Error in make_flist.\n');
    
end

% open file to write
fid=fopen(flistName, 'w'); 

% print to command line
fprintf('Opening: %s\n', flistName);

% write ntk names
if addProcDir
    for i =1:length(ntkFileNum)
        fprintf(fid,'flist{end+1} = ''../proc/%s'';\n',...
            ntkFileNames(ntkFileNum(i)).name );
        fprintf('Writing: flist{end+1} = ''../proc/%s'';\n',...
            ntkFileNames(ntkFileNum(i)).name );
        if i==length(ntkFileNum)
            fprintf('\n');
        end
        
    end
    

else
    for i =1:length(ntkFileNum)
        fprintf(fid,'flist{end+1} = ''%s'';\n',...
            ntkFileNames(ntkFileNum(i)).name );
        fprintf('Writing: flist{end+1} = ''%s'';\n',...
            ntkFileNames(ntkFileNum(i)).name );
        if i==length(ntkFileNum)
            fprintf('\n');
        end
        
        
    end
end

fileDetails = ls('../proc/*ntk','-hHl');
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