clear all
clc
close all

d=5;                % dimension
options.minPosition=-32*ones(1,d);   % lower bound
options.maxPosition=32*ones(1,d);    % upper bound
options.PopulationSize=50; % Size of the population
options.MaxIter=100; % Maximum number of iterations
options.ProblemSize=length(options.maxPosition);    % dimension of the problem.
options.w=0.5 ;
options.c1=1.5  ;
options.c2=1.5;
options.ObjFunction=@Ackley; % the name of the objective function
options.Display_Flag=1; % Flag for displaying results over iterations
options.run_parallel_index=0; % to run the different runs in parallel 
options.run=10; % number of runs

tic
if options.run_parallel_index
    stream = RandStream('mrg32k3a');
    parfor index=1:options.run
        %         index
        set(stream,'Substream',index);
        RandStream.setGlobalStream(stream)
        [bestX,bestFitness,bestFitnessEvolution,nEval]=PSO_v2(options);
        bestX_M(index,:)=bestX;
        Fbest_M(index)=bestFitness;
        fbest_evolution_M(index,:)=bestFitnessEvolution;
    end
else
    rng('default')
    for index=1:options.run
        %         index
        [bestX,bestFitness,bestFitnessEvolution,nEval]=PSO_v2(options);
        bestX_M(index,:)=bestX;
        Fbest_M(index)=bestFitness;
        fbest_evolution_M(index,:)=bestFitnessEvolution;
    end
end
toc
[a,b]=min(Fbest_M);
figure
plot(1:options.MaxIter,fbest_evolution_M(b,:))
xlabel('Iterations')
ylabel('Fitness')

fprintf(' MIN=%g  MEAN=%g  MEDIAN=%g MAX=%g  SD=%g \n',...
    min(Fbest_M),mean(Fbest_M),median(Fbest_M),max(Fbest_M),std(Fbest_M))