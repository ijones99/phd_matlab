function [out fileName] = create_out_struct(meaData, spikes,ts, flist)
% function [out fileName] = create_out_struct(meaData, spikes,ts, flist)

sortGroupNumber = input('Enter sort group number(recording)>> ');
sortElGp = input('Enter number for selected el groups>> ');
fileName = sprintf('checkerboard_n_%02d_g_%02d',sortGroupNumber,sortElGp);
if exist(fileName, 'file')
    junk = input('file exists!');
end

for i=1%:length(meaData)
    out = create_neur_struct(meaData{i}, spikes.labels(:,1), ts{i}, 'ds_cell', ...
        flist{i},'load_ntk_fields', {'images.frameno','dac1', 'dac2'});
    % add frame and dac info
    out = add_field_to_structure(out,'file_name', fileName);
    %     out = add_field_to_structure(out,'configs_stim_light', configs_stim_light);
    %     out = add_field_to_structure(out,'static_els', profData.staticEls);
    out = add_field_to_structure(out,'profData.flist', flist);
    out = add_field_to_structure(out,'spikes', spikes);
    
end

end