%% Interface Automatic Transmission model with Breach 

%addpath utilities
%% Initialize Variables

function [phi,rob,BrFalse] = init_walkingRobot(newfile,specno,mode)
    %addpath msra-walking-robot-master/ModelingSimulation;
    %warning('off');
    actuatorType = 2;
    addpath(genpath('LIPM'), ...                    % Linear inverted pendulum model (LIPM) files
        genpath('ModelingSimulation'), ...      % Modeling and simulation files
        genpath('Optimization'), ...            % Optimization files
        genpath('ControlDesign'), ...           % Control design files
        genpath('ReinforcementLearning'), ...   % Reinforcement learning files
        genpath('Libraries'));   
    robotParameters;
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");

    %define the formula
    %STL_ReadFile('stl/mimo_specs.stl');
    %phi_s = STL_Formula('phi_s', 'alw_[4,10] ((abs(tAngle[t+dt]-tAngle[t]) < epsi1) and (abs(bAngle[t+dt]-bAngle[t]) < epsi1) and (abs(fAngle[t+dt]-fAngle[t]) < epsi1) and (abs(wAngle[t+dt]-wAngle[t]) < epsi1) and (abs(hAngle[t+dt]-hAngle[t]) < epsi1) and (abs(gAngle[t+dt]-gAngle[t]) < epsi1))');
    phi_s = STL_Formula('phi_s', 'alw_[4,10] ((abs(measR[t+dt]-measR[t]) < epsi1) and (abs(measL[t+dt]-measL[t]) < epsi1))');
    phi_s = set_params(phi_s,{'dt', 'epsi1'}, [0.1 0.03]);
    phi_r = STL_Formula('phi_r', 'ev_[0,tau1] ((tAngle[t] > tREF[t]*bt) and (bAngle[t] > bREF[t]*bt) and (fAngle[t] > fREF[t]*bt) and (wAngle[t] > wREF[t]*bt) and (hAngle[t] > hREF[t]*bt) and (gAngle[t] > gREF[t]*bt))');
    phi_r = set_params(phi_r,{'tau1', 'bt'}, [1 0.75]);  
    
    phi_c = STL_Formula('phi_c', 'ev_[0,tau2] alw ((abs(tAngle[t]-tREF[t]) < epsi2) and (abs(bAngle[t]-bREF[t]) < epsi2) and (abs(fAngle[t]-fREF[t]) < epsi2) and (abs(hAngle[t]-hREF[t]) < epsi2) and (abs(gAngle[t]-gREF[t]) < epsi2))');
    phi_c = set_params(phi_c,{'tau2', 'epsi2'}, [4.5 1]);

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


    B.SetTime(0:.01:10);
    x_gen = var_step_signal_gen({'footR','footL'});

    B.SetInputGen(x_gen);                
    B.SetParam({'dt_u0'}, ...
                       [10;]);        
    B.SetParamRanges({'footR_u0'}, ...
                      [-1 1;]); 
    B.SetParamRanges({'foorL_u0'}, ...
                      [-1 1;]);
                  
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
    %BrFalse.PlotRobustSat(phi);
   end
