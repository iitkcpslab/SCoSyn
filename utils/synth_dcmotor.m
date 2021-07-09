%% Interface Automatic Transmission model with Breach 

 

function [phi,rob] = synth_dcmotor(newfile,phi)
    %% Initialize Variables
    
    J = 0.01;
    b = 0.1;
    K = 0.01;
    R = 1;
    L = 0.5;


    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");

    B.SetTime(0:.01:10); % default simulation time

    sg = var_step_signal_gen({'Voltage'},3);

    B.SetInputGen(sg);                
    %B.SetParam({'Zref_u0','Zref_u1','Zref_u2'},...
     %                    [10;  10;  10 ]);

    %B.SetParamRanges({'Force_u0'}, ...
    %                  [900 1000]);      
    B.SetParam({'Voltage_dt0','Voltage_dt1','Voltage_dt2'}, [3; 4 ;3]);        
    B.SetParamRanges({'Voltage_u0','Voltage_u1','Voltage_u2'}, ...
                      [0.8 1; 0.8 1; 0.8 1]);               

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
%         BrFalse = falsif_pb.GetBrSet_False();
%         BrFalse=BrFalse.BrSet;
% 
% 
%      BrFalse.PlotSigPortrait('theta');
%      BrFalse.PlotRobustSat(phi);
