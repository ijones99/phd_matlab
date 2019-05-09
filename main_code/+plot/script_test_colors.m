cMap = distinguishable_colors(11);
cMap = cMap([1:3 5 7:11],:);
h= figure
hold on
for i=1:size(cMap,1) %[7 12 17 25 28 41 46 56 60]%
   plot(i,0,'s','LineWidth', 15,'Color', cMap(i,:)) 
   text(i,0,num2str(i))
end