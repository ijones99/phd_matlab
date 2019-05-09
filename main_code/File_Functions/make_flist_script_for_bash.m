function make_flist_script_for_bash(ntkFileNum, flistName, varargin)

% make_flist(ntkFileNum, flistName, varargin)
% ARGUMENTS:
%   ntkFileNum = range of file numbers to print [ints] 
%   flistName = name of output file [string] 
% VARARGS:
%   'no_proc': do not add ../proc string
%
% ian.jones@bsse.ethz.ch 2012.01.16


% init vars
addProcDir = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'proc')
            addProcDir = 1;
        end
    end
end


% get file names
ntkFileNames = dir('../proc/*.ntk');

% open file to write
fid=fopen(flistName, 'w'); 

% print to command line
fprintf('Opening: %s\n', flistName);

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
        fprintf(fid,'ntk2hdf --chunkSize 200 -d 1 -o /links/groups/hima/recordings/HiDens/SpikeSorting/Roska/%s/%s /net/bs-filesvr01/export/group/hierlemann/recordings/HiDens/Roska/13Dec2012_2/proc/%s 2> /links/groups/hima/recordings/HiDens/SpikeSorting/Roska/13Dec2012_2%sconversion.log\n', ...
        get_dir_date, strrep(ntkFileNames(ntkFileNum(i)).name,'ntk','h5'), ntkFileNames(ntkFileNum(i)).name , ntkFileNames(ntkFileNum(i)).name ) ;


        
    end
end
% close file
fclose(fid);



end