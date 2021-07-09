%% Interface Automatic Transmission model with Breach 

%addpath utilities
%% Initialize Variables
%% Robotic Arm Model and Controller
% This example uses the six degree-of-freedom robotic arm shown below. 
% This arm consists of six joints labeled from base to tip:
% "Turntable", "Bicep", "Forearm", "Wrist", "Hand", and "Gripper".
% Each joint is actuated by a DC motor except for the Bicep joint
% which uses two DC motors in tandem.

%
% *Figure 3: Controller structure.*
%
% Typically, such multi-loop controllers are tuned sequentially by tuning 
% one PID loop at a time and cycling through the loops until the overall
% behavior is satisfactory. This process can be time consuming and is not
% guaranteed to converge to the best overall tuning. Alternatively, you can 
% use |systune| or |looptune| to jointly tune all six PI loops subject
% to system-level requirements such as response time and minimum cross-coupling.
%
% In this example, the arm must move to a particular configuration in
% about 1 second with smooth angular motion at each joint. The arm starts
% in a fully extended vertical position with all joint angles at zero except 
% for the Bicep angle at ninety degrees. 
% The end configuration is specified by the angular positions:
% Turntable = 0 deg, Bicep = 60 deg, Forearm = 90 deg, Wrist = 0 deg,
% Hand = 90 deg, and Gripper = 60 deg.
%
%Another[0,90,0,0,0,60]

function [phi,rob] = init_robotarm(newfile,phi)
    addpath config_robotarm;
    %warning('off');
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");

    B.SetTime(0:.01:20);
    %x_gen = var_step_signal_gen({'tREF','bREF','fREF','wREF','hREF','gREF'});
    x_gen = var_step_signal_gen({'theta2md','theta3md'});

    B.SetInputGen(x_gen);                
    B.SetParam({'dt_u0'}, ...
                       [20;]);     
    B.SetParamRanges({'theta2md_u0'}, ...
                      [0.9 1]);
    B.SetParamRanges({'theta3md_u0'}, ...
                      [0.9 1]);

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
