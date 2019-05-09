function [flist stimName ] = make_flist_select( flistName, varargin)
% [flist stimName ]= make_flist_select(flistName, varargin)
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
promptStr = '';
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'no_proc')
            addProcDir = 0;  
        elseif strcmp( varargin{i}, 'add_dir')
            extraDir = varargin{i+1};
        elseif strcmp( varargin{i}, 'prompt_string')
            promptStr = varargin{i+1};
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
if ~isempty(promptStr)
    [fileIdx ntkFileNames ] = filenames.select_flist_name('selection_type', ...
        'file_name_part','prompt_string',promptStr);
else
    [fileIdx ntkFileNames ] = filenames.select_flist_name('selection_type', ...
        'file_name_part');
end
% ntkFileNumStr = num2str(fileIdx);
% eval(sprintf('ntkFileNum = %s', ntkFileNumStr));
ntkFileNum = fileIdx;
if iscell(ntkFileNum)
    idChars = ntkFileNum;
    selByIndNum = 0;

end

if isstr(ntkFileNum)
   if strcmp(ntkFileNum,'all')
       clear ntkFileNum; ntkFileNum = 1:length(ntkFileNames);ntkFileNames
   end
else
%     fprintf('Error in make_flist. Did you put the ntk file in the correct directory?\n');
    
end

% open file to write
fid=fopen(flistName, 'w'); 

% print to command line
fprintf('Opening: %s\n', flistName);

% write ntk names
if addProcDir
    textToWriteToFlist = 'flist{end+1} = ''../proc/%s%s'';\n';
else
    textToWriteToFlist = 'flist{end+1} = ''%s%s'';\n';
end
flist = {};
if ~iscell(ntkFileNum)
    for i =1:length(ntkFileNum)
        fprintf(fid,textToWriteToFlist,...
            extraDir, ntkFileNames(ntkFileNum(i)).name );
        eval(sprintf(strcat(textToWriteToFlist),...
            extraDir, ntkFileNames(ntkFileNum(i)).name ));
        fprintf(strcat('Writing: ' , textToWriteToFlist),...
            extraDir, ntkFileNames(ntkFileNum(i)).name );
        if i==length(ntkFileNum)
            fprintf('\n');
        end
        
    end
else
    for i=1:length(idChars)
        fileName = dir(strcat('../proc/*', idChars{i}, '*.ntk'));
        
        fprintf(fid,textToWriteToFlist,...
            extraDir, fileName(1).name );
        fprintf(strcat('Writing: ' , textToWriteToFlist),...
            extraDir, fileName(1).name  );
               
        
    end  
    
end


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

stimName = strrep(flistName,'flist_','');
stimName = strrep(stimName,'.m','');
end