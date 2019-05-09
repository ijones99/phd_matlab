function matOut = add_noise_to_mat(matIn, noiseRange)
% matOut = ADD_NOISE_TO_MAT(matIn, noiseRange)

matSz= size(matIn);

noiseToAdd = normalize_values(rand(matSz), noiseRange);

matOut = matIn + noiseToAdd;

end