function ntkData = get_fields_from_ntk_file(flist, fieldNames, varargin)
% GET_FIELDS_FROM_NTK_FILE  Obtain selected fields from ntk file
%   function ntkData = get_fields_from_ntk_file(flist, fieldNames, varargin)
%
% varargin
%   num_samples
%   ch_no
%   get_all_fields
%
%
numSamplesLoad = 2e4*150;
chNo = 1;
doGetAllFields = 0;

if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'num_samples')
            numSamplesLoad = varargin{i+1};
        elseif strcmp( varargin{i}, 'ch_no')
            chNo = varargin{i+1};
        elseif strcmp( varargin{i}, 'get_all_fields')
            doGetAllFields = 1;
            
        
        end
    end
end

% make sure flist is not cell
if iscell(flist)
    flist = flist{1};
end

% fieldNames should be a cell
if ~iscell(fieldNames)
    fieldNames = {fieldNames};
end

ntk=initialize_ntkstruct(flist,'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, 1, 'images_v1', 'digibits');
chNo = ntk2.channel_nr(1);

ntk=initialize_ntkstruct(flist,'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, numSamplesLoad, 'images_v1', 'digibits','keep_only', chNo);

if doGetAllFields 
   ntkData = ntk2; 
else
    for i=1:length(fieldNames)
        
        eval(sprintf('ntkData.%s = ntk2.%s', fieldNames{i}, fieldNames{i}));
    end
end
end