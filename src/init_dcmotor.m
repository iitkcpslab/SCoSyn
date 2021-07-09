%% Interface Automatic Transmission model with Breach 

   

function [phi,rob,BrFalse] = init_dcmotor(newfile,specno,mode)
    %% Initialize Variables
    
    J = 0.01;
    b = 0.1;
    K = 0.01;
    R = 1;
    L = 0.5;


    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");

    %define the formula
    %STL_ReadFile('stl/dcmotor_specs.stl');
     
    phi_s = STL_Formula('phi_s', 'alw_[1,10] (abs(speed[t+dt]-speed[t]) < epsi1)');
    phi_s = set_params(phi_s,{'dt', 'epsi1'}, [0.1 0.04]);
    phi_r = STL_Formula('phi_r', 'ev_[0,tau1] (speed[t] > bt)');
    phi_r = set_params(phi_r,{'tau1', 'bt'}, [0.4 0.7]);
    %phi_c = STL_Formula('phi_c', 'ev_[0,tau] alw (abs(speed[t]-ref_speed[t]) < epsi )');
    %phi_c = set_params(phi_c,{'tau', 'epsi'}, [15 0.5]);
     phi_o = STL_Formula('phi_o', 'alw (speed[t] < al)');
     phi_o = set_params(phi_o,{'al'}, [1.15]);
     phi_sp = STL_Formula('phi_sp', 'alw (not(((speed[t+dt]-speed[t])*10 > m) and ev_[0,tau2] ((speed[t+dt]-speed[t])*10 < -1*m)))');
     phi_sp = set_params(phi_sp,{'tau2', 'dt','m'}, [2 0.1 0.5]);
     phi_all = STL_Formula('phi_all', '(phi_s and phi_o and phi_sp)');
     phi_all = set_params(phi_all,{'dt', 'epsi1','al','tau2','m'}, [0.1 0.04 1.15 2 0.5]);
    
     
    if specno==1
       phi=phi_s;
    %elseif specno==2
    %   phi=phi_r;
    %elseif specno==3
    %   phi=phi_c;
    elseif specno==4
       phi=phi_o;
    elseif specno==5    
       phi=phi_sp;
    elseif specno==6
        phi=phi_all;
    end

    B.SetTime(0:.01:10); % default simulation time

    sg = var_step_signal_gen({'Voltage'},3);

    B.SetInputGen(sg);                
    %B.SetParam({'Zref_u0','Zref_u1','Zref_u2'},...
     %                    [10;  10;  10 ]);

    %B.SetParamRanges({'Force_u0'}, ...
    %                  [900 1000]);      
    B.SetParam({'Voltage_dt0','Voltage_dt1','Voltage_dt2'}, [3; 4 ;3]);        
    B.SetParamRanges({'Voltage_u0','Voltage_u1','Voltage_u2'}, ...
                      [0.8 1; 0.8 1;0.8 1]);               

    %B.Sim(0:.01:30); % Run Simulink simulation until time=30s 
    %B.PlotSignals(); % plots the signals collected after the simulation


    %falsif_pb = FalsificationProblem(B, phi,falsif_params.names,falsif_params.ranges);
    %falsif_pb = FalsificationProblem(B,phi);
    if mode==1  % falsification mode
       disp("falsify");
       disp(phi);
       falsif_pb = FalsificationProblem(B,phi);
    elseif mode==2  %synthesis mode
       disp("synthesis");  
       disp(get_params(phi_mod));
       falsif_pb = FalsificationProblem(B,phi_mod);
    end   
    falsif_pb.max_time = 180;
    %falsif_pb.solver = 'fminsearch';
    %falsif_pb.solver = 'fmincon';
    %falsif_pb.solver = 'cmaes';
    %falsf_pb.solver = 'simulannealbnd';
    %falsif_pb.solver='ga';
    
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
%         BrFalse = falsif_pb.GetBrSet_False();
%         BrFalse=BrFalse.BrSet;
% 
% 
%      BrFalse.PlotSigPortrait('theta');
%      BrFalse.PlotRobustSat(phi);
