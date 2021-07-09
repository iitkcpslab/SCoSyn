%{
x=[1 2 3 4 5 6 7];
y=[1.139 0.5711 0.1407 0.025 0.0028 0.0006 0.0005];
plot(x,y,'r','Marker','*','LineWidth',3)
hold on
y%=[1.6205 0.5787 0.1897 0.0313 0.0030 0.0012 0.0006];
plot(x,y,'b','Marker','*','LineWidth',3)
ylabel('Singular Value')
xlabel('index')
%}

x=[6.28 5.02 4.01 3.21 2.57 2.05 1.64 1.31 1.05 0.84 6.90];
y=[-268.27 -1070.67 -1500 -1500 -1500 -1500 -1500 -1500 -1500 -1500 48];
plot(x,y,'r','Marker','*','LineWidth',3)
hold on
x=[6.90 5.52 4.42 3.53];
y=[-1 -1 -1 1];
plot(x,y,'b','Marker','o','LineWidth',3)
ylabel('Robustness')
xlabel('Parameter values')
