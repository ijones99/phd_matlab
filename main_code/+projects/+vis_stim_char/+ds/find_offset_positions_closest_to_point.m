function closestOffset = find_offset_positions_closest_to_point(angleInTrue, offsetPos, relXYLoc)
% closestOffset = FIND_OFFSET_POSITIONS_CLOSEST_TO_POINT(angleInTrue, offsetPos, relXYLoc)
% 
% angleInTrue: "true" angle, which is then transposed to the angle seen on the
% screen (but not on the chip). Relevant functions are in +psychtoolbox and
% +beamer
%
%
%
%

closestOffset = nan(length(angleInTrue), 4);


% transpose angle from "true" angle to on-screen angle.
angleOut = psychtoolbox.angle_transfer_function(angleInTrue);
for iAngle = 1:length(angleOut)
    d = nan(1,length(offsetPos));
    for iOffset =1:length(offsetPos)
        
        % get vector for angle
        lineLen = 250;
        [X,Y] = pol2cart(angleOut(iAngle)*pi/180,lineLen );
        xyAngle(:,1) = [ 0 0 ];
        xyAngle(:,2) = [X Y];
        
        % offsetPos vector
        [X,Y] = pol2cart((angleOut(iAngle)+90)*pi/180,offsetPos(iOffset));
        xyAngle2(:,1) = [ X Y ];
        xyAngle2(:,2) = [X Y];
        
        xyOffset = xyAngle+xyAngle2;
        
        v1 = xyOffset(:,1)';
        v2 = xyOffset(:,2)';
        
        d(iOffset) = geometry.distance_point_to_line(relXYLoc, v1, v2);
    end
    
    [junk idxMinD] = min(d);
    
    closestOffset(iAngle,:) = [angleInTrue(iAngle) offsetPos(idxMinD) idxMinD d(idxMinD)];
    
end

end
