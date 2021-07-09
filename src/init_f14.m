%% Interface quadcopter model with Breach 

%% Initialize Variables
%quad_variables;

function [phi,rob,BrFalse] = init_f14(newfile,specno,mode)

    
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");

    %define the formula
    %STL_ReadFile('stl/siso_specs.stl');
    phi_s = STL_Formula('phi_s', 'alw_[3,60] (abs(alpha[t+dt]-alpha[t]) < epsi1)');
    %phi_s = set_params(phi_s,{'dt', 'epsi1'}, [0.1 0.003]);
    phi_s = set_params(phi_s,{'dt', 'epsi1'}, [0.1 0.001]);
    phi_r = STL_Formula('phi_r', 'ev_[0,tau1] (alpha[t] > bt*stick[t])');
    phi_r = set_params(phi_r,{'tau1', 'bt'}, [0.9 0.85]);
    phi_c = STL_Formula('phi_c', 'ev_[0,tau2] alw (abs(alpha[t]-stick[t]) < epsi2 )');
    phi_c = set_params(phi_c,{'tau2', 'epsi2'}, [1 0.15]);
    
     phi_o = STL_Formula('phi_o', 'alw (abs(alpha[t]) < al*abs(alpha[t]))');
     phi_o = set_params(phi_o,{'al'}, [1]);
     phi_sp = STL_Formula('phi_sp', 'alw (not(((alpha[t+dt2]-alpha[t])*10 > m) and ev_[0,tau3] ((alpha[t+dt2]-alpha[t])*10 < -1*m)))');
     phi_sp = set_params(phi_sp,{'tau3', 'dt2','m'}, [4 0.1 0.1]);
    phi_all = STL_Formula('phi_all', '(phi_s and phi_r and phi_c )');
    phi_all = set_params(phi_all,{'dt', 'epsi1','tau1', 'bt','tau2','epsi2','al','tau3', 'dt2','m'}, [0.1 0.001 0.7 0.95 1 0.15 1.05 1 0.1 1]);
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

    B.SetTime(0:.1:60); % default simulation time

    sg = var_step_signal_gen({'stick'});

    B.SetInputGen(sg);                
    %B.SetParam({'Zref_u0','Zref_u1','Zref_u2'},...
     %                    [10;  10;  10 ]);

    B.SetParam({'dt_u0'}, ...
                       [60]);  
    B.SetParamRanges({'stick_u0'}, ...
                      [-1 1;]);                 
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