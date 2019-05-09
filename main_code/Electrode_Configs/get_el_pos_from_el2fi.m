function [configX configY ] = get_el_pos_from_el2fi(dirName, fileName)

all_els=hidens_get_all_electrodes(2);

localInd = [];
    % get elidx and chnummbers
    [elidxInFile chNoInFile] = get_el_ch_no_from_el2fi(dirName, ...
        fileName);
    
    % get local indices to get positions
    for j=1:length(elidxInFile)
        localInd(j) = find(all_els.el_idx == elidxInFile(j));
        
        
    end
    
    configX=all_els.x(localInd);
    configY=all_els.y(localInd);

%         plot(configX,configY,'o','Color',rand(1,3));
   

end