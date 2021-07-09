modelno=4;
specno=6;

mmr=[0.1 10; 0.1 10; 0.1 10];
pval_best=Particle_Swarm_Optimization(20, 3, mmr, objfunc(4,6), 'min',2, 2, 2, 0.4, 0.9, 10);
