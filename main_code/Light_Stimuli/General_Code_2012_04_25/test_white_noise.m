expanded_frame1 =   (kron(saved_frames(:,:,i),ones(Num_Pixels_Per_Square)));
  expanded_frame1(find(expanded_frame1==0)) = .50-.05;
  expanded_frame1(find(expanded_frame1==1)) = .50+.30;
  
  w = Screen(window, 'MakeTexture',  Black+White*expanded_frame1 );  
  
  function test3 
Screen('CloseAll') 
whichScreen = 0;
window = Screen(whichScreen, 'OpenWindow');

white = WhiteIndex(window); % pixel value for white
black = BlackIndex(window); % pixel value for black
gray = (white+black)/2;
inc = white-gray;
Screen(window, 'FillRect', black);
tic
for i=1:60
    m=zeros(400,400, 3);
    m(:,:,2)=rand(400);
    
    m(:,:,3)=m(:,:,2);

    w(i) = Screen(window, 'MakeTexture', gray+inc*m);
  
end
toc
% for i = 1:100
%     Screen('DrawTexture', window, w(i));
%     Screen(window,'Flip');
% end


KbWait;
Screen('CloseAll');

end