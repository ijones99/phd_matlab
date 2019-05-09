function LUT = file2lut(fileNameCore, expDate)
% LUT = FILE2LUT(fileNameCore, expDate)

dirBase = '/net/bs-filesvr01/export/group/hierlemann/AnalyzedData/Mea1k/ijones/';
searchStr = ['*',fileNameCore,'*.h5'];
dirData = fullfile(dirBase, expDate,'data/');


fileNames = filenames.get_filenames(searchStr,dirData );

LUT.filename_meta = mea1kadd.files.file2meta_lut(expDate, fileNames.name);
LUT.filename_rec = mea1kadd.files.meta2file_lut(expDate, LUT.filename_meta);

end
