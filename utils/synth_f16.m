%% Interface Automatic Transmission model with Breach 

%addpath utilities
%% Initialize Variables

function [phi,rob] = synth_f16(newfile,phi)

    addpath f16;
    %newfile='Quad_sim';
    warning('off');
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");


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

       disp("synthesis");  
       disp(get_params(phi));
       falsif_pb = FalsificationProblem(B,phi);
  
    falsif_pb.max_time = 180;
    falsif_pb.solve();
    rob=falsif_pb.obj_best;
    if rob>=0
         BrFalse='';
         return;
    end
end
