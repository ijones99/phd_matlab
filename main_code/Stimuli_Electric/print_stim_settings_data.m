function flist = print_stim_settings_data(settings, varargin)
% flist = PRINT_STIM_SETTINGS_DATA(out.configs_stim_volt)

flist = {};
suppressPrint = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'file_dir')
            name1 = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_name')
            name2 = varargin{i+1};
        elseif strcmp( varargin{i}, 'suppress_print')
            suppressPrint = 1;
            suppressPrintInd = i;
            
        end
    end
end

% this is because varargin is used to suppress printing as well as for the
% fields that the user wishes to extract. Therefore, the suppress printing
% argument must be removed.
if exist('suppressPrintInd','var')
    vararginInds = 1:length(varargin);
    vararginInds(suppressPrintInd) = [];
    varargin = varargin(vararginInds);
end

fieldNames = {'saveRecording', ...
    'recNTKDir', ...
    'slotNum', ...
    'delayInterSpikeMsec', ...
    'delayInterAmpMsec', ...
    'hostIP'...
    };

% header info (not cells)
if ~suppressPrint
    for i=1:length(fieldNames)
        fieldData = getfield(settings, fieldNames{i});
        % if not cell, then is header
        if ischar(fieldData)
            fprintf('%s:\t %s\n', fieldNames{i}, fieldData)
        else
            fprintf('%s:\t %d\n', fieldNames{i}, fieldData)
        end
    end
end

% other data
if ~isempty(varargin)
    for iFile = 1:length(settings.stimType) % go through files
        if ~suppressPrint
            fprintf('fileno-%d:|',iFile); % print file number
        end
        for iFields=1:length(varargin) % get requested data
            fieldData = getfield(settings, varargin{iFields});
            if strcmp(varargin{iFields},'flist')
                flist{end+1} =  fieldData{iFile};
            end
            
            if ~suppressPrint
                fprintf('|%s: |', varargin{iFields});
                
                if ~ischar(fieldData{iFile})
                    for iData = 1:length(fieldData{iFile})
                        fprintf('%6.0f|', fieldData{iFile}(iData));
                    end
                else
                    fprintf('%s|', fieldData{iFile});
                    
                end
            end
        end
        if ~suppressPrint
            fprintf('\n');
        end
    end
end

end

