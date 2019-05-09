function [ntk2 activity_map] = load_and_cut_events_for_activity_map(flist,varargin)
% function [ntk2 activity_map] = load_and_cut_events_for_activity_map(flist)

chunkSize = 2e4*60*4;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'load_time_sec')
            chunkSize = 2e4*varargin{i+1};
        end
    end
end


flistNo = 1;

ntk=initialize_ntkstruct(flist{flistNo},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1', 'digibits');
thr_f=4;
pretime=16;
posttime=16;
allevents=simple_event_cut(ntk2, thr_f, pretime, posttime);
activity_map=convert_events(allevents,ntk2)