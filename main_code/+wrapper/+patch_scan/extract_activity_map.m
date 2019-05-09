function activity_map = extract_activity_map(flist,varargin)
% activity_map = EXTRACT_ACTIVITY_MAP(flist,varargin)
%
% var
%   'load_sample_size'

chunkSize = 2e4*60*5;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'load_sample_size')
            chunkSize = varargin{i+1};

        end
    end
end



if iscell(flist)
    flist = flist{1};
end

flistNo = 1;

ntk=initialize_ntkstruct(flist,'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1', 'digibits');
thr_f=4;
pretime=16;
posttime=16;
allevents=simple_event_cut(ntk2, thr_f, pretime, posttime);
activity_map=convert_events(allevents,ntk2)

end