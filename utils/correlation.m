N=M;
for m1 = 1:size(N,2); % Create correlations for each experimenter
 for m2 = 1:size(N,2); % Correlate against each experimenter
  Cor(m2,m1) = corr(N(:,m1),N(:,m2));
 end
end

R = corrcoef(N); 
rR = round(R,2);
h = heatmap(rR);