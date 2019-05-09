function channelNr = convert_el_numbers_to_chs(flist, inputElNumbers)
% output:
% channelNr: channel numbers
% elIdx: 4-digit el number
% 

% make sure that there is only one flist
if size(flist,1)>1|iscell(flist)
   flist2 = flist{1}; 
   clear flist
   flist = flist2;
end

% load data
siz=100;
ntk=initialize_ntkstruct(flist,'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz);

% indices to make b look like a
[Y I] = ismember(inputElNumbers , ntk2.el_idx);

channelNr = ntk2.channel_nr(I(find(I>0)));
if sum(ismember(I,0))
   fprintf('Error: zeros in indices\n'); 
end
    
fprintf('convert_el_numbers_to_chs done\n');

end