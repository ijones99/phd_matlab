numBins = 30/.25;




for iStim = 1:2
    allBinned{iStim} = zeros(length(selSpikes{iStim}), numBins);
    for i=1:length(selSpikes{iStim})
        binned = hist(selSpikes{iStim}{i},numBins);
        allBinned{iStim}(i,:) = binned;
        i
    end
end

s{1} = mean(allBinned{1},2);
s1 = conv_gaussian_with_spike_train(s{1});

s{2} = mean(allBinned{2},2);
s2 = conv_gaussian_with_spike_train(s{2});


% figure, plot([1:length(binned)],binned), hold on

figure
plot(1:length(s1),s1,'r')

hold on
plot(1:length(s2),s2,'b')
      