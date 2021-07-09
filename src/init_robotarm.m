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

function [phi,rob,BrFalse] = init_robotarm(newfile,specno,mode)
    addpath config_robotarm;
    %warning('off');
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");

    %define the formula
    %STL_ReadFile('stl/mimo_specs.stl');
    phi_s = STL_Formula('phi_s', 'alw_[4,20] ((abs(theta2m[t+dt]-theta2m[t]) < epsi1) and (abs(theta3m[t+dt]-theta3m[t]) < epsi1))');
    phi_s = set_params(phi_s,{'dt', 'epsi1'}, [0.1 0.05]);
    
    phi_r = STL_Formula('phi_r', 'ev_[0,tau1] ((theta2m[t] > theta2md[t]*bt) and (theta3m[t] > theta3md[t]*bt))');
    phi_r = set_params(phi_r,{'tau1', 'bt'}, [0.1 0.85]);  
    
    phi_c = STL_Formula('phi_c', 'ev_[0,tau2] alw ((abs(theta2m[t]-theta2md[t]) < epsi2) and (abs(theta3m[t]-theta3md[t]) < epsi2))');
    phi_c = set_params(phi_c,{'tau2', 'epsi2'}, [4 0.1]);

    phi_o = STL_Formula('phi_o', 'alw ((theta2m[t] < al*theta2md[t]) and (theta3m[t] < al*theta3md[t]))');
    phi_o = set_params(phi_o,{'al'}, [2.3]);
    
    phi_sp = STL_Formula('phi_sp', 'alw ((not(((theta2m[t+dt2]-theta2m[t])*10 > m) and ev_[0,tau3] ((theta2m[t+dt2]-theta2m[t])*10 < -1*m))) and (not(((theta3m[t+dt2]-theta3m[t])*10 > m) and ev_[0,tau3] ((theta3m[t+dt2]-theta3m[t])*10 < -1*m))) )');
    phi_sp = set_params(phi_sp,{'tau3', 'dt2','m'}, [2 0.1 12]);
    
    phi_all = STL_Formula('phi_all', '(phi_s and phi_c and  phi_o and phi_sp)');
    phi_all = set_params(phi_all,{'dt','epsi1','tau2','epsi2','al','tau3','dt2','m'}, [0.1 0.05  4 0.1 2.2 2 0.1 12]);
    
    %phi_ra = STL_Formula('phi_ra', '(not (phi_s) until phi_c)');
    %phi_ra = set_params(phi_ra,{'dt','epsi1','tau2','epsi2'}, [0.1 0.01  6 0.1]);
    %phi_ra = set_params(phi_ra,{'dt','epsi1','tau2','epsi2'}, [0.1 0.02  4 0.1]);
    phi_ra = STL_Formula('phi_ra', '( (((theta2m[t] < al*theta2md[t]) and (theta3m[t] < al*theta3md[t])) ) until_[0,tau2]  (alw ((abs(theta2m[t]-theta2md[t]) < epsi2) and (abs(theta3m[t]-theta3md[t]) < epsi2))) )');
    %phi_ra = set_params(phi_ra,{'al','tau2','epsi2'}, [2.4 4 0.1]); % 1
    %1 iters 75.0000    2.0000    0.5000   50.0000    1.0000    2.0000
    phi_ra = set_params(phi_ra,{'al','tau2','epsi2'}, [2.4 4 0.1]);
    
    if specno==1
      phi=phi_s;
    elseif specno==2
      phi=phi_r;
    elseif specno==3
      phi=phi_c;
    elseif specno==4
      phi=phi_o;
    elseif specno==5
      phi=phi_sp;
    elseif specno==6
      phi=phi_all;  
    elseif specno==7
      phi=phi_ra;    
    end
    %phi=phi_spike;

    % Turntable = 0 deg, Bicep = 60 deg, Forearm = 90 deg, Wrist = 0 deg,
    % Hand = 90 deg, and Gripper = 60 deg.
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

    if mode==1  % falsification mode
       %disp("falsify");
       %disp(phi);
       falsif_pb = FalsificationProblem(B,phi);
    elseif mode==2  %synthesis mode
       %disp("synthesis");  
       %disp(get_params(phi_mod));
       falsif_pb = FalsificationProblem(B,phi_mod);
    end   
    falsif_pb.max_time = 180;
    falsif_pb.solve();
    rob=falsif_pb.obj_best;
    if rob>=0
         BrFalse='';
         return;
    end
    
    BrFalse = falsif_pb.GetBrSet_False();
    BrFalse=BrFalse.BrSet; 
    BrFalse.PlotRobustSat(phi);
   end
