function get_inds_els_chs(flist,varargin)

doSave = 0;

if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp(varargin{i},'do_save' )
            doSave = varargin{i+1};
        end
    end  
end

% flist name
flistNameStart = strfind(flist{1},'T');
flistNameEnd = strfind(flist{1},'.stream.ntk')-1;

% core name
fileSaveName = flist{1}(flistNameStart(2): flistNameEnd(1))

% load data
siz_init=10;
ntk=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);

% number of frames to load
siz=10;

[ntk2 ntk]=ntk_load(ntk, siz_init, 'images_v1');


elConfigInfo.elsInPatch = ntk2.el_idx;
elConfigInfo.chsInPatch = ntk2.channel_nr;

if doSave
    save( strcat('elConfigInfo_', fileSaveName,'.mat'), 'elConfigInfo')
    fprintf(strcat(['Saved ','elConfigInfo_', fileSaveName,'.mat\n')]);
end
    
end