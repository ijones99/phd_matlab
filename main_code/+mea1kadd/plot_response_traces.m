function plot_response(expDate, fileName, configName, readoutEls) 

minElValue = 5000;
numTestStim = 0;

% get lut info
% Metadata: file numbers to id files
LUT.filename_meta = mea1kadd.files.file2meta_lut(expDate, fileName);
LUT.filename_rec = mea1kadd.files.meta2file_lut(expDate, LUT.filename_meta);

[Xread DAC ] = mea1kadd.processing.load_readout_channel_data(expDate, fileName, ...
    configName, readoutEls);



% load metadata
[metaData doubleEls] = mea1kadd.load_metadata(['data/',LUT.filename_meta]);
I = find(metaData{2}>minElValue);
% save el names that were stimulated
LUT.el_name = metaData{2}(I);
% save idx location for electrode stim labels
LUT.meta_data_idx = I;
LUT.test_stim_num = numTestStim;

% print file info
structs.print_fields(LUT, {'filename_rec','el_name'}) ;

stimTimes = find(diff(abs(DAC))>0.03*max(diff(abs(DAC))));

% create table for electrode: [ts, Voltage]
[f_stim m_stim validIdx] = ...
    mea1kadd.load_mea1k_file_pointer(expDate, fileName, configName );

LUTFileIdx = cells.strfind(LUT.filename_rec, fileName);
metaDataIdxEl = LUT.meta_data_idx(LUTFileIdx);

lookupTbStim = mea1kadd.make_stim_lookuptable(...
    m_stim, metaData, metaDataIdxEl, stimTimes, LUT.test_stim_num);

uniqueVoltages = unique(lookupTbStim(:,2));
numStimReps = length(lookupTbStim(:,2))/length(uniqueVoltages);
% STIMULATION: plot mean/median responses
%         mea1kadd.plot_mean_stim_response(m_stim, uniqueVoltages(1:end),lookupTbStim,...
%             Xread, stimEl, readoutEl)
%         figs.format_for_pub('journal_name', 'frontiers')
mea1kadd.plot_traces_stim_response(m_stim, uniqueVoltages(1:end),lookupTbStim,...
    Xread, 'y_spacing',20);



end
