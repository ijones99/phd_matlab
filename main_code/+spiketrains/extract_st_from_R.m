function st = extract_st_from_R(R, clusNo)
% st = extract_st_from_R_to_cell(R, clusNo)


stIdx =  find(R(:,1)==clusNo);
st = R(stIdx,2);


end