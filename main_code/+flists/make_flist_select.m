function [flist flistName ]= make_flist_select( stimName, runNo, varargin)
%  [flist flistName ] = make_flist_select(flistName, runNo, varargin)
% ARGUMENTS:
%   flistName = name of output file [string] 
% VARARGS:
%   'no_proc': do not add ../proc string
%   'no_run_no'
%   'no_flist_id'
%
% ian.jones@bsse.ethz.ch 2012.01.16

% init vars
addProcDir = 1;
selByIndNum = 1;
extraDir = '';
sortByDateAscend = 1;
doAddFlistId = 1;
doAddRunNo =1;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'no_proc')
            addProcDir = 0;  
        elseif strcmp( varargin{i}, 'add_dir')
            extraDir = varargin{i+1};
        elseif strcmp( varargin{i}, 'no_flist_id')
            doAddFlistId = 0;
        elseif strcmp( varargin{i}, 'no_run_no')
            doAddRunNo = 0;
        
        end
    end
end

% remove any trailing underscores
if stimName(end) == '_';
    stimName(end)='';
end
if stimName(1) == '_';
    stimName(1)='';
end
prefixLoc = strfind(stimName, 'flist_');
if ~isempty(prefixLoc)
    if prefixLoc(1)==1
        stimName=stimName(7:end);
    end
end

% check extraDir name for slash
if ~isempty(extraDir)
    if extraDir(end) ~= '/'
        extraDir(end+1) = '/';
    end
end
% get file names
% ntkFileNames = dir(sprintf('../proc/%s*.ntk', extraDir));
% if isempty(ntkFileNames)
%    fprintf('No proc file found.\n');
%    return
% end
% ntkFileNames = sortStruct(ntkFileNames,'datenum',1);
% 
% % list all files
% for i=1:length(ntkFileNames)
%    fprintf('(%d) %s\n', i, ntkFileNames(i).name);   
% end
% 
% fprintf('\n');
% 
% ntkFileNumStr = input('Please enter in file number: ','s');
% eval(sprintf('ntkFileNum = %s', ntkFileNumStr));

 
[ntkFileNum ntkFileNames] = filenames.select_flist_name('prompt_string','flist (no repeat names)');

if iscell(ntkFileNum)
    idChars = ntkFileNum;
    selByIndNum = 0;

end

if isstr(ntkFileNum)
   if strcmp(ntkFileNum,'all')
       clear ntkFileNum; ntkFileNum = 1:length(ntkFileNames);
   end
else
%     fprintf('Error in make_flist. Did you put the ntk file in the correct directory?\n');
    
end
flistFileNameID = get_flist_file_id(ntkFileNames(ntkFileNum(1)).name);

% create flist name
flistName = sprintf('flist_%s', stimName);
if doAddRunNo 
    flistName = sprintf('%s_n_%02d',flistName , runNo);
end
if doAddFlistId
     flistName = sprintf('%s_%s',flistName , flistFileNameID);
end

flistName = strrep(flistName,'__','_');
% open file to write
fid=fopen([flistName,'.m'], 'w'); 

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
% fileDetails = ls(sprintf('../proc/%s*ntk',extraDir),'-rltH');
% phraseLocAll = strfind(fileDetails,'bsse-hierlemann');
% 
% while ~isempty( strfind(fileDetails,'bsse-hierlemann'))
%     phraseLoc = strfind(fileDetails,'bsse-hierlemann'); phraseLoc = phraseLoc(1);
%     strDel = fileDetails(phraseLoc-20:phraseLoc+15);
%     fileDetails = strrep(fileDetails,strDel,'% ');
% end
% 
% newLineLoc = strfind(fileDetails,'% ');
% for i=1:length(newLineLoc)
%     newLineLoc = strfind(fileDetails,'% ');
%     fileDetails = strcat(fileDetails(1:newLineLoc(i)),' (',num2str(i),')',...
%         fileDetails(newLineLoc(i)+1:end));
% 
% 
% end
% 
% fprintf(fid,'\n%s\n',fileDetails);

% close file
fclose(fid);



end