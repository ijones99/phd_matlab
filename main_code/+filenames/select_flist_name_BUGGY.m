function [fileIdx ntkFileNames] = select_flist_name(varargin)
% [fileIdx ntkFileNames]= SELECT_FLIST_NAME(varargin)
%
% Purpose: select file by numbers in file name.
%
fileIdx = [];
selectionType = 'file_name_part';
promptStr = '';
promptStringOnly= 0;
procDir = '../proc/';
flist = {};
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'selection_type')
            selectionType = varargin{i+1};
        elseif strcmp( varargin{i}, 'prompt_string')
                promptStr = varargin{i+1};
        elseif strcmp( varargin{i}, 'prompt_string_only')
            promptStr = varargin{i+1};
            promptStringOnly = 1;
        elseif strcmp( varargin{i}, 'proc_dir')
            procDir = varargin{i+1};
        elseif strcmp( varargin{i}, 'flist')
            flist = varargin{i+1};

        end
    end
end

if procDir(end) ~= '/';
    procDir(end+1) = '/';
end

% get file names
ntkFileNames = dir(sprintf('%s*.ntk',procDir));
if isempty(ntkFileNames)
   warning('No proc file found.\n');
   return
end
ntkFileNames = sortStruct(ntkFileNames,'datenum',1);

% list all files
for i=1:length(ntkFileNames)
   fprintf('(%d) %s\n', i, ntkFileNames(i).name);   
end

fprintf('\n');
% selection
if strcmp(selectionType ,'natural_order')
    ntkFileNumStr = input('Please enter in file number: ','s');
elseif strcmp(selectionType ,'file_name_part')
    exitLoop = 0;
    while exitLoop == 0
        if isempty(promptStr)
            searchNums = input('Please enter file number [last nums of file]: ');
            if isrow(searchNums)
                searchNums = searchNums';
            end
        elseif promptStringOnly == 0
            searchNums = input(sprintf('Please enter file number for %s [last nums of file]: ',promptStr));
            if isrow(searchNums)
                searchNums = searchNums';
            end
        elseif promptStringOnly == 1
            searchNums = input(sprintf('%s [last nums of file]: ',promptStr));
            if isrow(searchNums)
                searchNums = searchNums';
            end
        end
        for iSel = 1:size(searchNums,1)
            if size(searchNums(iSel,:)) > 1
                strArg = sprintf('_%d_%d.stream.ntk',searchNums(iSel,1), searchNums(iSel,2));
            else
                strArg = sprintf('_%d.stream.ntk',searchNums(iSel,1));
            end
            if isempty(flist)
                [currFileIdx strLocAtIdx] = filenames.find_str_in_filenames_cell(strArg, ntkFileNames);
            else
                [currFileIdx strLocAtIdx] = flists.find_str_in_flist_cell(strArg, flist);
            end
            if length(currFileIdx)>1
                for mm=1:length(currFileIdx)
                   fprintf('(%d) %s\n', mm,ntkFileNames(currFileIdx(mm)).name); 
                end
                hitIdx = input(sprintf('more than one result found, enter hit idx to select (file pos=%d; num=%d) >> '...
                    ,iSel,searchNums(iSel,1) ));
                fileIdx(iSel) = currFileIdx(hitIdx);
                exitLoop = 1;
            else
                fileIdx(iSel) = currFileIdx;
                if isempty(flist)
                    fprintf('%s\n',ntkFileNames(fileIdx(iSel)).name);
                else
                    fprintf('%s\n',flist{fileIdx(iSel)});
                end
                exitLoop = 1;
            end
        end
    end
end


end