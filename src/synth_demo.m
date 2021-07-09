%% Interface quadcopter model with Breach 

%% Initialize Variables
%quad_variables;

function [phi,rob] = init_f14(newfile,phi)

    
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");


    B.SetTime(0:.1:60); % default simulation time

    sg = var_step_signal_gen({'stick'});

    B.SetInputGen(sg);                
    
    B.SetParam({'dt_u0'}, ...
                       [60]);  
    B.SetParamRanges({'stick_u0'}, ...
                      [-1 1;]);                 
    

    %falsif_pb = FalsificationProblem(B, phi,falsif_params.names,falsif_params.ranges);
    %falsif_pb = FalsificationProblem(B,phi);
    
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
% 
%      BrFalse = falsif_pb.GetBrSet_False();
%      BrFalse=BrFalse.BrSet;
%      BrFalse.PlotRobustSat(phi);
end