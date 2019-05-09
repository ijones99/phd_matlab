function [positionen] = extract_config_from_flist(flist, file_name, positionen)

file_id=fopen(file_name, 'w');

list = [];

fprintf(file_id, '#xmin\t xmax\t ymin\t ymax\t stim_elec\t dac_amp\t dac_range\t fname\n');

for i = 1:length(flist)
    fname = flist{i}
    ntk = initialize_ntkstruct( fname , 'nofilters');
    %ntk = initialize_ntkstruct( fname , 'nofilters', 'verbose');
    [ntk2 ntk] = ntk_load(ntk, 1000, 'nofiltering');
    % omit the first 1000 data samples
    [ntk2 ntk] = ntk_load(ntk, 2000, 'nofiltering');
    xmin = min(ntk2.x);
    xmax = max(ntk2.x);
    ymin = min(ntk2.y);
    ymax = max(ntk2.y);
    fname = ntk2.fname;

%    dac_amp = demodulate_freq(ntk2.dac1, 1000,20000);
%    dac_range = ntk.dac_range;

%    [a b c d e] = process_data(ntk2);

 %   [a1 st_el] = max(a);
%    stim_elec = ntk2.channel_nr(st_el);

%    list{end+1} = {xmin, xmax, ymin, ymax, dac_amp, dac_range, fname, stim_elec};

%    fprintf(file_id,'%4.3f\t\t%04.3f\t\t%04.3f\t\t%04.3f\t\t%04.3f\t\t%1.4f\t\t%d\t\t%s\n', xmin, xmax, ymin, ymax, stim_elec, dac_amp, dac_range, fname );
%    fprintf(file_id,'%d\t\t%3.4f\t\t%d\t\t%s\n', stim_elec, dac_amp, uint16(dac_range*1000), fname );

%    if ( length(stim_elec) > 1) 
%        fprintf(file_id,'XXX XXX XXX\n', fname, xmin, xmax, ymin, ymax, stim_elec );
%    end

    positionen{end+1} = {fname, [xmin xmax ymin ymax]};
end

fclose(file_id);
