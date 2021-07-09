%% Interface Automatic Transmission model with Breach 

%% Initialize Variables


function [phi,rob,BrFalse] = init_cc(newfile,specno,mode)

    % Parameters for defining the system dynamics
    alpha = [40, 25, 16, 12, 10];		% gear ratios
    Tm = 190;				% engine torque constant, Nm
    wm = 420;				% peak torque rate, rad/sec
    beta = 0.4;				% torque coefficient
    Cr = 0.01;				% coefficient of rolling friction
    rho = 1.3;				% density of air, kg/m^3
    Cd = 0.32;				% drag coefficient
    A = 2.4;				% car area, m^2
    g = 9.8;				% gravitational constant

    % cruise_opcon.m - Defines operating conditions
    % kja 060717

    vref=20;            %reference value for velocity m/s
    v_e=20;             %equilibrium velocity m/s
    % theta_d=4;          %slope of road deg [set in local file]
    theta_e=0;          %equilibrium slope deg
    u_e=0.1616;         %equilibrium throttle
    gear=4;             %gear

    % Set defaults if all arguments aren't passed
    gear = 4; % gear ratio
    theta = 0; % road angle
    m = 1000; % mass of the car

    %newfile='cruise_ctrl';

    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");
    
    phi_s = STL_Formula('phi_s', 'alw_[12,60] (abs(speed[t+dt]-speed[t]) < epsi1)');
    phi_s = set_params(phi_s,{'dt', 'epsi1'}, [0.1 0.01]);
    phi_r = STL_Formula('phi_r', 'ev_[0,tau1] (speed[t] > bt*ref_speed[t])');
    phi_r = set_params(phi_r,{'tau1', 'bt'}, [1 0.9]);
    phi_c = STL_Formula('phi_c', 'ev_[0,tau2] alw (abs(speed[t]-ref_speed[t]) < epsi2 )');
    phi_c = set_params(phi_c,{'tau2', 'epsi2'}, [15 0.10]);
    phi_o = STL_Formula('phi_o', 'alw (speed[t] < al*ref_speed[t])');
    phi_o = set_params(phi_o,{'al'}, [1.05]);
    phi_sp = STL_Formula('phi_sp', 'alw (not(((speed[t+dt]-speed[t])*10 > m) and ev_[0,tau] ((speed[t+dt]-speed[t])*10 < -1*m)))');
    phi_sp = set_params(phi_sp,{'tau', 'dt','m'}, [20 0.1 .1]);
     phi_all = STL_Formula('phi_all', '(phi_s and phi_r and phi_c and phi_o)');
     phi_all = set_params(phi_all,{'dt', 'epsi1','tau1', 'bt','tau2', 'epsi2','al'}, [0.1 0.01 1 0.9 15 0.10 1.05]);
    


    %define the formula
    %STL_ReadFile('stl/cc_specs.stl');
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
    end
    B.SetTime(0:.01:60); % default simulation time
    sg = var_step_signal_gen({'ref_speed'});

    B.SetInputGen(sg);              
    B.SetParam({'dt_u0'}, ...
                       [60]);
    B.SetParamRanges({'ref_speed_u0'}, ...
                      [20 25]);  

    %{
    s_gen = var_step_signal_gen({'ref_speed'},3);
    g_gen = var_step_signal_gen({'gear'},3);

    %InputGen = BreachSignalGen({s_gen, g_gen});

    InputGen.SetParamRanges({'dt_u0', 'dt_u1'}, ...
                      [.1 10  ;  .1 10;]);
    %InputGen.SetParam({'ref_speed_u0','ref_speed_dt0','ref_speed_u1','ref_speed_dt1','ref_speed_u2'}, ...
    %                  [20 10 30 10 20]);   
    InputGen.SetParamRanges({'ref_speed_u0','ref_speed_u1','ref_speed_u2'}, ...
                      [0 10; 10 20; 20 30]); 
    InputGen.SetParamRanges({'gear_u0','gear_u1','gear_u2'}, ...
                      [1 1; 2 2; 3 3;]);              

    B.SetInputGen(InputGen);                
    %}
    %B.Sim(0:.01:30); % Run Simulink simulation until time=30s 
    %B.PlotSignals(); % plots the signals collected after the simulation


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
     %figure
     %BrFalse.PlotSigPortrait('speed');
end

% 
% 
%      BrFalse.PlotSigPortrait('speed');
%      BrFalse.PlotRobustSat(phi);
