function saveElConfigInfo(elConfigInfo)

if ~isdir('GenFiles/')
    mkdir('GenFiles/');
end

save(fullfile('GenFiles/', 'elConfigInfo.mat'),'elConfigInfo');



end
