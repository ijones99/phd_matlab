
N=10;
TIME=.5;
repetitions=2;
background_fixed=164;
save_recording=0;
FPS       = 60;   % FramePerSecond. This is the frequency of the projector. In Hz; You should not need to change this
Scaling   = 1.75; % Scaling. Micrometer per pixel. One Pixel corresponds to 1.75 micormeter

parapin(0);

whichScreen = 0;
window = Screen(whichScreen, 'OpenWindow');

%white = WhiteIndex(window); % pixel value for white
black = BlackIndex(window); % pixel value for black

Screen(window, 'FillRect', black);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,[0,1,1,0]);
%c = 1 %red
%c = 2 %green
%c = 3 %blu
% : white

m = zeros(600,600, 3);
%m(:,:,1) = 1;
m(:,:,2) = 1;
m(:,:,3) =  1;
%m(1:300,1:300,:)=0;
color=m*background_fixed;

Screen(window, 'PutImage', color);
Screen(window, 'Flip');

m = zeros(600,600, 3);
m(:,:,2) = 1;
m(:,:,3) = 1;
color=m * 255;

n = zeros(600,600, 3);
n(:,:,2) = 1;
n(:,:,3) = 1;
colorr=n * 1;

w(1)=Screen(window, 'MakeTexture', color);
w(2)=Screen(window, 'MakeTexture', colorr);
w(3)=Screen(window, 'MakeTexture', color);
w(4)=Screen(window, 'MakeTexture', colorr);
w(5)=Screen(window, 'MakeTexture', color);
w(6)=Screen(window, 'MakeTexture', colorr);
w(7)=Screen(window, 'MakeTexture', color);
w(8)=Screen(window, 'MakeTexture', colorr);
w(9)=Screen(window, 'MakeTexture', color);
w(10)=Screen(window, 'MakeTexture', colorr);

window_size = 200;% window side in um 300 600 1000

for jjj=1:repetitions

    pause(2);
    if window_size<650
        beep %window position
        sel_static_position=str2num(input('type config number: ','s'));
    end

    if save_recording
        hidens_startSaving(1,'bs-hpws03')
        pause(3)
    end
    seq_win_center_positions=[-86 -28 28 86 ];
    
    for j=1:length(seq_win_center_positions)
        % MASK
        static_position_vector=[0,1,2,3,4];
        idx_block=find(static_position_vector==sel_static_position);
        block_width=100;    %6x17 block width in um
        static_offsets_vector=[-2 -1 0 1 2];
        offset_window_heightPx=round(block_width/Scaling)*static_offsets_vector(idx_block);
     
        window_center=301; %center on y axis
%         horizontal movement
        j1=(window_center-round(window_size/Scaling/2))+seq_win_center_positions(j);
        j2=(window_center+round(window_size/Scaling/2))+seq_win_center_positions(j);

        i1=(window_center-(round(window_size/Scaling/2)))+offset_window_heightPx;
        i2=(window_center+(round(window_size/Scaling/2)))+offset_window_heightPx;

        mask=ones(600,600,2)*background_fixed;
        mask(:,:,2)=255;
        if window_size<650
            mask(i1:i2,j1:j2,2)=0;
        end
        if window_size>650
            i1=1;
            i2=599;
            j1=1;
            j2=599;
            mask(i1:i2,j1:j2,2)=0;
        end
        masktex=Screen('MakeTexture', window, mask);
        for i = 1:N
            Screen(window, 'DrawTexture', w(i));
            Screen('DrawTexture', window, masktex);
            parapin(6);
            Screen(window,'Flip');
            parapin(4);
            pause(TIME)
            i
        end
        parapin(0);
        m = zeros(600,600, 3);
        m(:,:,2) = 1;
        m(:,:,3) =  1;
        color=m*background_fixed;
        Screen(window, 'PutImage', color);
        Screen(window, 'Flip');
        pause(5)
    end
    if save_recording
        pause(3)
        hidens_stopSaving(1,'bs-hpws03')
    end
end
parapin(0);
pause(2);

KbWait;
Screen('CloseAll');
