function guassianDistribution = make_gaussian_distribution(sigmal, stepSize, edgesNoStd)
% guassianDistribution = make_gaussian_distribution(sigmal, stepSize, edgesNoStd)

edges = [-edgesNoStd*sigma:stepSize:edgesNoStd*sigma] 		% Time ranges from -03 st. dev. to 3*st.dev.
kernel = normpdf(edges,0,sigma);   



end