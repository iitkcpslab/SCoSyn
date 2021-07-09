%% Interface quadcopter model with Breach 

%% Initialize Variables
%quad_variables;

function [phi,rob,BrFalse] = init_quadrotor(newfile,specno,mode)

    
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");

    %define the formula
    %STL_ReadFile('stl/siso_specs.stl');
    phi_s = STL_Formula('phi_s', 'alw_[5,30] (abs(Z[t+dt]-Z[t]) < epsi1)');
    phi_s = set_params(phi_s,{'dt', 'epsi1'}, [0.1 0.03]);
    phi_r = STL_Formula('phi_r', 'ev_[0,tau1] (Z[t] > bt*Zref[t])');
    phi_r = set_params(phi_r,{'tau1', 'bt'}, [7 0.8]);
    phi_c = STL_Formula('phi_c', 'ev_[0,tau2] alw (abs(Z[t]-Zref[t]) < epsi2 )');
    phi_c = set_params(phi_c,{'tau2', 'epsi2'}, [15 0.1]);
    %phi_c = set_params(phi_c,{'tau2', 'epsi2'}, [15 0.01]);
     phi_o = STL_Formula('phi_o', 'alw (Z[t] < al*Zref[t])');
     phi_o = set_params(phi_o,{'al'}, [1.01]);
     %phi_sp = STL_Formula('phi_sp', 'alw (not(((Z[t+dt]-Z[t])*10 > m) and ev_[0,tau] ((Z[t+dt]-Z[t])*10 < -1*m)))');
     %phi_sp = set_params(phi_sp,{'tau', 'dt','m'}, [5 0.1 5]);
    phi_all = STL_Formula('phi_all', '(phi_s and phi_r and phi_c and phi_o)');
    phi_all = set_params(phi_all,{'dt', 'epsi1','tau1', 'bt','tau2', 'epsi2','al'}, [0.1 0.03 7 0.8 15 0.1 1.01]);
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

    B.SetTime(0:.01:30); % default simulation time

    sg = var_step_signal_gen({'Zref'});

    B.SetInputGen(sg);                
    %B.SetParam({'Zref_u0','Zref_u1','Zref_u2'},...
     %                    [10;  10;  10 ]);

    B.SetParam({'dt_u0'}, ...
                       [30]);  
    B.SetParamRanges({'Zref_u0'}, ...
                      [1 5;]);                 
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
     %BrFalse.PlotRobustSat(phi);
end
