function out = make_out_structure_for_volt_stimulus_response(cellName,out)

if nargin < 2
    out = {};
end

dirName = sprintf('log_files/%s/',cellName); 

out.configs_stim_volt = merge_settings_files(dirName);
out = add_field_to_structure(out,'channel_nr', {});
out = add_field_to_structure(out,'x', {});
out = add_field_to_structure(out,'y', {});
out = add_field_to_structure(out,'el_idx', {});

fprintf('read log files in log_files/')
% Convert files and load DAC info

if exist(cellName, 'file')
    junk = input('file exists!');
end

flist = out.configs_stim_volt.flist;
for m = 1
    
    %     cell2mat(out.configs_stim_volt.stimCh);
    %
    doPreFilter = 0;
    % convert file
    recFreqMsec = 2e1;
    out.run_name = cellName;
    
    for i=1:length(flist)
        if ~exist(strrep(out.configs_stim_volt.flist{i},'.ntk','.h5'))
            mysort.mea.convertNTK2HDF(out.configs_stim_volt.flist{i},'prefilter', doPreFilter);
        else
            fprintf('Already converted.\n');
        end
        
        % load dac info
        ntkExtractedFieldsName = strrep(strrep(out.configs_stim_volt.flist{i},'.stream','_extract_fld'),'.ntk','.mat');
        
        ntkOut = load_field_ntk(out.configs_stim_volt.flist{i}, {'dac1', 'dac2'});
        out.configs_stim_volt = add_field_to_structure(out.configs_stim_volt,['dac1{',num2str(i) ,'}'], ntkOut.dac1);
        out.configs_stim_volt = add_field_to_structure(out.configs_stim_volt,['dac2{',num2str(i) ,'}'], ntkOut.dac2);
        
        % determine type of stimulus
        if sum(diff(ntkOut.dac2+ntkOut.dac1)) == 0
            phaseType = 'Opposed';
        else
            phaseType = 'Same';
        end
        
        out.configs_stim_volt = add_field_to_structure(out.configs_stim_volt,['stim_phase_type{', num2str(i),'}'], phaseType);

                
        fprintf('progress %3.0f\n', 100*i/length(out.configs_stim_volt.flist));
        
        mea1 = mysort.mea.CMOSMEA(strrep(out.configs_stim_volt.flist{i},'.ntk','.h5'), 'useFilter', 0, 'name', 'Raw');
 
     
        
        out = add_field_to_structure(out,['el_idx{',num2str(i) ,'}'], [mea1.MultiElectrode.getElectrodeNumbers]');
        out = add_field_to_structure(out,['channel_nr{',num2str(i) ,'}'], mea1.getChannelNr);
                stimElInd = find(out.channel_nr{i}==out.configs_stim_volt.stimCh{i});
        out.configs_stim_volt.stimEl{i} = out.el_idx{i}(stimElInd);
        elPos = mea1.MultiElectrode.getElectrodePositions;
        out = add_field_to_structure(out,['x{',num2str(i) ,'}'], elPos(:,1)');
        out = add_field_to_structure(out,['y{',num2str(i) ,'}'], elPos(:,2)');
        
        
        
    end
    
    xyUnique = unique_in_cells_of_structure(out, 'el_idx', {'x','y','el_idx'});
    out = add_field_to_structure(out,'x_unique', xyUnique.x);
    out = add_field_to_structure(out,'y_unique', xyUnique.y);
    out = add_field_to_structure(out,'el_idx_unique', xyUnique.el_idx);
    
  
    save(sprintf('%s.mat', cellName),'out');
end




end