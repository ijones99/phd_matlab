function pixVal = get_lookup_table_value(percentValue, lookupTable)


    powerValue = (max(lookupTable) - min(lookupTable))*percentValue/100 + min(lookupTable);

    pixVal = find(abs(lookupTable-powerValue) == min(abs(lookupTable-powerValue))) -1;

    




end