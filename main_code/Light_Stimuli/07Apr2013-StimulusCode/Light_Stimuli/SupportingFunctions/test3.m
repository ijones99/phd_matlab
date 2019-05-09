function test3 
%%
Screen('CloseAll') 
whichScreen = 0;
window = Screen(whichScreen, 'OpenWindow');

white = WhiteIndex(window); % pixel value for white
black = BlackIndex(window); % pixel value for black
gray = (white+black)/2;
inc = white-gray;
Screen(window, 'FillRect', black);

for i=1:60
    m=zeros(400,400, 3);
    m(:,:,2)=rand(400);
    
    m(:,:,3)=m(:,:,2);

    w(i) = Screen(window, 'MakeTexture', gray+inc*m);
  
end

for i = 1:60
    Screen('DrawTexture', window, w(i));
    Screen(window,'Flip');
end


KbWait;
Screen('CloseAll');

end