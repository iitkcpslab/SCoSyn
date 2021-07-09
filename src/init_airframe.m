
function [phi,rob,BrFalse] = init_airframe(newfile,specno,mode)
    %addpath config_robotarm;
    %warning('off');
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");
   
     
    %define the formula
    %STL_ReadFile('stl/mimo_specs.stl');
    phi_s = STL_Formula('phi_s', 'alw_[2,20] ((abs(az[t+dt]-az[t]) < epsi1))');
    phi_s = set_params(phi_s,{'dt', 'epsi1'}, [0.1 0.05]);
    phi_r = STL_Formula('phi_r', 'ev_[0,tau1] (az[t] > az_ref[t]*bt)');
    phi_r = set_params(phi_r,{'tau1', 'bt'}, [0.4 0.95]);  
    
    phi_c = STL_Formula('phi_c', 'ev_[0,tau2] alw ((abs(az[t]-az_ref[t]) < epsi2) )');
    phi_c = set_params(phi_c,{'tau2', 'epsi2'}, [6 3.5]);

    phi_o = STL_Formula('phi_o', 'alw (az[t] < al*az_ref[t])');
    phi_o = set_params(phi_o,{'al'}, [1]);
    phi_sp = STL_Formula('phi_sp', 'alw (not(((az[t+dt2]-az[t])*10 > m) and ev_[0,tau3] ((az[t+dt2]-az[t])*10 < -1*m) ))');
    phi_sp = set_params(phi_sp,{'tau3', 'dt2','m'}, [8 0.1 0.3]);
    
    phi_all = STL_Formula('phi_all', '(phi_s and phi_r and phi_c and phi_sp)');
    phi_all = set_params(phi_all,{'dt','epsi1','tau1','bt','tau2','epsi2','tau3','dt2','m'}, [0.1 0.05 0.4 0.95 10 1.5 8 0.1 0.3]);
    
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
    %phi=phi_spike;

    B.SetTime(0:.01:20);
    x_gen = var_step_signal_gen({'az_ref'});

    B.SetInputGen(x_gen);                
    B.SetParam({'dt_u0'}, ...
                       [20;]);     
    B.SetParamRanges({'az_ref_u0'}, ...
                      [180 200;]);
    
    if mode==1  % falsification mode
       %disp("falsify");
       %disp(phi);
       falsif_pb = FalsificationProblem(B,phi);
    elseif mode==2  %synthesis mode
       %disp("synthesis");  
       %disp(get_params(phi_mod));
       falsif_pb = FalsificationProblem(B,phi_mod);
    end   
    %disp(phi)
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
