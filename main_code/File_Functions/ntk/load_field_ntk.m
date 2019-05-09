function ntkOut = load_field_ntk(fileName, fieldNames, varargin)
% ntkOut = LOAD_FIELD_NTK(fileName, fieldNames, varargin)
% LOAD_FIELD_NTK can be used to load data fields from an ntk file.
% 
% varargin
%
%   'file_dir'
%   'file_name'
%   'ind_number'
%   'init_settings'
%   'quick_load'
%
% arguments:
%
%   fieldNames: [cell]
%                    eof
%                    pos
%                  fname
%                     sr
%                    osf
%                 chipid
%                 design
%                version
%                  light
%              timestamp
%                  gain1
%                  gain2
%                  gain3
%                    lp1
%                    lp2
%          recfile_param
%             chip_param
%                 images
%                filters
%                   gain
%                    lsb
%                  range
%                  x_all
%                  y_all
%             el_idx_all
%                   temp
%                     dc
%                   dac1
%                   dac2
%               digibits
%                    sig
%               frame_no
%             channel_nr
%                      x
%                      y
%                 el_idx
%             prehp_mean
%     at_rail_percentage
%
%
% Author: ijones

% ntkOut = struct([]);
chunkSize = 2e4*60;
chunkSizeQuick = 50;
indNumber = 0;
initSettings = '''hpf'', 500, ''lpf'', 3000';
doQuickLoad = 0;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'file_dir')
            fileDir = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_name')
            nrkFileName = varargin{i+1};
        elseif strcmp( varargin{i}, 'ind_number')
            indNumber = varargin{i+1};
        elseif strcmp( varargin{i}, 'init_settings')
            initSettings = varargin{i+1};
        elseif strcmp( varargin{i}, 'quick_load')
            doQuickLoad =1;
            if isnumeric(varargin{i+1})
                chunkSizeQuick = varargin{i+1};

            end
            
        else
      
        end
    end
end

if ~iscell(fieldNames)
    fieldNamesNew = {};
    fieldNamesNew{1} = fieldNames;
    clear fieldNames
    fieldNames = fieldNamesNew;
end

if ~sum(strfind(fileName, '.stream.ntk'))
    fileName = [fileName, '.stream.ntk'];
end


% init struct
if isempty(initSettings)
    ntk=initialize_ntkstruct(fileName);
else
    eval([sprintf('ntk=initialize_ntkstruct(fileName,%s);', initSettings)]);
end
% init output
for i=1:length(fieldNames)
    eval(['ntkOut.', fieldNames{i},'=[];']);
end


if ~doQuickLoad
    ntkEof = 0;
    % load data
    while ~ntkEof
        
        % load chunk
        
        if indNumber == 0
            [ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1');
        else
            [ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1', 'keep_only', indNumber);
        end
        
        % go through field names and add data
        for i=1:length(fieldNames)
            if ~strcmp(fieldNames{i},'images.frameno')
                workingData = getfield(ntk2, fieldNames{i});
                eval(['ntkOut.', fieldNames{i},'(end+1:end+size(workingData,1),:)=single(workingData);']);
            elseif strcmp(fieldNames{i},'images.frameno')
                eval('workingData=single(ntk2.images.frameno);');
                eval(['ntkOut.', fieldNames{i},'(end+1:end+length(workingData))=single(workingData);']);
            end
            progress_info(i,length(fieldNames) )
        end
        
        
        ntkEof = ntk2.eof;
    end
    
    % just load a bit of data
else
    if indNumber == 0
        [ntk2 ntk]=ntk_load(ntk, chunkSizeQuick, 'images_v1');
    else
        [ntk2 ntk]=ntk_load(ntk, chunkSizeQuick, 'images_v1', 'keep_only', indNumber);
    end
    
    % go through field names and add data
    for i=1:length(fieldNames)
        if ~strcmp(fieldNames{i},'images.frameno')
            workingData = getfield(ntk2, fieldNames{i});
            eval(['ntkOut.', fieldNames{i},'(end+1:end+length(workingData))=workingData;']);
        elseif strcmp(fieldNames{i},'images.frameno')
            eval('workingData=ntk2.images.frameno;');
            eval(['ntkOut.', fieldNames{i},'(end+1:end+length(workingData))=workingData;']);
        end
        progress_info(i,length(fieldNames) )
    end
end

% change to original format of ntk2

 for i=1:length(fieldNames)

eval(['ntkOut.', fieldNames{i}, '=ntkOut.', fieldNames{i},''';'])
end