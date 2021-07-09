%% Interface Automatic Transmission model with Breach 

%% Initialize Variables


function [phi,rob] = synth_cc(newfile,phi)

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
   
    B.SetTime(0:.01:60); % default simulation time
    sg = var_step_signal_gen({'ref_speed'},3);

    B.SetInputGen(sg);                
    B.SetParamRanges({'ref_speed_u0', 'ref_speed_u1', 'ref_speed_u2'}, ...
                      [20 25; 20 25; 20 25]);  

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
