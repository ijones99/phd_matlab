function mainSettings = create_general_settings_file

P.save_file = 0;



    % BRIGHTNESS VALUES
    pixTransferFuncDir = '';
    % load pixel transfer function
    load(fullfile(pixTransferFuncDir, 'lookupTbMean_ND2_norm.mat'));
    mainSettings.BLACK_VAL = 0;
    mainSettings.WHITE_VAL = stim.projector.apply_projector_transfer_function_nearest_neighbor(255,lookupTbMean_ND2_norm);
    mainSettings.DARK_GRAY_VAL = stim.projector.apply_projector_transfer_function_nearest_neighbor(255*3/8,lookupTbMean_ND2_norm); % 50% below mid gray
    mainSettings.MID_GRAY_VAL = stim.projector.apply_projector_transfer_function_nearest_neighbor(255*4/8,lookupTbMean_ND2_norm); % mid gray
    mainSettings.LIGHT_GRAY_VAL = stim.projector.apply_projector_transfer_function_nearest_neighbor(255*5/8,lookupTbMean_ND2_norm); % 50% above mid gray
    mainSettings.DARK_GRAY_DECI = single(mainSettings.DARK_GRAY_VAL)/single(mainSettings.WHITE_VAL);
    mainSettings.MID_GRAY_DECI = single(mainSettings.MID_GRAY_VAL)/single(mainSettings.WHITE_VAL);
    mainSettings.LIGHT_GRAY_DECI = single(mainSettings.LIGHT_GRAY_VAL)/single(mainSettings.WHITE_VAL);
    
    % um to pixels conversion
    mainSettings.UM_TO_PIX_CONV = 1/0.6144;% equals 1.6276

    mainSettings.movieEdgeLengthPx = 750; %
    mainSettings.delayBetweenStimuli = 10;
    mainSettings.END_EXP_PAUSE = 10;
    
    if P.save_file
       save('GeneralSettings.mat', 'mainSettings'); 
    end
    
end