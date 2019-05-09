function LUT = el2file(elNoInt, expDate)
% LUT = EL2FILE(fileNameCore, expDate)
% 
% output: el num, file name

numStimEls = 1;

dirBase = '/net/bs-filesvr01/export/group/hierlemann/AnalyzedData/Mea1k/ijones/';
searchStr = 'metaInfo*';
dirData = fullfile(dirBase, expDate,'data/');

% fileNamesMeta = filenames.get_filenames(searchStr,dirData );

metaAndDataLUT = mea1kadd.files.get_meta_and_data_file_lut(expDate);
% choose file
[choiceIdx fileSel ]  =cells.choose_num_in_cell(metaAndDataLUT(:,2));

metaSel = metaAndDataLUT(choiceIdx,1);

idxFound = nan;
i=1;
while isnan(idxFound) & i< length(metaSel)
    try
        [metaData] = mea1kadd.load_metadata_to_struct(['data/',metaSel{i}],...
            'num_els',numStimEls);
        fprintf('%d) %d\n',i,metaData(i).el)
        if metaData(i).el == elNoInt
            idxFound = i;
        end
    end
    i= i+1;
    %     progress_info(i,length(metaSel));
end

if not(isnan(idxFound))
LUT.filename_meta = metaSel(idxFound);
LUT.filename_rec = fileSel(idxFound);
LUT.el = elNoInt;
else
   error('El not found');
   LUT = nan;
end

end
