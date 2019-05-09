function y=hidens_load(fnamebase, configfname, start_idx, chunck_size, save_on, adc_range, sample_rate)
%
% load already converted data from .mat file if available, otherwise
% converts the data
%
%


if nargin<7
    sample_rate = 20000;
end
if nargin<6
    adc_range = 3;
end
if nargin<6
    save_on = 'y';
end

convFName=['../proc/' fnamebase '_' num2str(start_idx) '_' num2str(start_idx+chunck_size) '.mat'];

if exist(convFName)
    load(convFName, 'data');
    y=data;
else 
    y=convert2mat(fnamebase, configfname, start_idx, chunck_size, save_on, adc_range, sample_rate);
end


