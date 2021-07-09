
function [phi,rob] = synth_airframe(newfile,phi)
    %addpath config_robotarm;
    %warning('off');
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");
   
    B.SetTime(0:.01:20);
    x_gen = var_step_signal_gen({'az_ref'});

    B.SetInputGen(x_gen);                
    B.SetParam({'dt_u0'}, ...
                       [20;]);     
    B.SetParamRanges({'az_ref_u0'}, ...
                      [180 200;]);
    
       disp("synthesis");  
       disp(get_params(phi));
       falsif_pb = FalsificationProblem(B,phi);

    %disp(phi)
    falsif_pb.max_time = 180;
    falsif_pb.solve();
    rob=falsif_pb.obj_best;
    if rob>=0
         BrFalse='';
         return;
    end
   end
