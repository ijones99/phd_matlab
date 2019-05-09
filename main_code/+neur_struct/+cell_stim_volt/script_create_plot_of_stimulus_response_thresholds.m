%% 
outRegionalFileName = 'neur_regional_scan_08.mat';
outRegional = load(outRegionalFileName); outRegional= outRegional.out;

[out] = neur_struct.cell_stim_volt.compute_volt_stimulus_response(outRegional, out, ...
    'set_stim_and_readout',1)

%%
localListChs = out.channel_nr{1};
stimChs = out.configs_stim_volt.stimCh;

[localInds B] =multifind(localListChs,cell2mat( stimChs),'J');
z = out.analysis_stim_volt.ic50;
x = out.x(localInds);
y = out.y(localInds);
text(x,y,num2str(z'),'FontSize',15)

%% plot by size
% figure, hold on
%scale data
% plot the footprint from the regional scan
h = figure, hold on



plot_footprints_simple([outRegional.footprint.mposx outRegional.footprint.mposy], ...
    outRegional.footprint.wfs, ...
    'input_templates','hide_els_plot',...
    'plot_color','b', 'flip_templates_ud','scale', 20);

%% plot the peak-to-peak amplitude of the waveforms
h=figure, hold on, neur_struct.regional_scan.plot.plot_peak2peak_amplitudes(outRegional)
maxCircDiamPix = 15;
zArea = pi()*z.^2;
zScaled = round(scaledata(100./zArea,1,maxCircDiamPix));

for i=1:length(z)
    if ~isnan(zScaled(i))
        plot(x(i),y(i),'ko','MarkerSize', zScaled(i),'MarkerEdgeColor',[0 0 0],'LineWidth', 2);
    end
end

minMax = minmax(z);
legend(sprintf('Stimulus amplitude: %dmV to %dmV', minMax(1), minMax(2)))

expName = path_name_decomposition(pwd,'part_no',2,'reverse','string_out');
titleName = [expName,': ', out.file_name];
title(titleName, 'FontSize', 15, 'Interpreter', 'none')
set(h,'Position', [    288          59        1545        1039])