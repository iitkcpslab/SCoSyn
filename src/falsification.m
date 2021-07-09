%% Interface Automatic Transmission model with Breach 


newfile='Aircraft_Pitch';

B = BreachSimulinkSystem(newfile);
B.SetTime(0:.01:30); % default simulation time
sg = var_step_signal_gen({'theta_ref'});

B.SetInputGen(sg);                
%B.SetParam({'Zref_u0','Zref_u1','Zref_u2'},...
 %                    [10;  10;  10 ]);

B.SetParam({'dt_u0'}, ...
                   [30]);  
B.SetParamRanges({'theta_ref_u0'}, ...
                  [0.1 1;]); % note 0.1 radians=5.5 degrees (ref model page)  
              
%B.Sim(0:.01:30); % Run Simulink simulation until time=30s 
%B.PlotSignals(); % plots the signals collected after the simulation



%falsif_pb = FalsificationProblem(B, phi,falsif_params.names,falsif_params.ranges);
falsif_pb = FalsificationProblem(B,phi);
falsif_pb.max_time = 180;
falsif_pb.solve();
 if falsif_pb.obj_best>=0
     return;
 end

    BrFalse = falsif_pb.GetBrSet_False();
    BrFalse=BrFalse.BrSet;
    
    
 BrFalse.PlotSigPortrait('theta');
 BrFalse.PlotRobustSat(phi);