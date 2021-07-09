%% Interface Automatic Transmission model with Breach 

%addpath utilities
%% Initialize Variables

function [phi,rob] = synth_quadrotor_full(newfile,phi)

    %newfile='Quad_sim';
    warning('off');
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");

    
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

    B.SetTime(0:.01:100);
    x_gen = var_step_signal_gen({'Xd','Yd','Zd','Psid'});

    B.SetInputGen(x_gen);                
    B.SetParam({'dt_u0'}, ...
                       [100;]);        
    B.SetParamRanges({'Xd_u0'}, ...
                      [4.1 4.4;]); 
    B.SetParamRanges({'Yd_u0'}, ...
                      [0.4 0.6;]);              
    B.SetParamRanges({'Zd_u0'}, ...
                      [2.1 2.3;]);  
    B.SetParam({'Psid_u0'}, ...
                      [ 0;]);  

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
%     BrFalse = falsif_pb.GetBrSet_False();
%     BrFalse=BrFalse.BrSet;
% 
%     %figure    
%     %BrFalse.PlotSignals();
%     figure
%     BrFalse.PlotRobustSat(phi);
