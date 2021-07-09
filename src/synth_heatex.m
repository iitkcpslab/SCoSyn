%% Temperature Control in a Heat Exchanger
% This example shows how to design feedback and feedforward compensators
% to regulate the temperature of a chemical reactor through a heat
% exchanger.

%   Copyright 1986-2012 The MathWorks, Inc.

%% Heat Exchanger Process
% A chemical reactor called "stirring tank" is depicted below. The top inlet
% delivers liquid to be mixed in the tank. The tank liquid must be 
% maintained at a constant temperature by varying the amount of
% steam supplied to the heat exchanger (bottom pipe) via its control valve. 
% Variations in the temperature of the inlet flow are the main source
% of disturbances in this process.
%

function [phi,rob] = synth_heatex(newfile,phi)
    
    B = BreachSimulinkSystem(newfile);
    
    B.SetTime(0:.01:200);
    x_gen = var_step_signal_gen({'setp','dis'});

    B.SetInputGen(x_gen);                
    B.SetParam({'dt_u0'}, ...
                       [200;]);     
    B.SetParamRanges({'dis_u0'}, ...
                      [-1 0;]);
    B.SetParamRanges({'setp_u0'}, ...
                      [0 2;]); 
    
    disp("synthesis");  
    disp(get_params(phi));
    falsif_pb = FalsificationProblem(B,phi);
   
    disp(phi)
    falsif_pb.max_time = 180;
    falsif_pb.solve();
    rob=falsif_pb.obj_best;
    if rob>=0
         BrFalse='';
         return;
    end
    
end
