% script_testing_hd_sorter

% convert file to h5
%    module load HiDens/experimental
%    ntk2hdf    filename.stream.ntk
 

% go into folder 
cd ~/bel.svn/hima_internal/cmosmea/trunk/matlab/
setup

% Then get a not too big H5 file for the first test. For me that looks like that
tmp_path = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/testData/proc/';

%% Run the HD sorter
fname = 'Trace_id843_2012-02-27T16_07_02_3.stream.h5';
ffile = fullfile(tmp_path, fname);
 
% Then start the gui:
f = hdsort('UserData', ffile);

%% Working with the Resulting Data

% plot the templates
plot(GUI.T.getTemplateWf(1:88)')

% steps to get timestamps
load hdmeagui
GUI.T.getTemplateWf
GUI.T.getTemplateIds
edit mysort.wf.TemplateManager
GUI.T.getTemplateWf
GUI.T.getTemplateWf(1:88)
size(GUI.T.getTemplateWf(1:88))
plot(GUI.T.getTemplateWf(1:88)')
plot(GUI.T.getTemplateWf(1:88)')
i=GUI.T.getIterator
while i.hasNext
t= i.next;st{t.idx} = t.getSpikeTrain;
end
i=GUI.T.getIterator
while i.hasNext
t= i.next;st{t.idx} = t.getIdx;
end
i=GUI.T.getIterator
while i.hasNext
t= i.next;st{i.idx} = t.getIdx;
end
ev
ev = GUI.WF.eventTimes
size(ev)
for i=1:88
stt{i}=ev(st{i});
end
size(stt)
stt(1)
stt{1}
stt