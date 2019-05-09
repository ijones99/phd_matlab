function save_plot_to_file(saveToDir, fileName, fileType, varargin  )
% SAVE_PLOT_TO_FILE(saveToDir, fileName, fileType  )
% varargin
%   'fig_h': 'eps', 'tiff', 'fig', 'add_filename_datestr'
%   'title_name'
%   'font_size_all' [numeric] font size for everything
%   'sup_title': super-title


h = [];
titleName = [];
addDateStr = 0;
timeStamp = now;
setFontSizeAll = 0;
setFontNameAll = 'Courier';
xLabel = '';
yLabel = '';
supTitle = '';
forceFileOverwrite=1;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'fig_h')
            h = varargin{i+1};
        elseif strcmp( varargin{i}, 'title_name')
            titleName = varargin{i+1};
        elseif strcmp( varargin{i}, 'sup_title')
            supTitle  = varargin{i+1};
        elseif strcmp( varargin{i}, 'no_title')
            titleName = 'none';
        elseif strcmp( varargin{i}, 'add_filename_datestr')
            addDateStr = 1;
        elseif strcmp( varargin{i}, 'timestamp') %e.g. "now"
            timeStamp = varargin{i+1};
        elseif strcmp( varargin{i}, 'font_size_all') %e.g. "now"
            setFontSizeAll = varargin{i+1};
        elseif strcmp( varargin{i}, 'font_name_all') %e.g. "now"
            setFontNameAll = varargin{i+1};
        elseif strcmp( varargin{i}, 'x_label') %e.g. "now"
            xLabel = varargin{i+1};
        elseif strcmp( varargin{i}, 'y_label') %e.g. "now"
            yLabel = varargin{i+1};
        elseif strcmp( varargin{i}, 'force_overwrite') %e.g. "now"
            forceFileOverwrite = 1;
        end
    end
end

if sum(strfind(fileName,'/'))
    [saveToDir,fileName,EXT] = fileparts(fullfile(saveToDir, fileName)); 
end

if addDateStr
   fileName = [fileName datestr(timeStamp, '_yyyy-mm-dd_THH-MM-SS-FFF')] 
end

% bring figure to front
if isempty(h)
    h = gcf;
end
figure(h);
    
% make title
  
if ~isempty(titleName)
    title(titleName,'Interpreter', 'none')
end



if ~exist(saveToDir,'dir')
    eval(sprintf('!mkdir -p %s', saveToDir));
    warning(sprintf('Creating directory: %s', saveToDir));
end

% save file
if ~iscell(fileType) % convert to cell
    fileTypeNew{1}= fileType;
    clear fileType;
    fileType = fileTypeNew(1);
end

% set x and/or y label
if ~isempty(xLabel)
    xlabel(xLabel,'FontName', setFontNameAll);
end

if ~isempty(yLabel)
    ylabel(yLabel,'FontName', setFontNameAll);
end

% suptitle
if ~isempty(supTitle)
    supTitle = strrep(supTitle,'_','-');
    suptitle(supTitle);
end

% set font size for all
if setFontSizeAll
    figs.font_size(setFontSizeAll);
    figs.font_name(setFontNameAll);
end

fileExists = 0;
doWriteFile = 1;
for iFileType = 1:length(fileType)
    if exist(fullfile(saveToDir, [fileName,'.',fileType{iFileType} ]),'file')
       fileExists = 1;
    end
end

if fileExists & not(forceFileOverwrite )
    
    doWriteFileStr = input(sprintf('Do overwrite file %s [y/n]', [fileName ]),'s');
    if doWriteFileStr == 'y'
        doWriteFile = 1;
    else
        doWriteFile = 0;
    end
end
if doWriteFile
    for iFileType = 1:length(fileType)
        if strcmp( fileType{iFileType}, 'eps')
            eval(sprintf('print -depsc2 -tiff %s',...
                fullfile(saveToDir, fileName)))
        elseif strcmp( fileType{iFileType}, 'tiff')
            eval(sprintf('print -dtiff %s',...
                fullfile(saveToDir, fileName)))
        elseif strcmp( fileType{iFileType}, 'fig')
            saveas(h,fullfile(saveToDir, fileName),'fig')
        elseif strcmp( fileType{iFileType}, 'pdf')
            saveas(h,fullfile(saveToDir, fileName),'pdf')
        elseif strcmp( fileType{iFileType}, 'ps')
            saveas(h,fullfile(saveToDir, fileName),'ps')
        else
            error('File type not recognized.');
        end     
    end
end



end