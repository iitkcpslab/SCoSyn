%% Interface Automatic Transmission model with Breach 

addpath utilities
%% Initialize Variables
quad_variables;
global Quad;
newfile='QuadrotorSimulink';

B = BreachSimulinkSystem(newfile);
%toc
%disp("time for interfacing");

%define the formula
STL_ReadFile('stl/cc_specs.stl');
    
%phi=phi_settled;
%phi=phi_stable;
%phi=phi_alw_settle;
%phi=phi_rise;
phi=phi_full_conv;
%phi=phi_spike;

%{
time_u = 0:.1:30;
Xdes = 1 - 1*exp(-0.5*time_u);
Ydes = 1 - 1*exp(-0.5*time_u);
Zdes = 1 - 1*exp(-0.5*time_u);
Psides = 0.52 - 0.52*exp(-0.5*time_u);
U = [time_u' Xdes' Ydes' Zdes' Psides'];
% order matters!
B.Sim(0:.01:30,U);
B.PlotSignals();
return;
%}

%{
%B.SetTime(0:.01:40); % default simulation time
input_gen.type = 'UniStep'; % uniform time steps
input_gen.cp = 3; % number of control points
B.SetInputGen(input_gen);
B.SetParam({'Xd_u0','Xd_u1','Xd_u2'}, [0 1 2]);
B.SetParam({'Yd_u0','Yd_u1','Yd_u2'}, [0 1 2]);
B.SetParam({'Zd_u0','Zd_u1','Zd_u2'}, [0 1 2]);
B.SetParam({'Psid_u0','Psid_u1','Psid_u2'}, [0 pi/6 pi/3]);
%B.Sim(0:0.01:40);
%B.PlotSignals();
%return;
%}


x_gen = var_step_signal_gen({'Xd','Yd','Zd','Psid'},10);
%y_gen = var_step_signal_gen({'Yd'},4);
%z_gen = var_step_signal_gen({'Zd'},4);
%p_gen = var_step_signal_gen({'Psid'},4);

B.SetInputGen(x_gen);                
B.SetParam({'Xd_dt0', 'Xd_dt1', 'Xd_dt2'}, ...
                  [10 ; 10; 10;]);  
B.SetParam({'Yd_dt0', 'Yd_dt1', 'Yd_dt2'}, ...
                  [10 ; 10; 10;]); 
B.SetParam({'Zd_dt0', 'Zd_dt1', 'Zd_dt2'}, ...
                  [10 ; 10; 10;]); 
B.SetParam({'Psid_dt0', 'Psid_dt1', 'Psid_dt2'}, ...
                  [10 ; 10; 10;]); 
        
B.SetParamRanges({'Xd_u0','Xd_u1','Xd_u2'}, ...
                  [0.1 .25;0.1 .25;0.1 .25;]); 
B.SetParam({'Yd_u0','Yd_u1','Yd_u2'}, ...
                  [0; 0; 0;]);              
B.SetParamRanges({'Zd_u0','Zd_u1','Zd_u2'}, ...
                  [0 .5;0 .5;0 .5;]);  
B.SetParam({'Psid_u0','Psid_u1','Psid_u2'}, ...
                  [ 0; 0; 0;]);  


%{
sg = var_step_signal_gen({'Xd'},3);
B.SetInputGen(sg);                
B.SetParam({'Xd_dt0', 'Xd_dt1', 'Xd_dt2'}, ...
                  [10 ; 10; 10]);                 
B.SetParamRanges({'Xd_u0', 'Xd_u1', 'Xd_u2'}, ...
                  [0.1 0.25;0.1 0.25;0.1 0.25]);                 
%}

%falsif_pb = FalsificationProblem(B, phi,falsif_params.names,falsif_params.ranges);
falsif_pb = FalsificationProblem(B,phi);
falsif_pb.max_time = 180;
falsif_pb.solve();
 if falsif_pb.obj_best>=0
     return;
 end

BrFalse = falsif_pb.GetBrSet_False();
BrFalse=BrFalse.BrSet;
    
    
BrFalse.PlotSigPortrait('Z');
BrFalse.PlotRobustSat(phi);
