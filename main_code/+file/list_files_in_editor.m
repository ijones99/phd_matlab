function filenames = list_files_in_editor(varargin)
% filenames = LIST_FILES_IN_EDITOR(varargin)

nameOnly = 0;
printResult = 1;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'name_only')
            nameOnly = 1;
        elseif strcmp( varargin{i}, 'suppress_print')
             printResult = 0;
        end
    end
end


f=matlab.desktop.editor.getAll;

if nameOnly
    filenames=cellfun(@(s)s(find(s==filesep,1,'last')+1:end-2),{f.Filename},'uniformoutput',false);
else
    filenames=cellfun(@(s)s(1:end-2),{f.Filename},'uniformoutput',false);
end


if printResult
   cells.print( filenames);
end

end