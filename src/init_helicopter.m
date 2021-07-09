%% Multiloop Control of a Helicopter
% This example shows how to use |slTuner| and |systune| to tune 
% a multiloop controller for a rotorcraft.
 
%   Copyright 1986-2015 The MathWorks, Inc.

%% Helicopter Model
% This example uses an 8-state helicopter model
% at the hovering trim condition. The state vector
% |x = [u,w,q,theta,v,p,phi,r]| consists of 
%
% * Longitudinal velocity |u| (m/s)
% * Lateral velocity |v| (m/s)
% * Normal velocity |w| (m/s)
% * Pitch angle |theta| (deg)
% * Roll angle |phi| (deg)
% * Roll rate |p| (deg/s)
% * Pitch rate  |q| (deg/s)
% * Yaw rate |r| (deg/s).
% 
% The controller generates commands |ds,dc,dT| in degrees for the longitudinal cyclic, 
% lateral cyclic, and tail rotor collective using measurements
% of |theta|, |phi|, |p|, |q|, and |r|. 
%%
% The control system consists of two feedback loops. The inner loop (static output 
% feedback) provides stability augmentation and decoupling.
% The outer loop (PI controllers) provides the desired setpoint tracking performance.
% The main control objectives are as follows:
%
% * Track setpoint changes in |theta|, |phi|, and |r| with zero steady-state error,
%   rise times of about 2 seconds, minimal overshoot, and minimal cross-coupling
% * Limit the control bandwidth to guard against neglected high-frequency rotor
%   dynamics and measurement noise 
% * Provide strong multivariable gain and phase margins (robustness to simultaneous
%   gain/phase variations at the plant inputs and outputs, see |diskmargin| for details).
%
% We use lowpass filters with cutoff at 40 rad/s to partially enforce the second objective.

function [phi,rob,BrFalse] = init_helicopter(newfile,specno,mode)
    %addpath config_robotarm;
    %warning('off');
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");
   
     
    %define the formula
    %STL_ReadFile('stl/mimo_specs.stl');
    %phi_s = STL_Formula('phi_s', 'alw_[2,10] ( (abs(theta[t+dt]-theta[t]) < epsi1) and (abs(phi[t+dt]-phi[t]) < epsi1) and (abs(r[t+dt]-r[t]) < epsi1) )');
    phi_s = STL_Formula('phi_s', 'alw_[1,10] (abs(theta[t+dt]-theta[t]) < epsi1)');
    phi_s = set_params(phi_s,{'dt', 'epsi1'}, [0.1 0.01]);
    phi_r = STL_Formula('phi_r', 'ev_[0,tau1] ((theta > theta_ref[t]*bt) and (phi[t] > phi_ref[t]*bt) and (r[t] > r_ref[t]*bt) )');
    phi_r = set_params(phi_r,{'tau1', 'bt'}, [1 0.75]);  
    
    phi_c = STL_Formula('phi_c', 'ev_[0,tau2] alw ((abs(tAngle[t]-tREF[t]) < epsi2) and (abs(bAngle[t]-bREF[t]) < epsi2) and (abs(fAngle[t]-fREF[t]) < epsi2) and (abs(wAngle[t]-wREF[t]) < epsi2) and (abs(hAngle[t]-hREF[t]) < epsi2) and (abs(gAngle[t]-gREF[t]) < epsi2))');
    phi_c = set_params(phi_c,{'tau2', 'epsi2'}, [3 0.1]);

    phi_o = STL_Formula('phi_o', 'alw ((tAngle[t] < al*tREF[t]) and (bAngle[t] < al*bREF[t]) and (fAngle[t] < al*fREF[t]) and (wAngle[t] < al*wREF[t]) and (hAngle[t] < al*hREF[t]) and (gAngle[t] < al*gREF[t]))');
    phi_o = set_params(phi_o,{'al'}, [1.3]);
    %phi_sp = STL_Formula('phi_sp', 'alw ((not(((Z[t+dt]-Z[t])*10 > m) and ev_[0,tau] ((Z[t+dt]-Z[t])*10 < -1*m))) and (not(((X[t+dt]-X[t])*10 > m) and ev_[0,tau] ((X[t+dt]-X[t])*10 < -1*m))) and (not(((Y[t+dt]-Y[t])*10 > m) and ev_[0,tau] ((Y[t+dt]-Y[t])*10 < -1*m))))');
    %phi_sp = set_params(phi_sp,{'tau', 'dt','m'}, [10 0.1 0.5]);
    
    phi_all = STL_Formula('phi_all', '(phi_s and phi_r and phi_c and phi_o)');
    phi_all = set_params(phi_all,{'dt','epsi1','tau1','bt','tau2','epsi2','al'}, [0.1 0.1 2.3 0.8 10 .1 1.25]);
    
    if specno==1
      phi=phi_s;
    elseif specno==2
      phi=phi_r;
    elseif specno==3
      phi=phi_c;
    elseif specno==4
      phi=phi_o;
    %elseif specno==5
    %  phi=phi_sp;
    elseif specno==6
      phi=phi_all;  
    end
    %phi=phi_spike;

    % Turntable = 0 deg, Bicep = 60 deg, Forearm = 90 deg, Wrist = 0 deg,
    % Hand = 90 deg, and Gripper = 60 deg.
    B.SetTime(0:.01:10);
    x_gen = var_step_signal_gen({'theta_ref','phi_ref','r_ref'});

    B.SetInputGen(x_gen);                
    B.SetParam({'dt_u0'}, ...
                       [10;]);     
    B.SetParamRanges({'theta_ref_u0'}, ...
                      [0.1 3;]);
    B.SetParamRanges({'phi_ref_u0'}, ...
                      [0.1 3;]); 
    B.SetParamRanges({'r_ref_u0'}, ...
                      [0.1 3;]);
    
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
