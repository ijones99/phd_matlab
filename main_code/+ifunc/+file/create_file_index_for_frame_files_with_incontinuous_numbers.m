function fileInd = create_file_index_for_frame_files_with_incontinuous_numbers(...
    totalNumFrames, breakInterval, numDelFrames)

    numSegs = ceil(totalNumFrames/breakInterval);
    
    base = sort(repmat(0:numSegs-1,1,breakInterval-numDelFrames  ))*breakInterval;
    overlay = repmat(numDelFrames:breakInterval-1, 1,numSegs  );

    fileInd = base+overlay;
    
end