function spikeTimes = get_spiketimes(ctrEl, expDate, fileNameShort,fileNameConfig)

Fs=2e4;
numSecsLoad = 30;

fileName.spont = sprintf('Trace_20%s_%s.raw.h5',expDate, fileNameShort)
fileName.config = [fileNameConfig, '.mapping.nrk'];
[f m validIdx] = ...
    mea1kadd.load_mea1k_file_pointer(expDate, fileName.spont, fileName.config );

elNumsSort = mea1kadd.get_neighboring_el(ctrEl, m)

% elNumsSortAll = [elNumsSortStim' elNumsSort'];
% load data 
[f m X Xfilt validIdx] = mea1kadd.load_raw_data(...
    expDate, fileName.spont, fileName.config,elNumsSort, Fs*numSecsLoad );

% remove dud channels
isNan = find(isnan(Xfilt)); 
if ~isempty(isNan)
    Xfilt(isNan(1):end,:) = [];
end

spikes = mea1kadd.spikesort_ums(Xfilt);

clusNo = input('Save "spikes" and enter cluster number >> ');

% save spikes
save(['analyzed_data/spontan_f',strrep(fileNameShort,'_','')],'spikes');

idxTs = find(spikes.assigns==clusNo);

spikeTimes= round(spikes.spiketimes(idxTs)*Fs);

end
