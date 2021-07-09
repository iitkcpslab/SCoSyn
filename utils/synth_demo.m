%% Interface Automatic Transmission model with Breach 

%% Initialize Variables


function [phi,rob] = synth_demo(newfile,phi)
    B = BreachSimulinkSystem(newfile);
   
    B.SetTime(0:.2:2); % default simulation time

    sg = var_step_signal_gen({'a_adv'});

    B.SetInputGen(sg);             

    B.SetParam({'dt_u0'}, ...
                       [2]);
    %B.SetParamRanges({'ref_u0'}, ...
    %                  [2.1 2.2;]); %demo1 
    B.SetParamRanges({'a_adv_u0'}, ...
                      [0.90 1.01;]); % demo2
    %B.SetParamRanges({'a_adv_u0'}, ...
    %                  [0 1.22;]); %for demo3                 
    

    %disp("synthesis");  
    %disp(get_params(phi_mod));
    falsif_pb = FalsificationProblem(B,phi);
    falsif_pb.max_time = 180;
    falsif_pb.solve();
    rob=falsif_pb.obj_best;
     if rob>=0
         BrFalse='';
         return;
     end
end

% 
% 
%      BrFalse.PlotSigPortrait('speed');
%      BrFalse.PlotRobustSat(phi);
