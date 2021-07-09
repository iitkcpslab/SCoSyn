
M = csvread('dataset.csv');
x=M(:,1);
y=M(:,2);
z=M(:,3);
v=M(:,4).*(-1);
m=size(x);
scatter3(x,y,z,m,v,'filled');
%surf(x,y,z,v);

