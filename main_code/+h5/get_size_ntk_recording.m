function fileSize =  get_size_ntk_recording(flist)
% fileSize =  GET_SIZE_NTK_RECORDING(flist)
%
% Purpose: get the length (samples) and number of recording channels
%
meaData = load_h5_data(flist);
dataObj = meaData;

fileSize= {};

for i=1:length(dataObj);
    fileSize{i} = size(dataObj{i}.sessionList.h5matrix_raw);
end



end