function [out] = compute_volt_stimulus_response(outRegional, out,varargin)
% function [out] = compute_volt_stimulus_response(outRegional, out)
%
% varargin
%   'set_stim_and_readout': '1' or '0' to set stim and readout.

doSetStimAndReadoutChs = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'set_stim_and_readout')
            doSetStimAndReadoutChs = varargin{i+1};
        end
    end
end

% plot the footprint from the regional scan
% 
% [nrg ah] = open_neurorouter;
% plot_footprints_simple([outRegional.footprint.mposx outRegional.footprint.mposy], ...
%     outRegional.footprint.wfs, ...
%     'input_templates','hide_els_plot','format_for_neurorouter',...
%     'plot_color','b', 'flip_templates_ud','flip_templates_lr','scale', 40);

gui.plot_hidens_els('hold_on');
plot_footprints_simple([outRegional.footprint.mposx outRegional.footprint.mposy], ...
    outRegional.footprint.wfs, ...
    'input_templates','hide_els_plot',...
    'plot_color','b', 'scale', 55);

saveFileName = [];
if doSetStimAndReadoutChs
    out = neur_struct.cell_stim_volt.set_stim_and_readout_els( out , saveFileName, ...
        'save', 0, 'suppress_xy_lims',...
       'xy_from_all_flists','sel_only_somatic_els'); % 
end
responseCurve = [];
stimDAC = 2;
preTimeMsec = 1;
postTimeMsec = 5;
ic50 = [];

doPreFilter = 0;
% convert files to hdf
recFreqMsec = 2e1;
for i=1:length(out.configs_stim_volt.flist)
    if ~exist(strrep(out.configs_stim_volt.flist{i},'.ntk','.h5'))
        mysort.mea.convertNTK2HDF(out.configs_stim_volt.flist{i},'prefilter', doPreFilter);
    else
        fprintf('Already converted.\n');
    end
    fprintf('progress %3.0f\n', 100*i/length(out.configs_stim_volt.flist));
end
yFit = {};
figure, hold on
for fileInd = 1:length(out.configs_stim_volt.flist) % go through all files
    % (each file corresponds to a different stimulation electrode configuration
    hold on
    % load h5 file
    mea1 = mysort.mea.CMOSMEA(strrep(out.configs_stim_volt.flist{fileInd},'.ntk','.h5'), 'useFilter', ...
        0, 'name', 'Raw');
    
    % check for stim el
    % dataLoaded = mea1.getData;
    if sum(diff(out.configs_stim_volt.dac2{fileInd}+...
            out.configs_stim_volt.dac1{fileInd})) == 0
        phaseType = 'Opposed';
    else
        phaseType = 'Same';
    end
    
    pulseType = 'biphasic';
    if strcmp(pulseType,'biphasic')
        numDACSwitchesPerStim = 3;
    elseif strcmp(pulseType,'triphasic')
        numDACSwitchesPerStim = 4;
    end
    
    % get stim timepoints
    if stimDAC == 1
        stimDACData = out.configs_stim_volt.dac1{fileInd};
    elseif stimDAC == 2
        stimDACData = out.configs_stim_volt.dac2{fileInd};
    end
    
    threshNumTimesRms = 3.5;
    plotChoice = 'no_plot';
%     zeroStimVals = find(out.configs_stim_volt.amps2{1}(:,1)==0);
    %         out.configs_stim_volt.amps2{1}(zeroStimVals,:) = [];
    doRecalculateCurves = 1;
    
    currStimChs = out.configs_stim_volt.stimCh{fileInd}; %stim electrode
    % determine where stimulation els are (which cell section) and which
    % electrodes should be used to determine readout els.
    
    elStimFields = fields(out.stim_in_out.stim_els);
    currStimEls = out.el_idx{fileInd}(find(out.channel_nr{fileInd}==currStimChs));
    iField = 1;
  
    fieldNo = [];
    for iField = 1:length(elStimFields)
        if find(getfield(out.stim_in_out.stim_els,elStimFields{iField}) ...
            == currStimEls(1))
            fieldNo = iField;
        end
        
    end
    
    if ~isempty(fieldNo)
        elidxReadout = getfield(out.stim_in_out.read_els,elStimFields{fieldNo});
        epochDataSig = {};
        meanData = {};
        for ampIndex = 1:length(out.configs_stim_volt.amps2{1}(:,1))
            
            try
                if doRecalculateCurves
                    
                    elIdx = out.el_idx{fileInd};
                    [traceIdxSpike numReps epochDataSig{ampIndex,1} meanData{ampIndex,1}] =...
                        spike_detector_i(stimDACData, ...
                        numDACSwitchesPerStim,ampIndex, ...
                        preTimeMsec, postTimeMsec, elIdx, elidxReadout, ...
                        mea1, threshNumTimesRms,...
                        plotChoice,'ylim', [-200,300]);
                end
            catch
                traceIdxSpike = 0;
            end
            responseCurve(fileInd, ampIndex) = length(traceIdxSpike)/numReps;
            title(num2str(ampIndex));
        end
        
        x = out.configs_stim_volt.amps2{1}(:,1)*2;
        y = responseCurve(fileInd,:);
        plotColor = rand(1,3);
        set(gca,'FontSize',15)
        
        plot(x,y,'o--', 'Color',plotColor ,'LineWidth', 2)
        try
            fittedData{fileInd} = fit_sigmoidal_curve_to_percent_response(x,y);
            %     plot(fittedData{fileInd}, 'k');
            yFit{fileInd} = feval(fittedData{fileInd} ,x);
            plot(x,yFit{fileInd},'Color', plotColor);
            [junk ic50idx] = min(abs(yFit{fileInd}-0.5));
            ic50(fileInd) = x(ic50idx);
            plot(ic50(fileInd),yFit{fileInd}(ic50idx),'ro','LineWidth', 2);
            junk = input('ok location? [enter/(s)elect/(i)gnore/(p)lot]','s');
            % select the correct ic50
            if strcmp(junk,'s')
                [guiSelX, guiSelY] = ginput(1);
                [junk xAxisInd] = min(abs(x-guiSelX));
                plot(x(xAxisInd),guiSelY,'r+','LineWidth', 2);
                % no real ic50
            elseif strcmp(junk,'i')
                ic50(fileInd) = NaN;
                
            elseif strcmp(junk,'p')
                figure, plot(cell2mat(meanData)')
                
            end
            
        catch
            fittedData{fileInd} = [];
            fprintf('Error\n')
            ic50(fileInd) = NaN;
        end
        drawnow
%         clf(h);
        out.analysis_stim_volt.ic50 = ic50;
        legend off
        hold off
        
        %     title(sprintf('Response Curves: %s',stimCellName), 'Interpreter', 'none','FontSize', 16);
        xlabel('Stimulus Amplitude (mV)','FontSize', 15);
        ylabel('Cell Response (decimal)','FontSize', 15);
    end
end

