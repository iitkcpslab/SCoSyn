%% Interface Automatic Transmission model with Breach 


%% Initialize Variables
%quad_variables;

%newfile='QuadrotorSimulink';

%newfile='Aircraft_Pitch';
%global specno;
%global mode;

function [phi,rob,BrFalse] = init_aircraft(newfile,specno,mode)


    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");

    %define the formula
    %STL_ReadFile('stl/aircraft_specs.stl');
    phi_s = STL_Formula('phi_s', 'alw_[5,30] (abs(theta[t+dt]-theta[t]) < epsi1)');
    phi_s = set_params(phi_s,{'dt', 'epsi1'}, [0.1 0.01]);
    phi_r = STL_Formula('phi_r', 'ev_[0,tau1] (theta[t] > bt*theta_ref[t])');
    phi_r = set_params(phi_r,{'tau1', 'bt'}, [2 0.8]);
    phi_c = STL_Formula('phi_c', 'ev_[0,tau2] alw (abs(theta[t]-theta_ref[t]) < epsi2 )');
    phi_c = set_params(phi_c,{'tau2', 'epsi2'}, [10 0.1]);
        
    phi_o = STL_Formula('phi_o', 'alw (theta[t] < al*theta_ref[t])');
    phi_o = set_params(phi_o,{'al'}, [1.15]);
    phi_sp = STL_Formula('phi_sp', 'alw (not(((theta[t+dt]-theta[t])*10 > m) and ev_[0,tau3] ((theta[t+dt]-theta[t])*10 < -1*m)))');
    phi_sp = set_params(phi_sp,{'tau3', 'dt','m'}, [5 0.1 0.1]);
    phi_all = STL_Formula('phi_all', '(phi_s and phi_r and phi_c and phi_o and phi_sp)');
    phi_all = set_params(phi_all,{'dt', 'epsi1','tau1', 'bt','tau2', 'epsi2', 'al','tau3','m'}, [0.1 0.01 2 0.8 10 0.10 1.15 5 0.1]);
    
    phi_io = STL_Formula('phi_io', 'alw_[0,10] ev_[0,3] (abs(theta[t]-theta_ref[t]) < epsi2 )');
    phi_io = set_params(phi_io,{'tau2', 'epsi2'}, [10 0.1]);


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
      phi=phi_io;
    end


    B.SetTime(0:.01:30); % default simulation time

    sg = var_step_signal_gen({'theta_ref'});

    B.SetInputGen(sg);                
    %B.SetParam({'Zref_u0','Zref_u1','Zref_u2'},...
     %                    [10;  10;  10 ]);

    B.SetParam({'dt_u0'}, ...
                       [30]);  
    B.SetParamRanges({'theta_ref_u0'}, ...
                      [0.1 1;]); % note 0.1 radians=5.5 degrees (ref model page)  

    %B.Sim(0:.01:30); % Run Simulink simulation until time=30s 
    %B.PlotSignals(); % plots the signals collected after the simulation



    %falsif_pb = FalsificationProblem(B, phi,falsif_params.names,falsif_params.ranges);
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
    falsif_pb.solve();
     rob=falsif_pb.obj_best;
     if rob>=0
         BrFalse='';
         return;
     end
     BrFalse=falsif_pb.GetBrSet_False();
     BrFalse=BrFalse.BrSet;
end
    
    
 %BrFalse.PlotSigPortrait('theta');
 %BrFalse.PlotRobustSat(phi);