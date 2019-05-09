
fileName = 'arrows_deg_135'

a = imread(['/tmp/', fileName],'jpg');
figure, subplot(2,2,1), imagesc(a),title('original');colormap gray

aMod = beamer.array2beamer_mat_adjustment(a);
subplot(2,2,2), imagesc(aMod),title('on chip');

aModMod = beamer.array2beamer_mat_adjustment(aMod);
subplot(2,2,3), imagesc(aModMod), title('on screen again');