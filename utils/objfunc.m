

function f = objfunc(pval)
   sind={'Gain';'Gain1';'Gain2'};
   newfile='Aircraft_Pitch';
   open_system(newfile);
   b = find_system(newfile,'Type','Block');  
    for i=1:length(b)
       prefix = strsplit(char(b(i)),'/');
       if length(prefix)>2
           continue;
       end
       %disp(sind(1));
       if strcmp(prefix(2),sind(1))
          handle1 = get_param(b{i},'handle');
          block = get(handle1);
       end
       if strcmp(prefix(2),sind(2))
          handle2 = get_param(b{i},'handle');
       end
       if strcmp(prefix(2),sind(3))
          handle3 = get_param(b{i},'handle');
       end  
    end
    set_param(handle1,block.BlockType,num2str(pval(1)));
    set_param(handle2,block.BlockType,num2str(pval(2)));
    set_param(handle3,block.BlockType,num2str(pval(3)));
    save_system(newfile);
    close_system(newfile);
    %initialize;
    B = BreachSimulinkSystem(newfile);
    
    B.SetTime(0:.01:30); % default simulation time
    sg = var_step_signal_gen({'theta_ref'});
    B.SetInputGen(sg);                
    B.SetParam({'dt_u0'},[30]);  
    B.SetParamRanges({'theta_ref_u0'},[0.1 1;]);
    %phi_c = STL_Formula('phi_c', 'ev_[0,tau] alw (abs(theta[t]-theta_ref[t]) < epsi )');
    %phi_c = set_params(phi_c,{'tau', 'epsi'}, [10 0.1]);
    phi_s = STL_Formula('phi_s', 'alw_[5,30] (abs(theta[t+dt]-theta[t]) < epsi)');
    phi_s = set_params(phi_s,{'dt', 'epsi'}, [0.1 0.01]);
    phi_r = STL_Formula('phi_r', 'ev_[0,tau] (theta[t] > bt*theta_ref[t])');
    phi_r = set_params(phi_r,{'tau', 'bt'}, [2 0.8]);
    phi_o = STL_Formula('phi_o', 'alw (theta[t] < al*theta_ref[t])');
    phi_o = set_params(phi_o,{'al'}, [1.15]);
    phi_sp = STL_Formula('phi_sp', 'alw (not(((theta[t+dt]-theta[t])*10 > m) and ev_[0,5] ((theta[t+dt]-theta[t])*10 < -1*m)))');
    phi_sp = set_params(phi_sp,{'tau', 'dt','m'}, [5 0.1 0.1]);
    phi = STL_Formula('phi', '(phi_s and phi_o)');
    
    falsif_pb = FalsificationProblem(B,phi);
    falsif_pb.max_time = 180;
    falsif_pb.solve();

    f=falsif_pb.obj_best;
end
