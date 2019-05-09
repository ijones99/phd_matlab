function projPointOnVector = project_points_onto_vector(points, projVector)
% projPointOnVector = PROJECT_POINTS_ONTO_VECTOR(points, projVector)

unityProjVector = projVector/norm(projVector);

if isrow(unityProjVector)
    unityProjVector = unityProjVector';
end

projPointOnVector = dotprod( points,unityProjVector);

end
%%
% figure, hold on
% scatter(points(:,1),points(:,2));
% plotUnityVector = [0 0; unityProjVector'];
% plot(plotUnityVector(:,1), plotUnityVector(:,2),'g');


%% 
% figure, axis square, hold on,xlim([0 10]);ylim([0 10])
% 
% % dots
% a = [0 0;...
%     5 3]
% plot(a(2,1), a(2,2),'ro','LineWidth', 2);
% 
% % vector
% b =  1.4142*[0 0;...
%     1 1];
% plot(b(:,1),b(:,2),'g')
% 
% % project onto vector
% 
% pa = dotprod([0 0;a],[0 0;b])
% plot(pa(2,1),pa(2,2),'co')
% 
