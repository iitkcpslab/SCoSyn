%% Interface Automatic Transmission model with Breach 

%% Initialize Variables
m1 = 2500;
m2 = 320;
k1 = 80000;
k2 = 500000;
b1 = 350;
b2 = 15020;



%return;
%newfile='QuadrotorSimulink';
newfile='suspmod';

B = BreachSimulinkSystem(newfile);
%toc
%disp("time for interfacing");

%define the formula
STL_ReadFile('stl/suspmod_specs.stl');
    
%phi=phi_settled;
phi=phi_ov; %%not working
%phi=phi_rise;

B.SetTime(0:.01:50); % default simulation time

sg = var_step_signal_gen({'r'},5);

B.SetInputGen(sg);                
%B.SetParam({'Zref_u0','Zref_u1','Zref_u2'},...
 %                    [10;  10;  10 ]);

%B.SetParamRanges({'Force_u0'}, ...
%                  [900 1000]);      
B.SetParam({'r_dt0','r_dt1','r_dt2','r_dt3','r_dt4'}, [10; 10 ;10; 10; 10]);        
B.SetParamRanges({'r_u0','r_u1','r_u2','r_u3','r_u4'}, ...
                  [0 0.1; 0 0.1; 0 0.1;0 0.1;0 0.1]);               
              
%B.Sim(0:.01:30); % Run Simulink simulation until time=30s 
%B.PlotSignals(); % plots the signals collected after the simulation


%falsif_pb = FalsificationProblem(B, phi,falsif_params.names,falsif_params.ranges);
falsif_pb = FalsificationProblem(B,phi);
falsif_pb.max_time = 180;
falsif_pb.solve();
 if falsif_pb.obj_best>=0
     return;
 end

    BrFalse = falsif_pb.GetBrSet_False();
    BrFalse=BrFalse.BrSet;
    
    
 BrFalse.PlotSigPortrait('theta');
 BrFalse.PlotRobustSat(phi);
