whichScreen = 0;
window = Screen(whichScreen, 'OpenWindow');

white = WhiteIndex(window); % pixel value for white
black = BlackIndex(window); % pixel value for black
gray = (white+black)/2;
inc = white-gray;
Screen(window, 'FillRect', black);
m=zeros(201,201,3,100);

for i=1:100
  m(:,50+i:100+i,2:3,i)=255;  
end

for i=1:100
Screen(window, 'PutImage', black+inc*m(:,:,:,i));
Screen(window, 'Flip');
end



KbWait;
Screen('CloseAll');