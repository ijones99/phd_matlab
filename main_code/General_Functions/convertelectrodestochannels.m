function channelList = convertelectrodestochannels(electrodeOfInterest, electrode_list, ntk2, number_els)
    
    %find the closest electrodes to the inputted electrode
    rowInElectrodeList = find(electrode_list(:,1) == electrodeOfInterest);
    electrodeNumbers = electrode_list(rowInElectrodeList,:);
    
    %convert a vector of channel numbers to electrode numbers.
    
    for m = 1:number_els+1
        try
            channelList(m) = ntk2.channel_nr( find(ntk2.el_idx == electrodeNumbers(m)));
        catch
            disp('Error in func channelList, cannot reference electrode to channel #');
    end
    end
    

end