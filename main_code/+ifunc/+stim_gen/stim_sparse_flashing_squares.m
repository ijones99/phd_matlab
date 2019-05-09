% script_create_dots_over_area_stimulus
Settings.OUTPUT_DIR = '/net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Light_Stimuli/Sparse_Flashing_Dots/';
Settings.EDGE_DIMS_PX = [750 750];
Settings.FRAME_RATE = 4;
Settings.TIME_MIN = 10;
Settings.TIME_SEC = Settings.TIME_MIN*60;
Settings.PERCENT_AREA_COVERED = 15;
Settings.SQR_SIZES_UM = [ 25 50 100 200 300 400 500];
Settings.SQR_SIZES_PX = round(Settings.SQR_SIZES_UM/1.6270);
Settings.UM_TO_PIX_CONV = 1.6270;
Settings.MID_GRAY_VAL = 156;


nFrames = Settings.TIME_SEC*Settings.FRAME_RATE;
sizesToRandomize = repmat(Settings.SQR_SIZES_PX,1,7*10);

selSizes = {};xCoord = {}; yCoord = {};brightness = [];



for i=1:nFrames
    frame = ones(Settings.EDGE_DIMS_PX)*Settings.MID_GRAY_VAL;
    randomInds = randperm(70);
    randSizes = sizesToRandomize(randomInds);
    cumSum = cumsum(randSizes);
    reachedMaxInd = find(cumSum > 500/1.6270,1)-1;
       
    selSizes{end+1} = randSizes(1:reachedMaxInd);
    xCoord{end+1} = round(rand(1,reachedMaxInd)*Settings.EDGE_DIMS_PX(2));
    yCoord{end+1} = round(rand(1,reachedMaxInd)*Settings.EDGE_DIMS_PX(1));
  
    brightness{end+1} = randi([0 1],[1 reachedMaxInd]);
    
    for j=1:reachedMaxInd
        
        inds = ifunc.shapes.get_square_inds(xCoord{end}(j), yCoord{end}(j), ...
            selSizes{end}(j), Settings.EDGE_DIMS_PX(1));
        frame(inds) = brightness{end}(j)*255;
     
    end
    frame = uint8(frame);
    save(fullfile(Settings.OUTPUT_DIR,sprintf('frame_%08d.mat',i)));
    i
    
end



