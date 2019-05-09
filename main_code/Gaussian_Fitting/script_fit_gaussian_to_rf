[xi,yi] = meshgrid(-10:10,-20:20);
zi = exp(-(xi-3).^2-(yi+4).^2) + randn(size(xi))*.1;
results = autoGaussianSurf(xi,yi,zi)
figure, hold on
subplot(2,1,1)
imagesc(zi), axis square
subplot(2,1,2), 
imagesc(results.G), axis square

%%
[xi,yi] = meshgrid(1:30,1:30);
% zi = exp(-(xi-3).^2-(yi+4).^2) + randn(size(xi))*.1;

% remove avg
bestSTAIm = double(bestSTAIm);
zi = max(max(bestSTAIm))-bestSTAIm;
avgVal = mean(mean(zi))*1.2;

zi(find(zi<avgVal)) = 0;
results = autoGaussianSurf(xi,yi,zi)
figure, hold on
subplot(2,1,1)
imagesc(zi), axis square
subplot(2,1,2),
imagesc((results.G)), axis square
%
p = calculateEllipse(results.x0, results.y0, results.sigmax, results.sigmay, results.angle*180/(pi));
figure(h), plot(p(:,1), p(:,2)), axis equal