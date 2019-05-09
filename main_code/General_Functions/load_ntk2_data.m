function ntk2 = load_ntk2_data(flist, chunkSize, varargin)
% ntk2 = load_ntk2_data(flist, chunkSize)

loadSpecChans = [];

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'keep_only')
            loadSpecChans = varargin{i+1};

        end
    end
end



if iscell(flist)
    flistNew = flist{1};
    if length(flist)>1
        warning('using only first flist file.\n');
    end
elseif ischar(flist)
    flistNew = flist;
else
    warning('error.\n');
end

if iscell(flistNew)
    flistNewNew = flistNew{1};
    clear flistNew;
    flistNew = flistNewNew;
end
    


ntk=initialize_ntkstruct(flistNew,'hpf', 500, 'lpf', 3000);
if isempty(loadSpecChans)
    [ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1', 'digibits');
else
     [ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1', 'digibits','keep_only',loadSpecChans);
end

end
