%% Interface Automatic Transmission model with Breach 

%% Initialize Variables
J = 3.2284E-6;
b = 3.5077E-6;
K = 0.0274;
R = 4;
L = 2.75E-6;

%return;
%newfile='QuadrotorSimulink';
newfile='Motor_Pos';

B = BreachSimulinkSystem(newfile);
%toc
%disp("time for interfacing");

%define the formula
STL_ReadFile('stl/dcmotor_pos_specs.stl');
    
phi=phi_settled;
%phi=phi_ov; %%not working
%phi=phi_rise;

B.SetTime(0:.01:0.2); % default simulation time

sg = var_step_signal_gen({'Voltage'},2);

B.SetInputGen(sg);                
%B.SetParam({'Zref_u0','Zref_u1','Zref_u2'},...
 %                    [10;  10;  10 ]);

%B.SetParamRanges({'Force_u0'}, ...
%                  [900 1000]);      
B.SetParam({'Voltage_dt0','Voltage_dt1'}, [0.1; 0.1]);        
B.SetParamRanges({'Voltage_u0','Voltage_u1'}, ...
                  [1 1.1; 1 1.1]);               
              
%B.Sim(0:.01:30); % Run Simulink simulation until time=30s 
%B.PlotSignals(); % plots the signals collected after the simulation


%falsif_pb = FalsificationProblem(B, phi,falsif_params.names,falsif_params.ranges);
%% not working TODO
%falsif_pb = FalsificationProblem(B,phi);
falsif_pb.max_time = 180;
falsif_pb.solve();
 if falsif_pb.obj_best>=0
     return;
 end

    BrFalse = falsif_pb.GetBrSet_False();
    BrFalse=BrFalse.BrSet;
    
    
 BrFalse.PlotSigPortrait('theta');
 BrFalse.PlotRobustSat(phi);
