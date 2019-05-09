%%
% Script for projecting a "window stimulus" with a surround stimulus
% --------------- MAIN PARAMETERS --------------- %
% DESCRIPTION:
% This function creates a stimulus with a circle in the middle and a
% uniform surround square, both of which are uniquely controllable. The
% center and surround can be modulated between values of 0 and 255, the
% values of which, when random, are selected using a normal
% distribution function, normrnd(), which "generates random numbers from
% the normal distribution with mean parameter mu and standard deviation
% parameter sigma." The values for the center and surround at each frame
% are stored in the matrix, "ctrStimBaseVal" and "surrStimMtx,"
% respectively.

% Two files are generated in this function:
%     A file containing the file names that are generated: Output_File_Names_Ctr_Surr.mat
%     A file for each stimulus set: e.g. Stim01_CtrOutOfPhase.mat

% Structure containing all relevant settings; name is first
for i=1:1
    Settings.STIM_NAME={};
    edgeLengthPx = 750;
    % um to pixels conversion
    Settings.UM_TO_PIX_CONV = 1.6;
    
    % BRIGHTNESS VALUES
    pixTransferFuncDir = 'DataFiles/';
    % load pixel transfer function
    load(fullfile(pixTransferFuncDir, 'lookupTbMean_ND2_norm.mat'));
    Settings.BLACK_VAL = 0;
    Settings.WHITE_VAL = apply_projector_transfer_function_nearest_neighbor(255,lookupTbMean_ND2_norm);
    
    Settings.DARK_GRAY_VAL = apply_projector_transfer_function_nearest_neighbor(255*3/8,lookupTbMean_ND2_norm); % 25% below mid gray
    Settings.MID_GRAY_VAL = apply_projector_transfer_function_nearest_neighbor(255*4/8,lookupTbMean_ND2_norm); % mid gray
    Settings.LIGHT_GRAY_VAL = apply_projector_transfer_function_nearest_neighbor(255*5/8,lookupTbMean_ND2_norm); % 25% above mid gray
    Settings.DARK_GRAY_DECI = single(Settings.DARK_GRAY_VAL)/single(Settings.WHITE_VAL);
    Settings.MID_GRAY_DECI = single(Settings.MID_GRAY_VAL)/single(Settings.WHITE_VAL);
    Settings.LIGHT_GRAY_DECI = single(Settings.LIGHT_GRAY_VAL)/single(Settings.WHITE_VAL);
    
    % SCREEN SIZE VALUES
    Settings.SCREEN_SIZE = get(0,'ScreenSize');
    Settings.SCREEN_SIZE(1:2) = Settings.SCREEN_SIZE(4:-1:3); % switch so that dims are in rows x cols
    Settings.SCREEN_SIZE(3:4) = [];
    
    % SURROUND STIM SPECS
    Settings.SURR_DIMS = [edgeLengthPx edgeLengthPx];%round(([1032 1032])/Settings.UM_TO_PIX_CONV); %height and width of surround; ...
    % must be a multiple of stim resolution
    
    % CENTER STIM SPECS
    %     Settings.CTR_STIM_DIAM = round(300/Settings.UM_TO_PIX_CONV); %diameter in pixels
    %     CTR_STIM_RADIUS = Settings.CTR_STIM_DIAM/2;
    %     Settings.CTR_STIM_LOC = [Settings.SURR_DIMS]/2;% [height width]
    %     Settings.ctrStimI={};
    
    % PRESENTATION
    Settings.STIM_FREQ = 20; % Hz for presentation rate
    Settings.SCR_DELAY = 0.0167;
    Settings.INTER_FRAME_PAUSE_CAL = (1/Settings.STIM_FREQ) - Settings.SCR_DELAY;
    Settings.BEGIN_EXP_PAUSE = 1;% seconds to wait before beginning
    Settings.END_EXP_PAUSE = 1;% seconds to wait at end
    Settings.POST_REPS_SERIES_PAUSE = 1.5; % Pause after series of repetitions
    


%% -----------------  bar experiments ----------------- %
for stimType = 1
    % SETTINGS
    % name of stimulus
    Settings.STIM_NAME = 'StimParams_Bars.mat';
    
    Settings.BAR_REPEATS = 20;
    Settings.BAR_PAUSE_BTWN_REPEATS = 1;
    Settings.BAR_DRIFT_VEL_PX = [ Settings.SURR_DIMS(1)];
    %     Settings.BAR_BRIGHTNESS = [Settings.WHITE_VAL Settings.BLACK_VAL ];
    Settings.BAR_BRIGHTNESS = [...
        %         apply_projector_transfer_function_nearest_neighbor(255*7/8,lookupTbMean_ND2_norm); % 75 percent above middle gray
%         apply_projector_transfer_function_nearest_neighbor(255*6/8,lookupTbMean_ND2_norm);% 50 percent above middle gray
        %         apply_projector_transfer_function_nearest_neighbor(255*5/8,lookupTbMean_ND2_norm);% 25 percent above middle gray
        %         apply_projector_transfer_function_nearest_neighbor(255*3/8,lookupTbMean_ND2_norm);% -25 percent above middle gray
%         apply_projector_transfer_function_nearest_neighbor(255*2/8,lookupTbMean_ND2_norm);% -50 percent above middle gray
        %         apply_projector_transfer_function_nearest_neighbor(255*1/8,lookupTbMean_ND2_norm)% -75 percent above middle gray
%     apply_projector_transfer_function_nearest_neighbor(255*7/8,lookupTbMean_ND2_norm);  % 75 percent above middle gray   
    apply_projector_transfer_function_nearest_neighbor(255*6/8,lookupTbMean_ND2_norm);  % 50 percent above middle gray   
%     apply_projector_transfer_function_nearest_neighbor(255*5/8,lookupTbMean_ND2_norm);  % 25 percent above middle gray   
%     apply_projector_transfer_function_nearest_neighbor(255*3/8,lookupTbMean_ND2_norm);  % -25 percent above middle gray   
    apply_projector_transfer_function_nearest_neighbor(255*2/8,lookupTbMean_ND2_norm);  % -50 percent above middle gray   
%     apply_projector_transfer_function_nearest_neighbor(255*1/8,lookupTbMean_ND2_norm);
        
        
        
        ];
    Settings.BAR_DRIFT_ANGLE = [0:7]*45;
    Settings.f = 1/60;
    Settings.BAR_HEIGHT_PX = [  300]/Settings.UM_TO_PIX_CONV;
    Settings.BAR_WIDTH_PX = 300/Settings.UM_TO_PIX_CONV;
    
    numEvents = (Settings.BAR_REPEATS*length(Settings.BAR_DRIFT_VEL_PX)*...
        length(Settings.BAR_BRIGHTNESS)*length(Settings.BAR_HEIGHT_PX)* ...
        length(Settings.BAR_DRIFT_ANGLE));
    pauseTime = Settings.BAR_PAUSE_BTWN_REPEATS;    % seconds per event
    avgEventTime = sum(600./Settings.BAR_DRIFT_VEL_PX)/length( Settings.BAR_DRIFT_VEL_PX);
    runTime = numEvents*(pauseTime+avgEventTime)/60;%minutes
    
    fprintf('Run time is %3.0f minutes.\n',runTime);
    
    % save meta data & stim frames
    dirName = '';
    save(fullfile(dirName,Settings.STIM_NAME),'Settings'...
        );
    %write-protect file
    eval(['!chmod a-w ',fullfile(dirName,Settings.STIM_NAME)]);
end

%% ----------- Dots that change diameter  ----------------- %
for stimType = 1
    % SETTINGS
    % name of stimulus
    Settings.STIM_NAME = 'StimParams_SpotsIncrSize.mat';
    % All in seconds
    Settings.DOT_STIM_REPEATS = 20;
    Settings.DOT_INTER_SUB_SESSION_WAIT = 1;
    Settings.DOT_DOT_SHOW_TIME = 1;
    Settings.DOT_BRIGHTNESS_VAL = [Settings.WHITE_VAL   Settings.BLACK_VAL    ]
    % This function generates a number of frames, each with a dot
    % of varying diameter in the center (with pixel values of 0),
    ...surrounded by a background of x um by y um (pixel value of 1).
        ...the frames are each to be repeated a number of times, which must occur in
        ...a randomized fashion. Thus, vector is also outputted which tells the
        ...stimulus presentation function how to present the frames.
        
    % Create window stimulus
    Settings.DOT_DIAMETERS = [50 100 200 400 600 900]
    StimMats.varDotStimMtx = (false(Settings.SURR_DIMS(1), ...
        Settings.SURR_DIMS(2), 1));
    
    runTime = ((Settings.DOT_INTER_SUB_SESSION_WAIT+Settings.DOT_DOT_SHOW_TIME)*...
        Settings.DOT_STIM_REPEATS*length(Settings.DOT_BRIGHTNESS_VAL)*...
        length(Settings.DOT_DIAMETERS))/60;
    fprintf('Run time is %2.1f minutes.\n',runTime);
    
    for m=2:length(Settings.DOT_DIAMETERS)
        StimMats.varDotStimMtx(m)=StimMats.varDotStimMtx(1);
    end
    
    if isfield('StimMats','ctrStimInd')
        clear StimMats.ctrStimInd
    end
    
    for k=1:length(Settings.DOT_DIAMETERS )
        % reset backgnd stim
        % surround stimulus matrix filled with logical ones
        StimMats.surrStimMtx = Settings.MID_GRAY_DECI*ones([Settings.SURR_DIMS]);
        % center stim specs
        Settings.CTR_STIM_DIAM = round(Settings.DOT_DIAMETERS(k)/...
            Settings.UM_TO_PIX_CONV); %diameter in pixels
        Settings.CTR_STIM_RADIUS = Settings.CTR_STIM_DIAM/2;
        Settings.CTR_STIM_LOC = [Settings.SURR_DIMS]/2;% [height width]
        
        % assign x and y values for drawing the circle
        %     x = [-Settings.CTR_STIM_RADIUS:1:Settings.CTR_STIM_RADIUS];
        %     y = real(sqrt(Settings.CTR_STIM_RADIUS^2-(x).^2))+Settings.CTR_STIM_LOC(1);
        %     x = ceil(x+Settings.CTR_STIM_LOC(2));
        
        ctrStim = ones([Settings.SURR_DIMS]);
        
        %     j=1;
        %     for i= x
        %         stripeOfCirc = round([Settings.CTR_STIM_LOC(1)-...
        %             abs(round(y(j)-Settings.CTR_STIM_LOC(1)))...
        %             +1:round(y(j))]); % row vals for each col val
        %         circleInd = sub2ind( [Settings.SURR_DIMS],  stripeOfCirc,i*...
        %             ones(1,length(stripeOfCirc)) ); % get indices for center stim
        %         ctrStim(circleInd) = 0; % assign zero
        %         j=j+1;
        %     end
        %     Settings.CTR_STIM_RADIUS = round(Settings.CTR_STIM_RADIUS);
        tempCirc = 1-Circle(Settings.CTR_STIM_RADIUS);
        
        borderYTop = round((size(ctrStim,1)-2*Settings.CTR_STIM_RADIUS)/2);
        borderYBot = size(ctrStim,1)-borderYTop-2*Settings.CTR_STIM_RADIUS;
        
        borderXLeft = round((size(ctrStim,2)-2*Settings.CTR_STIM_RADIUS)/2);
        borderXRight = size(ctrStim,2)-borderXLeft-2*Settings.CTR_STIM_RADIUS;
        
        ctrStim(borderYTop:end-borderYBot-1, borderXLeft:end-borderXRight-1)=...
            tempCirc;
        
        StimMats.ctrStimInd{k} = find(ctrStim==0);
        
        % combine center stim with surround
        StimMats.surrStimMtx(StimMats.ctrStimInd{k}) = 0;
        StimMats.varDotStimMtx(:,:,k)=StimMats.surrStimMtx;
    end
    
    % number of frames that will be presented.
    COUNT_FRAMES = Settings.DOT_STIM_REPEATS*length(Settings.DOT_DIAMETERS);
    
    % randomized order of frames: will serve as index
    StimMats.RAND_FRAMES_IND = randperm(COUNT_FRAMES);
    % save(strcat('varying_dot_presentation_order',datestr(now,30),'.mat'),
    % 'RAND_FRAMES_IND')
    
    % table of values to index
    StimMats.FRAME_TABLE = repmat([1:length(Settings.DOT_DIAMETERS)],Settings.DOT_STIM_REPEATS,1);
    StimMats.FRAME_TABLE = reshape(StimMats.FRAME_TABLE,size(StimMats.FRAME_TABLE,1)*size(StimMats.FRAME_TABLE,2),1 );
    
    StimMats.PRESENTATION_ORDER = StimMats.FRAME_TABLE(StimMats.RAND_FRAMES_IND);
    
    % save meta data & stim frames
    dirName = '';
    save(fullfile(dirName,Settings.STIM_NAME),'Settings',...
        'StimMats');
    %write-protect file
    eval(['!chmod a-w ',fullfile(dirName,Settings.STIM_NAME)]);
    
end

%% ----------- Create white noise checkerboard  ----------------- %
for stimType = 1
    createNewWhiteNoise = input('Create new whitenoise file [n/y]?','s');
    Settings.SURR_DIMS = edgeLengthPx*ones(1,2);
    Settings.STIM_DUR = 45; %mins
    
    load(fullfile('', 'polyFitCoeff.mat'));
    
    
    Settings.DARK_GRAY_25PER_VAL = apply_projector_transfer_function_nearest_neighbor(255*3/8,lookupTbMean_ND2_norm);
    Settings.LIGHT_GRAY_25PER_VAL = apply_projector_transfer_function_nearest_neighbor(255*5/8,lookupTbMean_ND2_norm);
    
    % name of stimulus
    Settings.STIM_NAME = 'StimParams_10_Wn100PerCheckerboard.mat';
    % Basic Stimulus Settings
    
    Settings.WN_STIM_RES_UM = 50;% Resolution of surround stim in um (micrometers)
    Settings.WN_STIM_RES_PX = round(Settings.WN_STIM_RES_UM/Settings.UM_TO_PIX_CONV); % Resolution of surround stim in pix
    
     Settings.CHECKER_COUNT_DIMS = round([Settings.SURR_DIMS]/Settings.WN_STIM_RES_PX);
    Settings.WN_EDGE_LENGTH = Settings.CHECKER_COUNT_DIMS(1)*Settings.WN_STIM_RES_PX*ones(1,2);
     
    Settings.N_FRAMES = Settings.STIM_DUR * Settings.STIM_FREQ * 60 +100;
    white_noise_frames = false(Settings.CHECKER_COUNT_DIMS(1), Settings.CHECKER_COUNT_DIMS(2), Settings.N_FRAMES);
    
    rand('state',255)
    for k = 1:Settings.N_FRAMES
        white_noise_frames(:,:,k) = ...
            logical(randint(Settings.CHECKER_COUNT_DIMS(1),...
            Settings.CHECKER_COUNT_DIMS(2)));
        if k/100 == round(k/100)
           k 
        end
    end
    
    % save meta data & stim frames
    dirName = '';
    save(fullfile(dirName,'white_noise_frames.mat'),'white_noise_frames');
    
        % save meta data & stim frames
    dirName = '';
    save(fullfile(dirName,Settings.STIM_NAME),'Settings'...
        );
    %write-protect file
    eval(['!chmod a-w ',fullfile(dirName,Settings.STIM_NAME)]);
    
end

%% ----------- Center has white noise grating, surround checkerboard  ----------------- %
for stimType = 1
    % SETTINGS
    
    Settings.STIM_DUR = 45; %mins
    % name of stimulus
    Settings.STIM_NAME = 'StimParams_08_Wn25PerCheckerboard.mat';
    % Basic Stimulus Settings
    
    Settings.WN_STIM_RES_UM = 100;% Resolution of surround stim in um (micrometers)
    Settings.WN_STIM_RES_PX = round(Settings.WN_STIM_RES_UM/Settings.UM_TO_PIX_CONV); % Resolution of surround stim in pix
    
     Settings.CHECKER_COUNT_DIMS = round([edgeLengthPx edgeLengthPx]/Settings.WN_STIM_RES_UM); % must adjust side length to be a ...
    % multiple of the checker square size
        % Dimensions of central stimulus in microns

    
    Settings.WN_EDGE_LENGTH = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_PX;%in pix
    
    
    % Dimensions of central stimulus in microns
    Settings.WN_DIMS_UM = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_UM;
    
    Settings.WN_EDGE_LENGTH = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_PX;%in pix
    Settings.N_FRAMES = Settings.STIM_DUR * Settings.STIM_FREQ;
    
    % Basic Stimulus Settings
    Settings.WN_STIM_RES_UM = 100;% Resolution of surround stim in um (micrometers)
    Settings.WN_STIM_RES_PX = round(Settings.WN_STIM_RES_UM/UM_TO_PIX_CONV); % Resolution of surround stim in pix
    
    Settings.Settings.CHECKER_COUNT_DIMS = round([edgeLengthPx edgeLengthPx]/Settings.WN_STIM_RES_UM); % must adjust side length to be a ...
    multiple of the checker square size
    
    % Dimensions of central stimulus in microns
    Settings.WN_DIMS_PX = round(([Settings.WN_DIMS_UM ])/UM_TO_PIX_CONV); %height and width of center stim in pix;
    Settings.WN_EDGE_LENGTH = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_PX;%in pix
    
    % CENTER STIM
    Settings.WN_STIM_LOC = round([Settings.WN_DIMS_PX]/2); % center stim location in window
    
    % PRESENTATION
    Settings.STIM_FREQ = 20; % Hz for presentation rate
    Settings.STIM_DUR = 20*60; % Duration of stimulus (seconds)
    Settings.SURR_DIMS = round(([900 900 ])/UM_TO_PIX_CONV); %height and width of surround;
    
    Settings.N_REPEATS = 1;
    Settings.N_FRAMES = Settings.STIM_DUR*Settings.STIM_FREQ;
    
    Settings.SIN_VARIATION = 77; % sine wave goes from middle gray value (163) to +/- 70
    % Calculate parameters of the grating:
    p=ceil(1/Settings.f); % pixels/cycle, rounded up.
    fr=Settings.f*2*pi;
    Settings.visiblesize=2*Settings.grHalfGratingSizePx+1;
    
    % Create one single static grating image:
    x = meshgrid(-Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx + p, -Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx);
    grating = Settings.MID_GRAY_VAL + Settings.SIN_VARIATION*sin(fr*x);
    
    % Create circular aperture for the alpha-channel:
    [x,y]=meshgrid(-Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx, -Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx);
    circle = Settings.WHITE_VAL * (x.^2 + y.^2 <= (Settings.grHalfGratingSizePx)^2);
    grating(:,:,2) = 255;
    %     grating(1:2*Settings.grHalfGratingSizePx+1, 1:2*Settings.grHalfGratingSizePx+1, 2) = circle;
    
    % Store alpha-masked grating in texture and attach the special 'glsl'
    % texture shader to it:
    StimMats.patternSurr = grating;
    StimMats.patternSurr(:,:,1)=Settings.MID_GRAY_DECI*Settings.WHITE_VAL;
    
    % Build a second drifting grating texture, this time half the Settings.grHalfGratingSizePx
    % of the 1st texture:
    Settings.grHalfGratingSizeAperPx = ceil(Settings.grApertureWidthPx/2);
    Settings.visible2size = 2*Settings.grHalfGratingSizeAperPx+1;
    x = meshgrid(-Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx + p, -Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx);
    grating = Settings.MID_GRAY_VAL + Settings.SIN_VARIATION*sin(fr*x);
    
    % Create circular aperture for the alpha-channel:
    [x,y]=meshgrid(-Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx, -Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx);
    circle = Settings.WHITE_VAL * (x.^2 + y.^2 <= (Settings.grHalfGratingSizeAperPx)^2);
    
    % Set 2nd channel (the alpha channel) of 'grating' to the aperture
    % defined in 'circle':
    
    grating(:,:,2) = 0;
    StimMats.patternAper = grating;
    StimMats.patternAper(1:2*Settings.grHalfGratingSizeAperPx+1, 1:2*Settings.grHalfGratingSizeAperPx+1, 2) = circle;
    
    dirName = '';
    save(fullfile(dirName,Settings.STIM_NAME),'Settings',...
        'StimMats');
    %write-protect file
    eval(['!chmod a-w ',fullfile(dirName,Settings.STIM_NAME)]);
end






    %% GRATING SETTINGS
    Settings.grCycleWidthUm = 300; % width of cycle in um
    Settings.grCycleWidthPx =  Settings.grCycleWidthUm/Settings.UM_TO_PIX_CONV; % width of cycle in pix (spatial freq).
    
    Settings.f=1/Settings.grCycleWidthPx;
    Settings.grDriftSpeedUmSec = 300; % movement of gratings in um/sec
    Settings.grDriftSpeedPxSec = Settings.grDriftSpeedUmSec/Settings.UM_TO_PIX_CONV;
    Settings.grCyclesPerSecond = Settings.grDriftSpeedPxSec/Settings.grCycleWidthPx  ;
    Settings.angle=0;
    Settings.grGratingSizeUm = 1074;
    Settings.grGratingSizePx = round(Settings.grGratingSizeUm/Settings.UM_TO_PIX_CONV  );
    Settings.grHalfGratingSizePx=Settings.grGratingSizePx / 2;
    
    Settings.grApertureWidthUm = 300; %aperature width in um
    Settings.grApertureWidthPx = round(Settings.grApertureWidthUm/Settings.UM_TO_PIX_CONV);%aperature width in pix
    Settings.INC=Settings.WHITE_VAL-Settings.MID_GRAY_VAL;
    Settings.f=1/Settings.grCycleWidthPx;
    Settings.grWaitframes = 1;
    ifi = 1/60;
    Settings.grWaitduration = Settings.grWaitframes * ifi;
    % Recompute p, this time without the ceil() operation from above.
    % Otherwise we will get wrong drift speed due to rounding!
    Settings.p = 1/Settings.f; % pixels/cycle
    % Translate requested speed of the gratings (in cycles per second) into
    % a shift value in "pixels per frame", assuming given Settings.grWaitduration:
    Settings.shiftperframe = Settings.grCyclesPerSecond * Settings.p * Settings.grWaitduration;
    
    % Parameters for random selection of numbers
    Settings.randMu = Settings.grCycleWidthUm/2 % middle-value
    Settings.randSigma = Settings.grCycleWidthUm/4; %std
    
    % Parameters for stimulus frequency display
    % Randomly-generated numbers are duplicated so that for example, i=1:4
    % consists of all the same numbers if setting of
    % Settings.STIM_FREQ_FRAC_OF_60 is 1/4
    Settings.STIM_FREQ_FRAC_OF_60 = 1/4;
    % set state (to seed rand num generator)
    randn('state',0);
    %create random numbers
    StimMats.wnGratingAperatureOffset = single(randn(1, round((1/Settings.grWaitduration)*Settings.STIM_DUR*Settings.STIM_FREQ_FRAC_OF_60)));
    % create duplicate values to reduce frequency
    StimMats.wnGratingAperatureOffset = repmat(StimMats.wnGratingAperatureOffset,1/Settings.STIM_FREQ_FRAC_OF_60,1);
    StimMats.wnGratingAperatureOffset = reshape(StimMats.wnGratingAperatureOffset,1,size(StimMats.wnGratingAperatureOffset,1)...
        *size(StimMats.wnGratingAperatureOffset,2));
    % set standard deviation
    StimMats.wnGratingAperatureOffset=StimMats.wnGratingAperatureOffset*Settings.randSigma;
    % restrict to proper range
    StimMats.wnGratingAperatureOffset(find( StimMats.wnGratingAperatureOffset > Settings.grCycleWidthUm/2 )  ) = Settings.grCycleWidthUm/2;
    StimMats.wnGratingAperatureOffset(find( StimMats.wnGratingAperatureOffset < -Settings.grCycleWidthUm/2 )  ) = -Settings.grCycleWidthUm/2;

end

%% -----------------  Center has white noise grating, surround gray ----------------- %
for stimType = 1
    % SETTINGS
    % name of stimulus
    Settings.STIM_NAME = 'StimParams_00_GratingsWnSurrGray.mat';
    Settings.SIN_VARIATION = 77; % sine wave goes from middle gray value (163) to +/- 70
    % Calculate parameters of the grating:
    p=ceil(1/Settings.f); % pixels/cycle, rounded up.
    fr=Settings.f*2*pi;
    Settings.visiblesize=2*Settings.grHalfGratingSizePx+1;
    
    % Create one single static grating image:
    x = meshgrid(-Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx + p, -Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx*4);
    grating = Settings.MID_GRAY_VAL + Settings.SIN_VARIATION*sin(fr*x);
    
    % Create circular aperture for the alpha-channel:
    [x,y]=meshgrid(-Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx, -Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx);
    circle = Settings.WHITE_VAL * (x.^2 + y.^2 <= (Settings.grHalfGratingSizePx)^2);
    grating(:,:,2) = 255;
    %     grating(1:2*Settings.grHalfGratingSizePx+1, 1:2*Settings.grHalfGratingSizePx+1, 2) = circle;
    
    % Store alpha-masked grating in texture and attach the special 'glsl'
    % texture shader to it:
    StimMats.patternSurr = grating;
    StimMats.patternSurr(:,:,1)=Settings.MID_GRAY_DECI*Settings.WHITE_VAL;
    
    % Build a second drifting grating texture, this time half the Settings.grHalfGratingSizePx
    % of the 1st texture:
    Settings.grHalfGratingSizeAperPx = ceil(Settings.grApertureWidthPx/2);
    Settings.visible2size = 2*Settings.grHalfGratingSizeAperPx+1;
    x = meshgrid(-Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx + p, -Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx);
    grating = Settings.MID_GRAY_VAL + Settings.SIN_VARIATION*sin(fr*x);
    
    % Create circular aperture for the alpha-channel:
    [x,y]=meshgrid(-Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx, -Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx);
    circle = Settings.WHITE_VAL * (x.^2 + y.^2 <= (Settings.grHalfGratingSizeAperPx)^2);
    
    % Set 2nd channel (the alpha channel) of 'grating' to the aperture
    % defined in 'circle':
    
    grating(:,:,2) = 0;
    StimMats.patternAper = grating;
    StimMats.patternAper(1:2*Settings.grHalfGratingSizeAperPx+1, 1:2*Settings.grHalfGratingSizeAperPx+1, 2) = circle;
    
    % save meta data & stim frames
    dirName = '';
    save(fullfile(dirName,Settings.STIM_NAME),'Settings',...
        'StimMats');
    %write-protect file
    eval(['!chmod a-w ',fullfile(dirName,Settings.STIM_NAME)]);
end

%% -----------------  Center has white noise grating, surround 0 degree (corr) ----------------- %
for stimType = 1
    % SETTINGS
    % name of stimulus
    Settings.STIM_NAME = 'StimParams_01_GratingsWnSurrCorr.mat';
    Settings.SIN_VARIATION = 77; % sine wave goes from middle gray value (163) to +/- 70
    % Calculate parameters of the grating:
    p=ceil(1/Settings.f); % pixels/cycle, rounded up.
    fr=Settings.f*2*pi;
    Settings.visiblesize=2*Settings.grHalfGratingSizePx+1;
    
    % Create one single static grating image; multiplied by 4 to ensure
    % sufficient width
    x = meshgrid(-Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx*4 + p, -Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx*4);
    grating = Settings.MID_GRAY_VAL + Settings.SIN_VARIATION*sin(fr*x);
    
    % Create circular aperture for the alpha-channel:
    [x,y]=meshgrid(-Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx, -Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx);
    circle = Settings.WHITE_VAL * (x.^2 + y.^2 <= (Settings.grHalfGratingSizePx)^2);
    grating(:,:,2) = 255;
    %     grating(1:2*Settings.grHalfGratingSizePx+1, 1:2*Settings.grHalfGratingSizePx+1, 2) = circle;
    
    % Store alpha-masked grating in texture and attach the special 'glsl'
    % texture shader to it:
    StimMats.patternSurr = grating;
    % StimMats.patternSurr(:,:,1)=Settings.MID_GRAY_DECI*Settings.WHITE_VAL;
    
    % Build a second drifting grating texture, this time half the Settings.grHalfGratingSizePx
    % of the 1st texture:
    Settings.grHalfGratingSizeAperPx = ceil(Settings.grApertureWidthPx/2);
    Settings.visible2size = 2*Settings.grHalfGratingSizeAperPx+1;
    x = meshgrid(-Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx + p, -Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx);
    grating = Settings.MID_GRAY_VAL + Settings.SIN_VARIATION*sin(fr*x);
    
    % Create circular aperture for the alpha-channel:
    [x,y]=meshgrid(-Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx, -Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx);
    circle = Settings.WHITE_VAL * (x.^2 + y.^2 <= (Settings.grHalfGratingSizeAperPx)^2);
    
    % Set 2nd channel (the alpha channel) of 'grating' to the aperture
    % defined in 'circle':
    
    grating(:,:,2) = 0;
    StimMats.patternAper = grating;
    StimMats.patternAper(1:2*Settings.grHalfGratingSizeAperPx+1, 1:2*Settings.grHalfGratingSizeAperPx+1, 2) = circle;
    
    % save meta data & stim frames
    dirName = '';
    save(fullfile(dirName,Settings.STIM_NAME),'Settings',...
        'StimMats');
    %write-protect file
    eval(['!chmod a-w ',fullfile(dirName,Settings.STIM_NAME)]);
end

%% -----------------  Center has white noise grating, surround 180 degree (anticorr) ----------------- %
for stimType = 1
    % SETTINGS
    % name of stimulus
    Settings.STIM_NAME = 'StimParams_02_GratingsWnSurrAntiCorr.mat';
    
    Settings.SIN_VARIATION = 77; % sine wave goes from middle gray value (163) to +/- 70
    % Calculate parameters of the grating:
    p=ceil(1/Settings.f); % pixels/cycle, rounded up.
    fr=Settings.f*2*pi;
    Settings.visiblesize=2*Settings.grHalfGratingSizePx+1;
    
    % Create one single static grating image:
    x = meshgrid(-2*Settings.grHalfGratingSizePx:2*Settings.grHalfGratingSizePx*4 + p, -2*Settings.grHalfGratingSizePx:2*Settings.grHalfGratingSizePx*4);
    grating = Settings.MID_GRAY_VAL + Settings.SIN_VARIATION*sin(fr*x);
    
    % Create circular aperture for the alpha-channel:
    [x,y]=meshgrid(-Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx, -Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx);
    circle = Settings.WHITE_VAL * (x.^2 + y.^2 <= (Settings.grHalfGratingSizePx)^2);
    grating(:,:,2) = 255;
    %     grating(1:2*Settings.grHalfGratingSizePx+1, 1:2*Settings.grHalfGratingSizePx+1, 2) = circle;
    
    % Store alpha-masked grating in texture and attach the special 'glsl'
    % texture shader to it:
    StimMats.patternSurr = grating;
    % StimMats.patternSurr(:,:,1)=Settings.MID_GRAY_DECI*Settings.WHITE_VAL;
    
    % Build a second drifting grating texture, this time half the Settings.grHalfGratingSizePx
    % of the 1st texture:
    Settings.grHalfGratingSizeAperPx = ceil(Settings.grApertureWidthPx/2);
    Settings.visible2size = 2*Settings.grHalfGratingSizeAperPx+1;
    x = meshgrid(-Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx + p, -Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx);
    grating = Settings.MID_GRAY_VAL + Settings.SIN_VARIATION*sin(fr*x);
    
    % Create circular aperture for the alpha-channel:
    [x,y]=meshgrid(-Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx, -Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx);
    circle = Settings.WHITE_VAL * (x.^2 + y.^2 <= (Settings.grHalfGratingSizeAperPx)^2);
    
    % Set 2nd channel (the alpha channel) of 'grating' to the aperture
    % defined in 'circle':
    
    grating(:,:,2) = 0;
    StimMats.patternAper = grating;
    StimMats.patternAper(1:2*Settings.grHalfGratingSizeAperPx+1, 1:2*Settings.grHalfGratingSizeAperPx+1, 2) = circle;
    
    % save meta data & stim frames
    dirName = '';
    save(fullfile(dirName,Settings.STIM_NAME),'Settings',...
        'StimMats');
    %write-protect file
    eval(['!chmod a-w ',fullfile(dirName,Settings.STIM_NAME)]);
end

%% -----------------  Center has white noise grating, surround uncorr (both rand) ----------------- %
for stimType = 1
    % SETTINGS
    % name of stimulus
    Settings.STIM_NAME = 'StimParams_03_GratingsWnSurrUnCorr.mat';
    
    Settings.SIN_VARIATION = 77; % sine wave goes from middle gray value (163) to +/- 70
    % Calculate parameters of the grating:
    p=ceil(1/Settings.f); % pixels/cycle, rounded up.
    fr=Settings.f*2*pi;
    Settings.visiblesize=2*Settings.grHalfGratingSizePx+1;
    
    % Create one single static grating image:
    x = meshgrid(-2*Settings.grHalfGratingSizePx:2*Settings.grHalfGratingSizePx*4 + p, -2*Settings.grHalfGratingSizePx:2*Settings.grHalfGratingSizePx*4);
    grating = Settings.MID_GRAY_VAL + Settings.SIN_VARIATION*sin(fr*x);
    
    % Create circular aperture for the alpha-channel:
    [x,y]=meshgrid(-Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx, -Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx);
    circle = Settings.WHITE_VAL * (x.^2 + y.^2 <= (Settings.grHalfGratingSizePx)^2);
    grating(:,:,2) = 255;
    %     grating(1:2*Settings.grHalfGratingSizePx+1, 1:2*Settings.grHalfGratingSizePx+1, 2) = circle;
    
    % Store alpha-masked grating in texture and attach the special 'glsl'
    % texture shader to it:
    StimMats.patternSurr = grating;
    % StimMats.patternSurr(:,:,1)=Settings.MID_GRAY_DECI*Settings.WHITE_VAL;
    
    % Build a second drifting grating texture, this time half the Settings.grHalfGratingSizePx
    % of the 1st texture:
    Settings.grHalfGratingSizeAperPx = ceil(Settings.grApertureWidthPx/2);
    Settings.visible2size = 2*Settings.grHalfGratingSizeAperPx+1;
    x = meshgrid(-Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx + p, -Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx);
    grating = Settings.MID_GRAY_VAL + Settings.SIN_VARIATION*sin(fr*x);
    
    % Create circular aperture for the alpha-channel:
    [x,y]=meshgrid(-Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx, -Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx);
    circle = Settings.WHITE_VAL * (x.^2 + y.^2 <= (Settings.grHalfGratingSizeAperPx)^2);
    
    % Set 2nd channel (the alpha channel) of 'grating' to the aperture
    % defined in 'circle':
    
    grating(:,:,2) = 0;
    StimMats.patternAper = grating;
    StimMats.patternAper(1:2*Settings.grHalfGratingSizeAperPx+1, 1:2*Settings.grHalfGratingSizeAperPx+1, 2) = circle;
    
    % create randomized movement for surround
    randn('state',600);
    %create random numbers
    %     StimMats.wnGratingSurrOffset = single(randn(1, (1/Settings.grWaitduration)*...
    %         Settings.STIM_DUR+60));
    % create duplicate values to reduce frequency
    StimMats.wnGratingSurrOffset = repmat(StimMats.wnGratingSurrOffset,1/Settings.STIM_FREQ_FRAC_OF_60,1);
    StimMats.wnGratingSurrOffset = reshape(StimMats.wnGratingSurrOffset,1,size(StimMats.wnGratingSurrOffset,1)...
        *size(StimMats.wnGratingSurrOffset,2));
    % set standard deviation
    StimMats.wnGratingSurrOffset=StimMats.wnGratingSurrOffset*Settings.randSigma;
    % restrict to proper range
    StimMats.wnGratingSurrOffset(find( StimMats.wnGratingSurrOffset > Settings.grCycleWidthUm/2 )  ) = Settings.grCycleWidthUm/2;
    StimMats.wnGratingSurrOffset(find( StimMats.wnGratingSurrOffset < -Settings.grCycleWidthUm/2 )  ) = -Settings.grCycleWidthUm/2;
    
    
    % save meta data & stim frames
    dirName = '';
    save(fullfile(dirName,Settings.STIM_NAME),'Settings',...
        'StimMats');
    %write-protect file
    eval(['!chmod a-w ',fullfile(dirName,Settings.STIM_NAME)]);
end



%% -----------------  slit experiments ----------------- %
for stimType = 1
    % SETTINGS
    % name of stimulus
    Settings.STIM_NAME = 'StimParams_Slits.mat';
    
    Settings.SLIT_REPEATS = 3;
    Settings.SLIT_PAUSE_BTWN_REPEATS = 5;
    Settings.SLIT_DRIFT_VEL_PX = [200, 600,1200]/Settings.UM_TO_PIX_CONV;
    Settings.SLIT_BRIGHTNESS = [Settings.WHITE_VAL Settings.BLACK_VAL ];
    Settings.SLIT_HEIGHT_PX = [ 100 300 600  900]/Settings.UM_TO_PIX_CONV;
    Settings.slitDriftSpeedPx = Settings.SLIT_DRIFT_VEL_PX;
    
    runTime = (Settings.SLIT_REPEATS*Settings.SLIT_PAUSE_BTWN_REPEATS*length(Settings.SLIT_DRIFT_VEL_PX)*...
        length(Settings.SLIT_BRIGHTNESS)*length(Settings.SLIT_HEIGHT_PX)*length(Settings.slitDriftSpeedPx)*800/200)/60; %minutes
    fprintf('Run time is %d minutes.\n',runTime);
    
    % save meta data & stim frames
    dirName = '';
    save(fullfile(dirName,Settings.STIM_NAME),'Settings',...
        'StimMats');
    %write-protect file
    eval(['!chmod a-w ',fullfile(dirName,Settings.STIM_NAME)]);
end

%% ----------- Center has white noise grating, surround checkerboard  ----------------- %
for stimType = 1
    % SETTINGS
    % name of stimulus
    Settings.STIM_NAME = 'StimParams_06_GratingsWnSurrCheckerboard.mat';
    % Basic Stimulus Settings
    
    Settings.WN_STIM_RES_UM = 50;% Resolution of surround stim in um (micrometers)
    Settings.WN_STIM_RES_PX = round(Settings.WN_STIM_RES_UM/Settings.UM_TO_PIX_CONV); % Resolution of surround stim in pix
    
    Settings.CHECKER_COUNT_DIMS = round([900 900]/Settings.WN_STIM_RES_UM); % must adjust side length to be a ...
    ...multiple of the checker square size
        % Dimensions of central stimulus in microns
    Settings.WN_DIMS_UM = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_UM;
    % CTR_DIMS = round(([CTR_DIMS_UM ])/UM_TO_PIX_CONV); %height and width of center stim in pix;
    
    Settings.WN_EDGE_LENGTH = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_PX;%in pix
    
    % save meta data & stim frames
    dirName = '';
    save(fullfile(dirName,Settings.STIM_NAME),'Settings',...
        'StimMats');
    %write-protect file
    eval(['!chmod a-w ',fullfile(dirName,Settings.STIM_NAME)]);
    
end





%% ----------- Center has white noise grating, surround checkerboard  ----------------- %
for stimType = 1
    % SETTINGS
    % name of stimulus
    Settings.STIM_NAME = 'StimParams_06_GratingsWnSurrCheckerboard.mat';
    % Basic Stimulus Settings
    
    Settings.WN_STIM_RES_UM = 50;% Resolution of surround stim in um (micrometers)
    Settings.WN_STIM_RES_PX = round(Settings.WN_STIM_RES_UM/Settings.UM_TO_PIX_CONV); % Resolution of surround stim in pix
    
    Settings.CHECKER_COUNT_DIMS = round([900 900]/Settings.WN_STIM_RES_UM); % must adjust side length to be a ...
    ...multiple of the checker square size
        
% Dimensions of central stimulus in microns
Settings.WN_DIMS_UM = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_UM;

Settings.WN_EDGE_LENGTH = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_PX;%in pix
Settings.N_FRAMES = Settings.STIM_DUR * Settings.STIM_FREQ;

% Basic Stimulus Settings
Settings.WN_STIM_RES_UM = 50;% Resolution of surround stim in um (micrometers)
Settings.WN_STIM_RES_PX = round(Settings.WN_STIM_RES_UM/UM_TO_PIX_CONV); % Resolution of surround stim in pix

Settings.CHECKER_COUNT_DIMS = round([900 900]/Settings.WN_STIM_RES_UM); % must adjust side length to be a ...
...multiple of the checker square size
    
% Dimensions of central stimulus in microns
Settings.WN_DIMS_PX = round(([Settings.WN_DIMS_UM ])/UM_TO_PIX_CONV); %height and width of center stim in pix;
Settings.WN_EDGE_LENGTH = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_PX;%in pix

% CENTER STIM
Settings.WN_STIM_LOC = round([Settings.WN_DIMS_PX]/2); % center stim location in window

% PRESENTATION
Settings.STIM_FREQ = 25; % Hz for presentation rate
Settings.STIM_DUR = 45*60; % Duration of stimulus (seconds)
Settings.SURR_DIMS = round(([900 900 ])/UM_TO_PIX_CONV); %height and width of surround;

Settings.N_REPEATS = 1;
Settings.N_FRAMES = Settings.STIM_DUR*Settings.STIM_FREQ;

Settings.SIN_VARIATION = 77; % sine wave goes from middle gray value (163) to +/- 70
% Calculate parameters of the grating:
p=ceil(1/Settings.f); % pixels/cycle, rounded up.
fr=Settings.f*2*pi;
Settings.visiblesize=2*Settings.grHalfGratingSizePx+1;

% Create one single static grating image:
x = meshgrid(-Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx + p, -Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx);
grating = Settings.MID_GRAY_VAL + Settings.SIN_VARIATION*sin(fr*x);

% Create circular aperture for the alpha-channel:
[x,y]=meshgrid(-Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx, -Settings.grHalfGratingSizePx:Settings.grHalfGratingSizePx);
circle = Settings.WHITE_VAL * (x.^2 + y.^2 <= (Settings.grHalfGratingSizePx)^2);
grating(:,:,2) = 255;
%     grating(1:2*Settings.grHalfGratingSizePx+1, 1:2*Settings.grHalfGratingSizePx+1, 2) = circle;

% Store alpha-masked grating in texture and attach the special 'glsl'
% texture shader to it:
StimMats.patternSurr = grating;
StimMats.patternSurr(:,:,1)=Settings.MID_GRAY_DECI*Settings.WHITE_VAL;

% Build a second drifting grating texture, this time half the Settings.grHalfGratingSizePx
% of the 1st texture:
Settings.grHalfGratingSizeAperPx = ceil(Settings.grApertureWidthPx/2);
Settings.visible2size = 2*Settings.grHalfGratingSizeAperPx+1;
x = meshgrid(-Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx + p, -Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx);
grating = Settings.MID_GRAY_VAL + Settings.SIN_VARIATION*sin(fr*x);

% Create circular aperture for the alpha-channel:
[x,y]=meshgrid(-Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx, -Settings.grHalfGratingSizeAperPx:Settings.grHalfGratingSizeAperPx);
circle = Settings.WHITE_VAL * (x.^2 + y.^2 <= (Settings.grHalfGratingSizeAperPx)^2);

% Set 2nd channel (the alpha channel) of 'grating' to the aperture
% defined in 'circle':

grating(:,:,2) = 0;
StimMats.patternAper = grating;
StimMats.patternAper(1:2*Settings.grHalfGratingSizeAperPx+1, 1:2*Settings.grHalfGratingSizeAperPx+1, 2) = circle;


% save meta data & stim frames
dirName = '';
save(fullfile(dirName,Settings.STIM_NAME),'Settings',...
    'StimMats');
%write-protect file
eval(['!chmod a-w ',fullfile(dirName,Settings.STIM_NAME)]);
end



%% ----------- Checkerboard 25% contrast, surround only  ----------------- %
for stimType = 1
    % SETTINGS
    
    % um to pixels conversion
    Settings.UM_TO_PIX_CONV = 1.72;
    
    % name of stimulus
    Settings.STIM_NAME = 'StimParams_08_Wn25PerCheckerboard.mat';
    % Basic Stimulus Settings
    
    Settings.WN_STIM_RES_UM = 50;% Resolution of surround stim in um (micrometers)
    Settings.WN_STIM_RES_PX = round(Settings.WN_STIM_RES_UM/Settings.UM_TO_PIX_CONV); % Resolution of surround stim in pix
    
    % Dimensions of central stimulus in microns
    Settings.WN_DIMS_UM = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_UM;
    
    Settings.WN_EDGE_LENGTH = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_PX;%in pix
    Settings.N_FRAMES = Settings.STIM_DUR * Settings.STIM_FREQ;
    
    % Basic Stimulus Settings
    Settings.WN_STIM_RES_UM = 50;% Resolution of surround stim in um (micrometers)
    Settings.WN_STIM_RES_PX = round(Settings.WN_STIM_RES_UM/Settings.UM_TO_PIX_CONV); % Resolution of surround stim in pix
    
    Settings.Settings.CHECKER_COUNT_DIMS = round([900 900]/Settings.WN_STIM_RES_UM); % must adjust side length to be a ...
    % multiple of the checker square size
    
    % Dimensions of central stimulus in microns
    Settings.WN_DIMS_PX = round(([Settings.WN_DIMS_UM ])/Settings.UM_TO_PIX_CONV); %height and width of center stim in pix;
    Settings.WN_EDGE_LENGTH = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_PX;%in pix
    
    % CENTER STIM
    Settings.WN_STIM_LOC = round([Settings.WN_DIMS_PX]/2); % center stim location in window
    
    % PRESENTATION
    Settings.STIM_FREQ = 30; % Hz for presentation rate
    Settings.STIM_DUR = 45*60; % Duration of stimulus (seconds)
    Settings.SURR_DIMS = round(([900 900 ])/Settings.UM_TO_PIX_CONV); %height and width of surround;
    
    Settings.N_REPEATS = 1;
    Settings.N_FRAMES = Settings.STIM_DUR*Settings.STIM_FREQ;
    
    % save meta data & stim frames
    dirName = '';
    save(fullfile(dirName,Settings.STIM_NAME),'Settings',...
        'StimMats');
    %write-protect file
    eval(['!chmod a-w ',fullfile(dirName,Settings.STIM_NAME)]);
end

%% ----------- Checkerboard 60% contrast, surround only  ----------------- %
for stimType = 1
    % SETTINGS
    % name of stimulus
    
    Settings.STIM_NAME = 'StimParams_09_Wn60PerCheckerboard.mat';
    % Basic Stimulus Settings
    
    Settings.WN_STIM_RES_UM = 50;% Resolution of surround stim in um (micrometers)
    Settings.WN_STIM_RES_PX = round(Settings.WN_STIM_RES_UM/Settings.UM_TO_PIX_CONV); % Resolution of surround stim in pix
    
    % Dimensions of central stimulus in microns
    Settings.WN_DIMS_UM = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_UM;
    
    Settings.WN_EDGE_LENGTH = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_PX;%in pix
    Settings.N_FRAMES = Settings.STIM_DUR * Settings.STIM_FREQ;
    
    % Basic Stimulus Settings
    Settings.WN_STIM_RES_UM = 50;% Resolution of surround stim in um (micrometers)
    Settings.WN_STIM_RES_PX = round(Settings.WN_STIM_RES_UM/UM_TO_PIX_CONV); % Resolution of surround stim in pix
    
    Settings.Settings.CHECKER_COUNT_DIMS = round([900 900]/Settings.WN_STIM_RES_UM); % must adjust side length to be a ...
    ...multiple of the checker square size
        
% Dimensions of central stimulus in microns
Settings.WN_DIMS_PX = round(([Settings.WN_DIMS_UM ])/UM_TO_PIX_CONV); %height and width of center stim in pix;
Settings.WN_EDGE_LENGTH = Settings.CHECKER_COUNT_DIMS*Settings.WN_STIM_RES_PX;%in pix

% CENTER STIM
Settings.WN_STIM_LOC = round([Settings.WN_DIMS_PX]/2); % center stim location in window

% PRESENTATION
Settings.STIM_FREQ = 25; % Hz for presentation rate
Settings.STIM_DUR = 45*60; % Duration of stimulus (seconds)
Settings.SURR_DIMS = round(([900 900 ])/UM_TO_PIX_CONV); %height and width of surround;

Settings.N_REPEATS = 1;
Settings.N_FRAMES = Settings.STIM_DUR*Settings.STIM_FREQ;

% save meta data & stim frames
dirName = '';
save(fullfile(dirName,Settings.STIM_NAME),'Settings',...
    'StimMats');
%write-protect file
eval(['!chmod a-w ',fullfile(dirName,Settings.STIM_NAME)]);
end
