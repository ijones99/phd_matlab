function output = apply_lookup_table(input, lookupTable)

output = intlut(uint8(input), uint8(lookupTable));

end