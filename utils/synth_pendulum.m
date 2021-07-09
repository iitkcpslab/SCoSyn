%% Interface Automatic Transmission model with Breach 


function [phi,rob] = synth_pendulum(newfile,phi)
    %% Initialize Variables
    M = 0.5;
    m = 0.2;
    b = 0.1;
    I = 0.006;
    g = 9.8;
    l = 0.3;

    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");

    B.SetTime(0:.01:2); % default simulation time

    sg = var_step_signal_gen({'Force'},2);

    B.SetInputGen(sg);                
    %B.SetParam({'Zref_u0','Zref_u1','Zref_u2'},...
     %                    [10;  10;  10 ]);

    %B.SetParamRanges({'Force_u0'}, ...
    %                  [900 1000]); 

    B.SetParam({'dt_u0','dt_u1'}, ...
                       [0.01; 1.99]); 
    %B.SetParam({'Force_dt0','Force_dt1','Force_dt2'}, [1.4; 0.2 ;1.4]);        
    B.SetParamRanges({'Force_u0','Force_u1'}, ...
                      [900 1000; 0 0.1]);               

    %B.Sim(0:.01:30); % Run Simulink simulation until time=30s 
    %B.PlotSignals(); % plots the signals collected after the simulation


    disp("synthesis");  
    disp(get_params(phi));
    falsif_pb = FalsificationProblem(B,phi);
    falsif_pb.max_time = 180;
    falsif_pb.solve();
     rob=falsif_pb.obj_best;
     if rob>=0
         BrFalse='';
         return;
     end
 end