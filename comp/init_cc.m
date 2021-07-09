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
