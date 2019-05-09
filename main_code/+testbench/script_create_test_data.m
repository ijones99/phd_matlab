% create data
% spots:
% ON
spikeTimes = {};
numSpikes = 150;
for i=1:10
spikeTimes{i} = sort(normalize_values( rand(1,randi([numSpikes-20 numSpikes+20])),[0 2]));
end
%OFF{};
numSpikes = 50;
for i=11:20
spikeTimes{i} = sort(normalize_values( rand(1,randi([numSpikes-20 numSpikes+20])),[0 2]));
end



