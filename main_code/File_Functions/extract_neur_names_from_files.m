function neurNames = extract_neur_names_from_files(  dirName, filePattern , varargin)
% FUNCTION NEURNAMES = EXTRACT_NEUR_NAMES_FROM_FILES(  DIRNAME, FILEPATTERN , VARARGIN)
% author: ijones

selInds = [];
suffixString ='';
strToRemove = '';
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp(varargin{i},'flist')
            flist = varargin{i+1};
            idNameStartLocation = strfind(flist{1},'T');idNameStartLocation(1)=[];
            flistFileNameID = flist{1}(idNameStartLocation:end-11);
        elseif strcmp(varargin{i},'suffix')
            suffixString = varargin{i+1};
  
        elseif strcmp(varargin{i},'data_dir')
            dataDir = varargin{i+1};
        elseif strcmp(varargin{i},'sel_inds')
            selInds = varargin{i+1};
        elseif strcmp(varargin{i},'remove_string')
            strToRemove = varargin{i+1};
        end
    end
end

% if length(flist)==1
%    flist{1} = flist; 
% end

% idNameStartLocation = strfind(flist{1},'T');idNameStartLocation(1)=[];
% flistFileNameID = strcat(flist{1}(idNameStartLocation:end-11),suffixString);

% get processed file names
elFileNames = dir(fullfile(dirName,filePattern));

% extract names of neurons

neurNames = {}; % init value

% get file prefix
filePrefix = filePattern;
if filePrefix(end)=='*';
    filePrefix = filePrefix(1:end-1);
end
if  ~isempty(selInds)
    % get all the neuron names
    for i=1: length(selInds)
        neurNames{i} = strrep(strrep(elFileNames(selInds(i)).name,filePrefix,''),'.mat','');
        nLoc = strfind(neurNames{i},'n');
        neurNames{i} = neurNames{i}(nLoc-4:end);
        if ~isempty(strToRemove)
            neurNames{i} = strrep(neurNames{i},strToRemove,'');
        end
        % remove suffix
        periodLoc = strfind(neurNames{i},'.');
        if ~isempty(periodLoc )
            neurNames{i} = neurNames{i}(1:periodLoc-1);
        end
        
    end
else
    for i=1: length(elFileNames)
        neurNames{i} = strrep(strrep(elFileNames(i).name,filePrefix,''),'.mat','');
        if ~isempty(strToRemove)
            neurNames{i} = strrep(neurNames{i},strToRemove,'');
        end
        nLoc = strfind(neurNames{i},'n');
        neurNames{i} = neurNames{i}(nLoc-4:end);

        % remove suffix
        periodLoc = strfind(neurNames{i},'.');
        if ~isempty(periodLoc )
            neurNames{i} = neurNames{i}(1:periodLoc-1);
        end
    end
end

end