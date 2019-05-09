function stimInfo = get_stimulation_info_from_el2fi_files(dirName)
% function stimInfo = GET_STIMULATION_INFO_FROM_EL2FI_FILES(dirName)

stimInfo = {};
stimInfo.stimConfigNames = get_file_names_from_dir(dirName, '*el2fi*');
% get channels and electrodes for stimulation configurations
for iStimConfig=1:length(stimInfo.stimConfigNames)
    [stimInfo.elidxInFile{iStimConfig} stimInfo.chNoInFile{iStimConfig}] = ...
        get_el_ch_no_from_el2fi(dirName, stimInfo.stimConfigNames{iStimConfig});
end


end