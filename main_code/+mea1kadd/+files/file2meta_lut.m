function lutName = file2meta_lut(expDate, fileName)
% lutName = FILE2META_LUT(expDate, fileName)
%
% Descr.: used to get the meta data file name from the data file name
%


% load meta data
% if ~exist('metaAndDataLUT.mat','file')
metaAndDataLUT = mea1kadd.files.get_meta_and_data_file_lut(expDate);
save('metaAndDataLUT.mat','metaAndDataLUT');
% else
%     load('metaAndDataLUT.mat');
% end

idxLUT = cells.strfind(metaAndDataLUT(:,2),fileName);
lutName = metaAndDataLUT{idxLUT,1};

end
