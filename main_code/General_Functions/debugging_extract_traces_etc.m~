
%%
% get timestamps by threshholding
% [traceTimeStamps, eventTimeStamps] = geteventtimestamps(ntk2.sig(:,12),25,25,20000,4);
% manualTs = eventTimeStamps;

%% prepare ts for use
foundTimes = ceil(spikes.spiketimes(find(spikes.assigns==13))*20000);size(foundTimes)
maxLoc = find(foundTimes>length(ntk2.sig),1);
if ~isempty(maxLoc)
    foundTimes = foundTimes(1,1:maxLoc-1);
end
manualTs = ceil(foundTimes);

%%
load('/home/ijones/Matlab/Spikesorting/MatlabTesting/Basic_Analysis/blank_neuron.mat')
blank_neuron{1}.ts_fidx  = ones(size(manualTs))
blank_neuron{1}.ts = double(ntk2.frame_no(manualTs));
blank_neuron{1}.fname = ntk2.fname;
blank_neuron{1}.ts_pos = ones(size(blank_neuron{1}.ts));
% blank_neuron{1}.event_param=[];
% blank_neuron{1}.event_param.margin=[];
%% extract traces
y = hidens_extract_traces(blank_neuron)

%% plot neuron
figure
plot_neurons(y)
%% plot frameno's and spike timestamps
figure, plot(ntk2.frame_no,'b'), hold on, plot(ntk2.frame_no(ceil(manualTs)),'r' )

%% plot channel and spike times
figure
plot(ntk2.sig(:,12))
hold on
foundTimes = ceil(spikes.spiketimes*20000);
foundTimes = foundTimes(1:537);
plot(foundTimes,0*ones(size(ntk2.frame_no(foundTimes))),'r*')

