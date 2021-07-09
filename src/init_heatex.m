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

function [phi,rob,BrFalse] = init_heatex(newfile,specno,mode)
    %addpath config_robotarm;
    %warning('off');
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");
   
     
    %define the formula
    %STL_ReadFile('stl/mimo_specs.stl');
    phi_s = STL_Formula('phi_s', 'alw_[70,200] (abs(temp[t+dt]-temp[t]) < epsi1)');
    phi_s = set_params(phi_s,{'dt', 'epsi1'}, [0.1 0.001]);
    phi_r = STL_Formula('phi_r', 'ev_[0,tau1] ((temp[t] > setp[t]*bt) )');
    phi_r = set_params(phi_r,{'tau1', 'bt'}, [20 0.8]);  
    
    phi_c = STL_Formula('phi_c', 'ev_[0,tau2] alw (abs(temp[t]-setp[t]) < epsi2)');
    phi_c = set_params(phi_c,{'tau2', 'epsi2'}, [80 0.1]);

    phi_o = STL_Formula('phi_o', 'alw (temp[t] < al*(setp[t]))');
    phi_o = set_params(phi_o,{'al'}, [2]);
    phi_sp = STL_Formula('phi_sp', 'alw (not ( ((temp[t+dt2]-temp[t])*10 > m) and ev_[0,tau3] ((temp[t+dt2]-temp[t])*10 < -1*m) ) )');
    phi_sp = set_params(phi_sp,{'tau3', 'dt2','m'}, [3 0.1 0.01]);
    
    %phi_all = STL_Formula('phi_all', '(phi_s and phi_r and phi_c and phi_o and phi_sp)');
    phi_all = STL_Formula('phi_all', '(phi_s and phi_r and phi_c)');
    phi_all = set_params(phi_all,{'dt','epsi1','tau1','bt','tau2','epsi2','al','tau3', 'dt2','m'}, [0.1 0.001 20 0.8 80 0.1 2 3 0.1 0.01]);
    
    phi_ra = STL_Formula('phi_ra', '(not ((abs(temp[t+dt]-temp[t]) < epsi1)) until phi_c)');
    phi_ra = set_params(phi_ra,{'dt','epsi1','tau2','epsi2'}, [0.1 0.0001 80 0.1]);

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
    B.SetTime(0:.01:200);
    x_gen = var_step_signal_gen({'setp','dis'});

    B.SetInputGen(x_gen);                
    B.SetParam({'dt_u0'}, ...
                       [200;]);     
    B.SetParamRanges({'dis_u0'}, ...
                      [-1 0;]);
    B.SetParamRanges({'setp_u0'}, ...
                      [0 2;]); 
    
    if mode==1  % falsification mode
       %disp("falsify");
       %disp(phi);
       falsif_pb = FalsificationProblem(B,phi);
    elseif mode==2  %synthesis mode
       %disp("synthesis");  
       %disp(get_params(phi_mod));
       falsif_pb = FalsificationProblem(B,phi_mod);
    end   
    %disp(phi)
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
