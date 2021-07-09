%clear all, close all, clc
addpath models;
addpath src;
addpath utils;

%{
dt = 0.001;
popsize = 25;
MaxGenerations = 10;
%K=[5;1;10];
population = [10*rand(popsize,1) 2*rand(popsize,1) 20*rand(popsize,1)]; 
options = optimoptions(@ga,'PlotFcn',{@gaplotbestf,@gaplotstopping},'PopulationSize',popsize,'MaxGenerations',MaxGenerations,'InitialPopulation',population,'OutputFcn',@myfun);
[x,fval] = ga(@(K)pidtest(K),3,-eye(3),zeros(3,1),[],[],[],[],[],options);
%}

diary mysa_an.log
tic
% lb = [0;0;0];
% % ub = [10;2;20];
% ub = [50;10;100];
fun = @pidtest;
%x0 = [5 1 10];   % Starting point
%x0 =[50 2 0.5 50 1 2];
%x0 = [0.5 0.1 1];
%x0 = [20 50 1.65];

% in our controller synthesis algorithm, we have limited search space
%  This assumption we follow here as well.
% This is important because the default values have been taken from standard sources
% and represent stable region for these controllers. Hence, our aim has
% been to synthesize controllers as close as possible to these regions that
% satisfy the set of specifications.

modelno=9;

if modelno==1
    quad_vars;
    x0 = [5 1 10];
    lb = [0.05 0.01 0.1];
    ub = [500 100 1000];
elseif modelno==2
    x0 = [0.5,0.1,1];
    lb = [0.005 0.001 0.01];
    ub = [50 10 100];
elseif modelno==3
    x0 = [0.495,0.348,0.115];
    lb = [0.049 0.034 0.011];
    ub = [49.5 34.8 1.15];
elseif modelno==4
    x0 = [41.76,65.58,3.87];
    lb = [0.004176,0.006558,0.0387];
    ub = [417.6,655.8,38.7];
 elseif modelno==5
    x0 = [20 50 1.65];
    lb = [0.2 0.5 0.165];
    ub = [200 500 16.5];
elseif modelno==6
    x0 = [-0.02233 -0.0297 -0.009821 -0.2843 4.81];
    lb = [-2.2 -2.9 -0.98 -28.43 0.048];
    ub = [-0.0002233 -0.000297 -0.00009821 -0.002843 481];
elseif modelno==11
    x0 = [-3.864 0.677 0.8156];
    lb = [-386.4 0.00677 0.008156];
    ub = [-0.03864 67.7 81.56];
 elseif modelno==14
    x0 = [0.00027507 2.7717622];
    lb = [0.0000027507 0.027717622];
    ub = [0.027507 27.717622];
  elseif modelno==7 
    init_vars;  
    x0 =[.1 0 -.1 .1 0 -.1 4 0 -4 4.5 0 0 4.5 0 0 10 0 0];
    lb=[.01 0 -1 .01 0 -1 0.4 0 -40 0.45 0 0 0.45 0 0 1 0 0];
    ub=[1 0 -.01 1 0 -.01 40 0 -0.4 45 0 0 45 0 0 100 0 0];
elseif  modelno==15
    x0 = [1 1];
    lb=[0.01 0.01];
    ub=[100 100];
elseif modelno==9
    x0 = [50 2 0.5 50 1 2];
    lb = [5 0.2 0.05 5 0.1 0.2];
    ub = [500 20 5 500 10 20];  
end
rng default % For reproducibility
[x,fval,exitFlag,output] = simulannealbnd(fun,x0,lb,ub);
%[x,fval,exitFlag,output] = simulannealbnd(fun,x0);

toc
disp("sa time")