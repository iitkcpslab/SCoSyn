%% Interface Automatic Transmission model with Breach 

%addpath utilities
%% Initialize Variables

function [phi,rob,BrFalse] = init_f16(newfile,specno,mode)

    addpath f16;
    %newfile='Quad_sim';
    warning('off');
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");

    %define the formula
    %STL_ReadFile('stl/mimo_specs.stl');
    phi_s = STL_Formula('phi_s', 'alw_[3,10] ((abs(Nz[t+dt1]-Nz[t]) < epsi1))');
    phi_s = set_params(phi_s,{'dt1', 'epsi1'}, [0.1 0.005]);
    
    phi_r = STL_Formula('phi_r', 'ev_[0,tau1] (Nz[t] > bt*Nzref[t])');
    phi_r = set_params(phi_r,{'tau1', 'bt'}, [0.03 1]);  % 0.03 1
    % SAT at 0.03 0.5
    
    phi_c = STL_Formula('phi_c', 'ev_[0,tau2] alw (abs(Nzref[t]-Nz[t]) < epsi2)');
    phi_c = set_params(phi_c,{'tau2', 'epsi2'}, [5 .1]); % 5 0.05   SAT at 8 0.1
    
    phi_o = STL_Formula('phi_o', 'alw (Nz[t] < al*Nzref[t]) ');
    phi_o = set_params(phi_o,{'al'}, [1.2]);
    
    phi_sp = STL_Formula('phi_sp', 'alw (not(((Nz[t+dt2]-Nz[t])*10 > m) and ev_[0,tau3] ((Nz[t+dt2]-Nz[t])*10 < -1*m)))');
    phi_sp = set_params(phi_sp,{'tau3', 'dt2','m'}, [1  0.1 0.05]);
    
    phi_all = STL_Formula('phi_all', '(phi_s and phi_r and phi_c and phi_o and phi_sp)');
    phi_all = set_params(phi_all,{'dt1','epsi1','tau1','bt','tau2','epsi2','al','tau3','dt2','m'}, [0.1 0.01 0.03 1 5 .05 1.2 1 0.1 0.05]);
    
    phi_ra = STL_Formula('phi_ra', '(not (phi_sp) until phi_r)');
    phi_ra = set_params(phi_ra,{'tau1','bt','tau3','dt2','m'}, [5 0.5 1 0.1 0.05]);

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
      phi=phi_ra;  
    end
    %phi=phi_spike;


    B.SetTime(0:.01:10);
    x_gen = var_step_signal_gen({'Nzc','n','w'});

    B.SetInputGen(x_gen);                
    %B.SetParam({'Xd_dt0', 'Xd_dt1', 'Xd_dt2'}, ...
    %                  [10 ; 10; 10;]);  
    %B.SetParam({'Yd_dt0', 'Yd_dt1', 'Yd_dt2'}, ...
    %                  [10 ; 10; 10;]); 
    %B.SetParam({'Zd_dt0', 'Zd_dt1', 'Zd_dt2'}, ...
    %                  [10 ; 10; 10;]); 
    %B.SetParam({'Psid_dt0', 'Psid_dt1', 'Psid_dt2'}, ...
    %                  [10 ; 10N; 10;]); 
    B.SetParam({'dt_u0'}, ...
                       [10;]);        
    B.SetParamRanges({'Nzc_u0'}, ...
                      [1 1.1;]); 
    B.SetParamRanges({'n_u0'}, ...
                      [0.0001 0.0002;]);
    B.SetParamRanges({'w_u0'}, ...
                      [0 0.0001;]);


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
    %figure
    %BrFalse.PlotSigPortrait('Nz');
%     figure
%     BrFalse.PlotSigPortrait('Nzc');
%     figure
%     BrFalse.PlotSigPortrait('');
end
%     BrFalse = falsif_pb.GetBrSet_False();
%     BrFalse=BrFalse.BrSet;
% 
%     %figure    
%     %BrFalse.PlotSignals();
%     figure
%     BrFalse.PlotRobustSat(phi);
