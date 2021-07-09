modelno=4;
specno=6;

    if modelno==3
        newfile='Quad_sim';
    elseif modelno==4
        newfile='Aircraft_Pitch';
    elseif modelno==1
        newfile='model';
    elseif modelno==2
        newfile='cruise_ctrl';
    elseif modelno==5
        newfile='Inverted_Pendulum';
    elseif modelno==6
        newfile='DCMotor';
    elseif modelno==7
        newfile='suspmod';
    end

   init_values;
   %STL_ReadFile('stl/aircraft_specs.stl');
   phi=phi_all; 
   mmr=[0.1 10; 0.1 10; 0.1 10];
   %pval=[1.2.5];
   echo off;
   diary mypsolog.out;
   pval_best=Particle_Swarm_Optimization(20, 3, mmr, @objfunc , 'max',2, 2, 2, 0.4, 0.9, 20);
   diary off;