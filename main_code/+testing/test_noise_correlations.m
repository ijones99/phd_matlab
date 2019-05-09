   ntk=initialize_ntkstruct(configs.flist{1},'hpf', 500, 'lpf', 3000);
   [ntk2 ntk]=ntk_load(ntk, 100000, 'images_v1');
   
   
ntk2 = extract_noise(ntk2)
%% plot els
figure, plot(ntk2.x,ntk2.y,'cs'), axis equal
text(ntk2.x+1,ntk2.y,num2cell(1:size(ntk2.sig,2))','Color', 'k')

%% find closest els
idxMain = 38; % 60 works for 09Dec2014_02
distMax = 70;
locMain.x = ntk2.x(idxMain );
locMain.y = ntk2.y(idxMain );

 [ distance] = geometry.get_distance_between_2_points(ntk2.x, ntk2.y, locMain.x , locMain.y)
idxClose = find(distance<distMax);
% sort by distance
[Y I] = sort(distance(idxClose),'ascend');
idxCloseSorted = idxClose(I);
% idxCloseSorted = idxCloseSorted(find(~ismember(idxCloseSorted,idxMain)));
%
h=figure;
figs.scale(h,50,100)
plotCnt = 1;
edges = subplots.find_edge_numbers_for_square_subplot(length(idxCloseSorted)+1);
sigMax = [];
for i=1:length(idxCloseSorted)
    subplot(edges(1),edges(2),plotCnt)
    sig1 = ntk2.noise_sig(:,39);
    sig2 = ntk2.noise_sig(:,idxCloseSorted(i));
    
    [C,LAGS] = xcorr(sig1, sig2);
    plot(LAGS,C,'k')
    
    plotCnt = 1 +plotCnt;
    sigMax(i) = max(C);
    if i==1
       yMax = max(C)*1.2; 
    end
    ylim([-1 1]*yMax)
    title(sprintf('idx %d, dist=%3.0f', idxCloseSorted(i), distance(idxCloseSorted(i))))
end

subplot(edges(1),edges(2),plotCnt);
plot(distance(idxCloseSorted), sigMax,'sr')
