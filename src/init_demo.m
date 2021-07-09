%% Interface quadcopter model with Breach 

%% Initialize Variables
%quad_variables;

function [phi,rob,BrFalse] = init_demo(newfile,specno,mode)

    
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");

    %define the formula
    %STL_ReadFile('stl/siso_specs.stl');
    phi_11 = STL_Formula('phi_11', 'alw (not (y_ego[t]>lb1 and y_ego[t]<ub1 and x_adv[t]<ub2 and x_adv[t]>lb2))');
    phi_11 = set_params(phi_11,{'lb1', 'ub1', 'lb2','ub2'}, [-0.5 0.5 -0.5 0.5]);
    %phi_11 = set_params(phi_11,{'lb1', 'ub1', 'lb2','ub2'}, [-0.499 0.501 -0.499 0.501]);
    phi_12 = STL_Formula('phi_12', 'alw (a_ego[t]>0.67 and a_ego[t]<2.501)');
    phi_1 = STL_Formula('phi_1', '(phi_11 and phi_12)');
    phi_1 = set_params(phi_1,{'lb1', 'ub1', 'lb2','ub2'}, [-0.5 0.5 -0.5 0.5]);
    
    phi_2 = STL_Formula('phi_2', 'alw (a_ego[t]>lb and a_ego[t]<ub and v_ego[t]>epsi1)');
    phi_2 = set_params(phi_2,{'lb','ub','epsi1'}, [-1 1 0.5]); %0.5
    %phi_2 = STL_Formula('phi_2', 'alw (a_ego[t]>lb and a_ego[t]<ub and v_ego[t]>epsi1)');
    %phi_2 = set_params(phi_2,{'lb','ub','epsi1'}, [-1 1 -0.01]); %0.5
    
    phi_3 = STL_Formula('phi_3', 'alw ((v_adv[t]>epsi1) =>(v_ego[t]>epsi1)) and (abs(a_ego[t])<1.01)');
    phi_3 = set_params(phi_3,{'epsi1'}, [0.5]); %0.5
    
    phi_all = STL_Formula('phi_all', '(phi_s and phi_r)');
    phi_all = set_params(phi_all,{'lb', 'ub'}, [-0.5 0.5]);
    
     if specno==1
      phi=phi_1;
    elseif specno==2
      phi=phi_2;
    elseif specno==3
      phi=phi_3;
     elseif specno==4  
      phi=phi_all;
    end

    B.SetTime(0:.2:2); % default simulation time

    sg = var_step_signal_gen({'a_adv'});

    B.SetInputGen(sg);                
    %B.SetParam({'Zref_u0','Zref_u1','Zref_u2'},...
     %                    [10;  10;  10 ]);

    B.SetParam({'dt_u0'}, ...
                       [2]);
    %B.SetParamRanges({'ref_u0'}, ...
    %                  [2.1 2.2;]); %demo1 
    B.SetParamRanges({'a_adv_u0'}, ...
                      [0.9 1.1;]); % demo2
    %B.SetParamRanges({'a_adv_u0'}, ...
    %                  [0 1.22;]); %for demo3                 
    %B.Sim(0:.01:30); % Run Simulink simulation until time=30s 
    %B.PlotSignals(); % plots the signals collected after the simulation


    %falsif_pb = FalsificationProblem(B, phi,falsif_params.names,falsif_params.ranges);
    %falsif_pb = FalsificationProblem(B,phi);
    if mode==1  % falsification mode
       disp("falsify");
       disp(phi);
       falsif_pb = FalsificationProblem(B,phi);
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
