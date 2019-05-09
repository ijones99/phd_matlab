% convert brightness measurements to vector of avg vals

measuredData = load('~/Equipment/Beamer/Brightness_Info/11Apr2014log2_values.mat');
A = measuredData.A;

diffA = diff(A);

diffA_idx = find(diffA>3e-7)
diffA_idxTooClose = find(diff(diffA_idx)<10); 
diffA_idx(diffA_idxTooClose)=[];

figure, plot(diffA); hold on
dotX = diffA_idx;
dotY = ones(1,length(dotX))*3e-7;
plot(dotX,dotY,'ro')

%add to end
for i=length(diffA_idx)+1:52
    
    diffA_idx(i)=diffA_idx(i-1)+100;
end

relData= zeros(length(diffA_idx),diffA_idx(i)+min(diff(diffA_idx))-10 - (diffA_idx(i)+10)+1) ;
for i=1:length(diffA_idx)
relData(i,:) = A(diffA_idx(i)+10:diffA_idx(i)+min(diff(diffA_idx))-10);
end

meanVal = mean(relData,2);
percentVal = meanVal/max(meanVal);