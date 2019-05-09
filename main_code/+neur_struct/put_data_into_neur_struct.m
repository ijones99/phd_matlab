function neur = put_data_into_neur_struct(wn_checkerbrd, spt, mb, runNo, expName)

% constants
acqRate = 2e4;

% init
neur= {};
neur.info = {};

% info
neur.info.exp_name = expName;
neur.info.run_no =runNo;
neur.info.ums_clus_name =strrep(wn_checkerbrd.tsMatrix{1}.name,'st_','');
neur.info.rfRelCtr = spt.rfRelCtr;

% wn_checkerbrd
neur.wn_checkerbrd.st = wn_checkerbrd.tsMatrix{1}.ts*acqRate ;
neur.wn_checkerbrd.frameno = wn_checkerbrd.frameno;

% mb
neur.mb.st = mb.tsMatrix{1}.ts*acqRate ;
neur.mb.frameno = mb.frameno;


% spt
neur.spt.st = spt.tsMatrix{1}.ts*acqRate ;
neur.spt.frameno = spt.frameno;


end