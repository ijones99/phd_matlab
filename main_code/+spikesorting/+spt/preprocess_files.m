function preprocess_files

thresholdVal = 4.5;
numEls = 7;
% select stim type
stimTypes = {'_wn_checkerboard'; ...
    '_marching_sqr_and_moving_bars'; ...
    '_marching_sqr'; ...
    '_moving_bars'; ...
    '_spots';...
    }
fprintf('Select stimulation type:\n ')
for i=1:length(stimTypes)
   fprintf('(%d) %s\n', i, stimTypes{i}); 
end
stimTypeSel = input('Select type [number] >> ');

% input stim run number, make flist name
fileRunNameNumber = input('Enter stim run number >>')
suffixName = sprintf('%s_n_%02d',stimTypes{stimTypeSel}, fileRunNameNumber);
flistName = sprintf('flist%s_n_%02d',stimTypes{stimTypeSel}, fileRunNameNumber);

% make flist
flist = make_flist_select([flistName,'.m'])

% enter center electrodes
procFileInfo = {};
procFileInfo.flist = flist;
elIdxCtr = [];
for i=1:length(flist)
    fprintf('(%d) %s.\n',i,flist{i} );
    procFileInfo.elIdxCtr(i) = input('Enter center el idx >> ');
end

% get el groups
% for i=1:length(procFileInfo.elIdxCtr )
%     fileName = sprintf('el_%04d.mat',procFileInfo.elIdxCtr(i));
%     stFileData = file.load_single_var(dirNameEl,fileName) ;
%     procFileInfo.elIdxGp{i} = stFileData.elidx;
%     % save to list
% 
% end


procFileCtrEl = [];
for i=1:length(flist)
    % make flist, get ID
    
    flistFileNameID = get_flist_file_id(flist{i}, suffixName);
    
    % dir names
    dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
    dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
    dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
    dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');

    fileName = sprintf('el_%04d.mat',procFileInfo.elIdxCtr(i));
    stFileData = file.load_single_var(dirNameEl,fileName) ;
    procFileInfo.elIdxGp{i} = stFileData.elidx;
    %
    pre_process_data(suffixName, flistName, 'config_type','exclusive',...
        'sel_by_els',procFileInfo.elIdxGp{i}, 'kmeans_reps',1,'threshold', thresholdVal);
    % save processed data
    procFileCtrEl(i) = procFileInfo.elIdxCtr(i);    
    save(sprintf('%s_info.mat',flistName), 'procFileCtrEl');
end


end
    

