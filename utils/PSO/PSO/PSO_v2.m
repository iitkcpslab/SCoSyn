function [bestX,bestFitness,bestFitnessEvolution,nEval]=PSO_v2(options)
%--------------------------------------------------------------------------
% Author: Dr Bouchekara Houssem Rafik El-Hana
% Date: 26/05/2015
% PSO version 2 with velocity bounding
%--------------------------------------------------------------------------
% References 
% Smail, M. K., Bouchekara, H. R. E. H., Pichon, L., Boudjefdjouf, H., &
% Mehasni, R. (2014). Diagnosis of wiring networks using Particle Swarm
% Optimization and Genetic Algorithms. Computers & Electrical Engineering.
% doi:10.1016/j.compeleceng.2014.07.002
%--------------------------------------------------------------------------
bestFitnessEvolution=[];
nEval=0;
%--------------------------------------------------------------------------
ProblemSize=options.ProblemSize;
PopulationSize=options.PopulationSize;
minPosition=options.minPosition;
maxPosition=options.maxPosition;
MaxIter=options.MaxIter;
ObjFunction=options.ObjFunction;
c1=options.c1;
c2=options.c2;
w=options.w;
d=abs(maxPosition-minPosition);
Pposition=zeros(PopulationSize,ProblemSize);
Pvelocity=rand(PopulationSize,ProblemSize);

for i=1:ProblemSize
    Pposition(:,i)=minPosition(i)+rand(PopulationSize,1)*(maxPosition(i)-minPosition(i));
    Pvelocity(:,i)=-d(i)+2*rand(PopulationSize,1)*d(i);
end

P_cost=feval(ObjFunction,Pposition);
nEval=nEval+length(P_cost);
% The ith particle's best known position
Pp_best_cost=P_cost;
Pp_best=Pposition;
% Is the best position known to the swarm
[Pg_best_cost, indexmin]=min(P_cost);
Pg_best=Pp_best(indexmin,:);

Pg_best_evolution=zeros(MaxIter,ProblemSize);
% bestFitnessEvolution=zeros(MaxIter,1);

for k=1:MaxIter
    %     tic
    for i=1:PopulationSize
        % Update Velocity
        Pvelocity(i,:)=w*Pvelocity(i,:)+...
            (c1*rand*(Pp_best(i,:)-Pposition(i,:)))+ ...
            (c2*rand*(Pg_best-Pposition(i,:)));
        [Pvelocity]=bound(Pvelocity,-d,d);
        
        % Update Position
        Pposition(i,:)=Pposition(i,:)+Pvelocity(i,:);
        [Pposition]=bound(Pposition,minPosition,maxPosition);
        
        P_cost(i)=feval(ObjFunction,Pposition(i,:));
        nEval=nEval+1;
        if P_cost(i)<=Pp_best_cost(i)
            Pp_best(i,:)=Pposition(i,:);
            Pp_best_cost(i)=P_cost(i);
            if P_cost(i)<=Pg_best_cost
                Pg_best=Pposition(i,:);
                Pg_best_cost=P_cost(i);
            end
        end
    end
    %----------------------------------------------------------------------
    bestFitnessEvolution(k)=Pg_best_cost;    
    %--------------------------------------------------------------------------------
    if options.Display_Flag==1
        fprintf('Iteration N° is %g Best Fitness is %g\n',k,Pg_best_cost)
    end
    
end
    bestX=Pg_best;
    bestFitness=Pg_best_cost;
end
function [x]=bound(x,l,u)
for j = 1:size(x,1)
    x(j,x(j,:)<l)=l(x(j,:)<l);
    x(j,x(j,:)>u)=u(x(j,:)>u);
    %     x(j,find(x(j,:)<l))=l(find(x(j,:)<l))+rand*(l(find(x(j,:)<l))+u(find(x(j,:)<l)))/2;
    %     x(j,find(x(j,:)>u))=l(find(x(j,:)>u))+rand*(l(find(x(j,:)>u))+u(find(x(j,:)>u)))/2;
end
end



