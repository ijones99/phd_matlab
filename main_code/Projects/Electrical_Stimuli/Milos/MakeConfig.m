function out = MakeConfig(varargin)
% Milos Radivojevic 2013
%
%      MakeConfig(varargin)
%
%      'no_plot'         -    doesn't plot configuration
%      'config_path'     -    directory path
%      'config_name'     -    configuration title
%      'stim_elcs'       -    stimulation electriode(s)
%      'rec_elcs'        -    recording electriode(s)




PLOT = 1;

i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        if strcmp(varargin{i}, 'no_plot')
            PLOT=0;
        elseif strcmp(varargin{i}, 'config_path')
            i=i+1;
            config_path=varargin{i};
        elseif strcmp(varargin{i}, 'config_name')
            i=i+1;
            config_name=varargin{i};
        elseif strcmp(varargin{i}, 'stim_elcs')
            i=i+1;
            elc_to_stimulate=varargin{i};
        elseif strcmp(varargin{i}, 'rec_elcs')
            i=i+1;
            elc_with_neuron=varargin{i};
        else
            fprintf('unknown argument at pos %d\n', 1+i);
        end
    end
    i=i+1;
end

% make neuropos file
dir_configs = config_path;
Info.Exptitle = config_name;
neurons=elc_with_neuron;
rp=randperm(length(neurons));
maximumElNumber = min(126, length(neurons) );
elc_with_neuron=neurons(rp(1:maximumElNumber));
neuroposfile=[dir_configs Info.Exptitle '.neuropos.nrk'];
mkdir(dir_configs)
fid = fopen(neuroposfile, 'wt');

% normal electrodes without stimulation request
for i=1:length(elc_with_neuron)
    e=elc_with_neuron(i);
    [x y]=el2position(e);
    x = round(x);
    y = round(y);
    fprintf(fid, 'Neuron matlab%i: %i/%i, 10/10\n',i,x,y);
end

% stimulation electrodes
for i=1:length(elc_to_stimulate)
    e=elc_to_stimulate(i);
    [x y]=el2position(e);
    x = round(x);
    y = round(y);
    fprintf(fid, 'Neuron matlab%i: %i/%i, 10/10, stim\n',i,x,y);
end
fclose(fid);

% execute NeuroDishRouter
ndr_exe='`which NeuroDishRouter`';
[pathstr, name, ext] = fileparts(neuroposfile);
[tmp, name]          = fileparts(name);
neurs_to_take     = elc_with_neuron;

cmd=sprintf('%s -n -v 2 -l %s -s %s\n', ndr_exe, neuroposfile, [pathstr '/' name]);
system(cmd);

% reload & visualize configuration


[elidx amps] =nr.hidens_read_el2fi_nrk_file(pathstr,name)
routed_stim_els=multifind(elidx,elc_to_stimulate);
routed_neuron_els=multifind(elidx,elc_with_neuron);


[mposx mposy]=el2position([0:11015]);
if PLOT
    figure; % plot selected vs routed
    box on,    hold on;
    axis ij,   axis equal
    
    plot(mposx,mposy,'.','color',[1 1 1]*.8)
    plot(mposx(neurs_to_take+1),mposy(neurs_to_take+1),'sk')
    plot(mposx(elidx+1), mposy(elidx+1), 'rx');
else
end

chs_stim=amps(routed_stim_els);
chs_neur=amps(routed_neuron_els);

out.chs_stim=chs_stim;
out.chs_neur=chs_neur;
out.els_stim=elidx(routed_stim_els);
out.els_neur=elidx(routed_neuron_els);
out.config_name=[pathstr '/' name];

