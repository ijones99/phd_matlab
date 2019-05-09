% Analyze the data from the voltage stimulation and put the data into an 
% "out" struct.

stimCellName = 'neur_stim_cell_01';
dirName = sprintf('log_files/%s/',stimCellName); 
% out = {};
out.configs_stim_volt = merge_settings_files(dirName);
flistAll = print_stim_settings_data(out.configs_stim_volt, 'stimType', ...                        
    'stimCh', 'flist' );
%% Convert files and load DAC info --> save to out file.
fileName = 'neur_stim_cell_01'; 
out = neur_struct.cell_stim_volt.data_analysis.make_out_structure_for_volt_stimulus_response(fileName,out)

if exist(stimCellName, 'file')
    junk = input('file exists!');
end

fileInd = 7;
flist = {}; flist = flistAll;
for m = 1
    
    %     cell2mat(out.configs_stim_volt.stimCh);
    %
    doPreFilter = 0;
    % convert file
    recFreqMsec = 2e1;
    
    out.run_name = stimCellName;
    out.flist = flistAll;
    
    for i=1:length(flist)
        if ~exist(strrep(out.flist{i},'.ntk','.h5'))
            mysort.mea.convertNTK2HDF(out.flist{i},'prefilter', doPreFilter);
        else
            fprintf('Already converted.\n');
        end
        
        % load dac info
        ntkExtractedFieldsName = strrep(strrep(out.flist{i},'.stream','_extract_fld'),'.ntk','.mat');
        
        ntkOut = load_field_ntk(out.flist{i}, {'dac1', 'dac2'});
        out.configs_stim_volt = add_field_to_structure(out.configs_stim_volt,['dac1{',num2str(i) ,'}'], ntkOut.dac1);
        out.configs_stim_volt = add_field_to_structure(out.configs_stim_volt,['dac2{',num2str(i) ,'}'], ntkOut.dac2);
        

        
        if sum(diff(ntkOut.dac2+ntkOut.dac1)) == 0
            phaseType = 'Opposed';
        else
            phaseType = 'Same';
        end
        
        out.configs_stim_volt = add_field_to_structure(out.configs_stim_volt,['stim_phase_type{', num2str(i),'}'], phaseType);
        
        
        fprintf('progress %3.0f\n', 100*i/length(out.flist));
    end
    % load h5 file
    mea1 = mysort.mea.CMOSMEA(strrep(out.flist{i},'.ntk','.h5'), 'useFilter', 0, 'name', 'Raw');
    out.channel_nr = mea1.getChannelNr;
    out.el_idx = mea1.MultiElectrode.getElectrodeNumbers;
    elPos = mea1.MultiElectrode.getElectrodePositions;
    % mea1{1}.getChannelNr
    out = add_field_to_structure(out,'channel_nr', mea1.getChannelNr);
%     [a b] = multifind(m, n,'J')
    
    out = add_field_to_structure(out,'x', elPos(:,1)');
    out = add_field_to_structure(out,'y', elPos(:,2)');
    

    
    out = add_field_to_structure(out,'file_name', stimCellName);
    save(sprintf('%s.mat', stimCellName),'out');
end