function channelNo=chName2chNo( channelName )

mapping = struct( ...
'fr0', 0 , ...
'fr1', 1 , ...
'fr2', 2 , ...
'fr3', 3 , ...
'fr4', 4 , ...
'fr5', 5 , ...
'fr6', 6 , ...
'fr7', 7 , ...
'fr8', 8 , ...
'fr9', 9 , ...
'fr10', 10 , ...
'fr11', 11 , ...
'fr12', 12 , ...
'fr13', 13 , ...
'fr14', 14 , ...
'fr15', 15 , ...
'fr16', 16 , ...
'fr17', 17 , ...
'fr18', 18 , ...
'fr19', 19 , ...
'fr20', 20 , ...
'fr21', 21 , ...
'fr22', 22 , ...
'fr23', 23 , ...
'fr24', 24 , ...
'fr25', 25 , ...
'fr26', 26 , ...
'fr27', 27 , ...
'fr28', 28 , ...
'fr29', 29 , ...
'fr30', 30 , ...
'fr31', 31 , ...
'fr32', 32 , ...
'fr33', 33 , ...
'fr34', 34 , ...
'fr35', 35 , ...
'fb26', 36,  ...
'fb25', 37, ...
'fb24', 38, ...
'fb23', 39, ...
'fb22', 40, ...
'fb21', 41, ...
'fb20', 42, ...
'fb19', 43, ...
'fb18', 44, ...
'fb17', 45, ...
'fb16', 46, ...
'fb15', 47, ...
'fb14', 48, ...
'fb13', 49, ...
'fb12', 50, ...
'fb11', 51, ...
'fb10', 52, ...
'fb9', 53, ...
'fb8', 54, ...
'fb7', 55, ...
'fb6', 56, ...
'fb5', 57, ...
'fb4', 58, ...
'fb3', 59, ...
'fb2', 60, ...
'fb1', 61, ...
'fb0', 62, ...
'fl35', 63, ...
'fl34', 64, ...
'fl33', 65, ...
'fl32', 66, ...
'fl31', 67, ...
'fl30', 68, ...
'fl29', 69, ...
'fl28', 70, ...
'fl27', 71, ...
'fl26', 72, ...
'fl25', 73, ...
'fl24', 74, ...
'fl23', 75, ...
'fl22', 76, ...
'fl21', 77, ...
'fl20', 78, ...
'fl19', 79, ...
'fl18', 80, ...
'fl17', 81, ...
'fl16', 82, ...
'fl15', 83, ...
'fl14', 84, ...
'fl13', 85, ...
'fl12', 86, ...
'fl11', 87, ...
'fl10', 88, ...
'fl9', 89, ...
'fl8', 90, ...
'fl7', 91, ...
'fl6', 92, ...
'fl5', 93, ...
'fl4', 94, ...
'fl3', 95, ...
'fl2', 96, ...
'fl1', 97, ...
'fl0', 98, ...
'ft0', 99, ...
'ft1', 100, ...
'ft2', 101, ...
'ft3', 102, ...
'ft4', 103, ...
'ft5', 104, ...
'ft6', 105, ...
'ft7', 106, ...
'ft8', 107, ...
'ft9', 108, ...
'ft10', 109, ...
'ft11', 110, ...
'ft12', 111, ...
'ft13', 112, ...
'ft14', 113, ...
'ft15', 114, ...
'ft16', 115, ...
'ft17', 116, ...
'ft18', 117, ...
'ft19', 118, ...
'ft20', 119, ...
'ft21', 120, ...
'ft22', 121, ...
'ft23', 122, ...
'ft24', 123, ...
'ft25', 124, ...
'ft26', 125, ...
'temp', 126, ...
'dc', 127, ...
'st0', 128, ...
'st1', 129, ...
'st2', 130, ...
'st3', 131, ...
'st4', 132, ...
'st5', 133, ...
'st6', 134, ...
'st7', 135, ...
'st8', 136, ...
'st9', 137, ...
'st10', 138, ...
'st11', 139, ...
'st12', 140, ...
'st13', 141, ...
'st14', 142, ...
'st15', 143, ...
'st16', 144, ...
'st17', 145, ...
'st18', 146, ...
'st19', 147, ...
'st20', 148, ...
'st21', 149, ...
'st22', 150, ...
'st23', 151, ...
'st24', 152, ...
'st25', 153, ...
'st26', 154, ...
'st27', 155, ...
'st28', 156, ...
'st29', 157, ...
'st30', 158, ...
'st31', 159, ...
'st32', 160, ...
'st33', 161, ...
'st34', 162, ...
'st35', 163 );

channelNo = mapping.( channelName );

end
