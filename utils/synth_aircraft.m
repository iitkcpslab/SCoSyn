%% Interface Automatic Transmission model with Breach 


function [phi,rob] = synth_aircraft(newfile,phi)

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
    
    
 %BrFalse.PlotSigPortrait('theta');
 %BrFalse.PlotRobustSat(phi);