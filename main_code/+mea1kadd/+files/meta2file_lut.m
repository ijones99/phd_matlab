function datafileName = file2meta_lut(expDate, fileNameLut)
% datafileName = FILE2META_LUT(expDate, fileNameLut)
%
% Descr.: used to get the data file name from the meta file name.
%


% load meta data
if ~exist('metaAndDataLUT.mat','file')
    metaAndDataLUT = mea1kadd.files.get_meta_and_data_file_lut(expDate);
    save('metaAndDataLUT.mat','metaAndDataLUT');
else
    load('metaAndDataLUT.mat');
end

idxLUT = cells.strfind(metaAndDataLUT(:,1),fileNameLut);
datafileName = metaAndDataLUT(idxLUT',2);

end
