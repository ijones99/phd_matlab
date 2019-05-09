function create_configuration_from_el_numbers_with_static_els(dirName, fileName, staticEls, nonstaticEls)

version=2;
all_els=hidens_get_all_electrodes(version);

npos_multiloc={};
% static els
for n=1:length(staticEls)
    npos_multiloc{end+1}.label=sprintf('static_els%d', n);
    npos_multiloc{end}.x=all_els.x(find(all_els.el_idx==staticEls(n)));
    npos_multiloc{end}.y=all_els.y(find(all_els.el_idx==staticEls(n)));
    npos_multiloc{end}.cost=0;
    npos_multiloc{end}.elcnt=1;%length(staticEls);

end
% block els -> check in
for n=1:length(nonstaticEls)
    npos_multiloc{end+1}.label=sprintf('nonstatic_els%d', n);
    npos_multiloc{end}.x=all_els.x(find(all_els.el_idx==nonstaticEls(n)));
    npos_multiloc{end}.y=all_els.y(find(all_els.el_idx==nonstaticEls(n)));
    npos_multiloc{end}.cost=50;
    npos_multiloc{end}.elcnt=1;
  
end


hidens_write_neuroplacement(strcat(fileName, '.neuropos.nrk'), ...
    'npos', npos_multiloc, 'size', 20, 'folder', dirName);

end