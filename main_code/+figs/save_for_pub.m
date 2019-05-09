function save_for_pub(fileName, varargin)
% function SAVE_FOR_PUB(fileName)
%
% figs.save_for_pub('~/Desktop/matilda3', 'file_type', 'eps', 'dpi', 900)
%
% fileName: can be cell or full filename with path & file
%
%
%   Built-in MATLAB Drivers:
%         -dps       % PostScript for black and white printers
%         -dpsc      % PostScript for color printers
%         -dps2      % Level 2 PostScript for black and white printers
%         -dpsc2     % Level 2 PostScript for color printers
%  
%         -deps      % Encapsulated PostScript
%         -depsc     % Encapsulated Color PostScript
%         -deps2     % Encapsulated Level 2 PostScript
%         -depsc2    % Encapsulated Level 2 Color PostScript
%  
%         -dhpgl     % HPGL compatible with Hewlett-Packard 7475A plotter
%         -dill      % Adobe Illustrator 88 compatible illustration file
%         -djpeg<nn> % JPEG image, quality level of nn (figures only)
%                      E.g., -djpeg90 gives a quality level of 90.
%                      Quality level defaults to 75 if nn is omitted.
%         -dtiff     % TIFF with packbits (lossless run-length encoding)
%                      compression (figures only)
%         -dtiffnocompression % TIFF without compression (figures only)
%         -dpng      % Portable Network Graphic 24-bit truecolor image
%                      (figures only)

fileType = 'depsc';
resolution = 900;

fileNameSave = [];
if iscell(fileName)
    fileNameSave = fullfile(fileName{:});
else
    fileNameSave = fileName;
end

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'file_type')
            fileType = varargin{i+1};
        elseif strcmp( varargin{i}, 'dpi')
            resolution = varargin{i+1};

        end
    end
end


if strcmp(fileType, 'depsc')
    eval(sprintf('print -%s -tiff -r%d %s',fileType, resolution, fileNameSave ));
else
    eval(sprintf('print -%s -r%d %s',fileType, resolution, fileNameSave ));
end


end