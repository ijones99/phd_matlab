function elNumbers= extract_el_numbers_from_files(  dirName, filePattern , flist, varargin)

selInds = [];
suffixString ='';

if iscell(flist)
   flist = flist{1}; 
end


if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp(varargin{i},'suffix')
            suffixString = varargin{i+1};
        elseif strcmp(varargin{i},'use_prespikesorting_dir')
            idNameStartLocation = strfind(flist,'T');idNameStartLocation(1)=[];
            flistFileNameID = flist(idNameStartLocation:end-11);
            idNameStartLocation = strfind(flist,'T');idNameStartLocation(1)=[];
            flistFileNameID = strcat(flist(idNameStartLocation:end-11),suffixString);
            dirName = sprintf('../analysed_data/%s/01_Pre_Spikesorting/', flistFileNameID)
            
        elseif strcmp(varargin{i},'sel_inds')
            selInds = varargin{i+1};
        end
    end
end


% get processed file names
elFileNames = dir(fullfile(dirName,filePattern));

% extract electrode numbers of processed electrodes
if isempty(selInds)
    elNumbers = zeros(1,length(elFileNames));
    for i=1: length(elFileNames)
        elNumbers(i)= str2num(elFileNames(i).name(4:7));
    end
else
    elNumbers = zeros(1,length(selInds));
    for i=1:length(selInds)
        elNumbers(i)= str2num(elFileNames(selInds(i)).name(4:7));
    end
    
end


end