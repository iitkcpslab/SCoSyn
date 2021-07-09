
% this script takes modelno and specno as input
%function [phi,rob,BrFalse] = spec_param_synth(newfile,specno)
%synthesis
modelno=16;
specno=2;
tic
if modelno==3
      if specno==3
        phi_c = STL_Formula('phi_c', 'ev_[0,tau] alw (abs(theta[t]-theta_ref[t]) < epsi )');
        phi = set_params(phi_c,{'tau', 'epsi'}, [10 0.1]);
      elseif specno==5  
        phi_sp = STL_Formula('phi_sp', 'alw (not(((theta[t+dt]-theta[t])*10 > m) and ev_[0,tau] ((theta[t+dt]-theta[t])*10 < -1*m)))');
        phi = set_params(phi_sp,{'tau', 'dt','m'}, [5 0.1 0.1]);
      end  
    
        %phi=phi_c;

        pp=get_params(phi);
        clear phi_mod;
        if isfield(pp,'m')
          dval=pp.m;
          min=dval;
          max=5;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'m',i);
              [phi_mod,rob]=synth_aircraft('Aircraft_Pitch',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                  toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end  
        elseif isfield(pp,'tau')
          dval=pp.tau;
          min=dval;
          max=dval*2;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'tau',i);
              [phi_mod,rob]=synth_aircraft('Aircraft_Pitch',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                  toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
        elseif isfield(pp,'dt')
          dval=pp.dt;
        end
elseif modelno==2
        phi_r = STL_Formula('phi_r', 'ev_[0,tau] (speed[t] > bt*ref_speed[t])');
        phi_r = set_params(phi_r,{'tau', 'bt'}, [1 0.9]);
        phi=phi_r;
        pp=get_params(phi);
        clear phi_mod;
        if isfield(pp,'tau')
          dval=pp.tau;
          min=dval;
          max=dval*10;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'tau',i);
              [phi_mod,rob]=synth_cc('cruise_ctrl',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 return;
              end
           disp(i);   
          end
        elseif isfield(pp,'bt')
          dval=pp.dt;
          
          min=dval;
          max=1;
          step=0.02;
          for i=min:step:max
              phi_mod=set_params(phi,'bt',i);
              [phi_mod,rob]=synth_cc('cruise_ctrl',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 return;
              end
           disp(i);   
          end
        end
     
elseif modelno==4
        phi_r = STL_Formula('phi_r', 'ev_[0,tau] (theta[t] > bt)');
        phi_r = set_params(phi_r,{'tau', 'bt'}, [0.1 0.9]);
        phi=phi_r;
        pp=get_params(phi);
        clear phi_mod;
        if isfield(pp,'bt')
          dval=pp.bt;
          min=dval;
          max=0.1;
          step=-0.1;
          for i=min:step:max
              phi_mod=set_params(phi,'bt',i);
              [phi_mod,rob]=synth_pendulum('Inverted_Pendulum',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 return;
              end
           disp(i);   
          end
        elseif isfield(pp,'tau')
          dval=pp.tau;
          min=dval;
          max=dval*10;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'tau',i);
              [phi_mod,rob]=synth_pendulum('Inverted_Pendulum',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 return;
              end
           disp(i);   
          end
        end
  elseif modelno==5
      if specno==2
        phi_r = STL_Formula('phi_r', 'ev_[0,tau] (speed[t] > bt)');
        phi = set_params(phi_r,{'tau', 'bt'}, [0.6 0.8]);
      elseif specno==1
        phi_s = STL_Formula('phi_s', 'alw_[0,2.2] (abs(speed[t+dt]-speed[t]) < epsi)');
        phi = set_params(phi_s,{'dt', 'epsi'}, [0.01 0.02]);
      end
        %phi=phi_r;
        pp=get_params(phi);
        clear phi_mod;
        if isfield(pp,'epsi')
          dval=pp.epsi;
          min=dval;
          max=dval*10;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'epsi',i);
              [phi_mod,rob]=synth_dcmotor('DCMotor',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 return;
              end
           disp(i);   
          end        
        elseif isfield(pp,'tau')
          dval=pp.tau;
          min=dval;
          max=dval*10;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'tau',i);
              [phi_mod,rob]=synth_dcmotor('DCMotor',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 return;
              end
           disp(i);   
          end
        elseif isfield(pp,'bt')
          dval=pp.bt;
          min=dval;
          max=1;
          step=0.02;
          for i=min:step:max
              phi_mod=set_params(phi,'bt',i);
              [phi_mod,rob]=synth_dcmotor('DCMotor',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 return;
              end
           disp(i);   
          end
        end
        
   elseif modelno==6
      if specno==2
        phi_r = STL_Formula('phi_r', 'ev_[0,tau] (Nz[t] > bt*Nzref[t])');
        phi = set_params(phi_r,{'tau', 'bt'}, [0.03 1]); 
      elseif specno==3
        phi_c = STL_Formula('phi_c', 'ev_[0,tau] alw (abs(Nzref[t]-Nz[t]) < epsi)');
        phi = set_params(phi_c,{'tau', 'epsi'}, [2 .05]); % 5 0.05   SAT at 8 0.1
      end
       
        %phi=phi_r;
        pp=get_params(phi);
        clear phi_mod;
       if isfield(pp,'bt')
          dval=pp.bt;
          min=dval;
          exl=0.1;
          step=-0.02;
          for i=min:step:exl
              phi_mod=set_params(phi,'bt',i);
              [phi_mod,rob]=synth_f16('rct_concorde',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
       end
       if isfield(pp,'epsi')
          dval=pp.epsi;
          min=dval;
          max=0.1;
          step=(max-min)/5;
          for i=min:step:max
              phi_mod=set_params(phi,'epsi',i);
              [phi_mod,rob]=synth_f16('rct_concorde',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                  toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
          phi=phi_mod;
       end
        if isfield(pp,'tau')
          dval=pp.tau;
          min=dval;
          max=dval*10;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'tau',i);
              [phi_mod,rob]=synth_f16('rct_concorde',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
       end
        
        
   elseif modelno==7
           phi_r = STL_Formula('phi_r', 'ev_[0,tau] ((Z[t] > Zd[t]*bt) and (X[t] > Xd[t]*bt) and (Y[t] > Yd[t]*bt))');
           phi_r = set_params(phi_r,{'tau', 'bt'}, [2.3 0.8]); 
           phi=phi_r;
            pp=get_params(phi);
            clear phi_mod;
            if isfield(pp,'tau')
              dval=pp.tau;
              min=dval;
              max=dval*10;
              step=(max-min)/10;
              for i=min:step:max
                  phi_mod=set_params(phi,'tau',i);
                  [phi_mod,rob]=synth_quadrotor_full('Quad_sim',phi_mod);
                  if rob>=0
                     disp("new spec is ");
                     phi_mod
                     disp("with params ");
                     disp(get_params(phi_mod));
                     toc
                      disp("time for param synth");
                     return;
                  end
               disp(i);   
              end
            elseif isfield(pp,'bt')
              dval=pp.bt;
              min=dval;
              max=1;
              step=0.02;
              for i=min:step:max
                  phi_mod=set_params(phi,'bt',i);
                  [phi_mod,rob]=synth_quadrotor_full('Quad_sim',phi_mod);
                  if rob>=0
                     disp("new spec is ");
                     phi_mod
                     disp("with params ");
                     disp(get_params(phi_mod));
                      toc
                 disp("time for param synth");
                     return;
                  end
               disp(i);   
              end
            end
elseif modelno==14
        phi_sp = STL_Formula('phi_sp', 'alw (not(((az[t+dt]-az[t])*10 > m) and ev_[0,tau] ((az[t+dt]-az[t])*10 < -1*m) ))');
        phi_sp = set_params(phi_sp,{'tau', 'dt','m'}, [8 0.1 0.3]);
      
        phi=phi_sp;

        pp=get_params(phi);
        clear phi_mod;
        
       if isfield(pp,'m')
          dval=pp.m;
          min=dval;
          max=100;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'m',i);
              [phi_mod,rob]=synth_airframe('scdairframectrl',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                  toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end  
        
       elseif isfield(pp,'tau')
          dval=pp.tau;
          min=dval;
          max=dval*0.1;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'tau',i);
               [phi_mod,rob]=synth_airframe('scdairframectrl',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                  toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
       
        elseif isfield(pp,'dt')
          dval=pp.dt;
       end
       
elseif modelno==11
      if specno==1
        phi_s = STL_Formula('phi_s', 'alw_[3,60] (abs(alpha[t+dt]-alpha[t]) < epsi)');
        phi = set_params(phi_s,{'dt', 'epsi'}, [0.1 0.001]);  
      elseif specno==2
        phi_r = STL_Formula('phi_r', 'ev_[0,tau] (alpha[t] > bt*stick[t])');
        phi = set_params(phi_r,{'tau', 'bt'}, [0.9 0.85]);
      elseif specno==3
        phi_c = STL_Formula('phi_c', 'ev_[0,tau] alw (abs(alpha[t]-stick[t]) < epsi )');
        phi = set_params(phi_c,{'tau', 'epsi'}, [1 0.15]);
      end
       
        %phi=phi_r;
        pp=get_params(phi);
        clear phi_mod;
       if isfield(pp,'epsi')
          dval=pp.epsi;
          min=dval;
          max=dval*10;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'epsi',i);
              [phi_mod,rob]=synth_f14('F14',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                  toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end    
        elseif isfield(pp,'bt')
          dval=pp.bt;
          min=dval;
          exl=0.1;
          step=-0.02;
          for i=min:step:exl
              phi_mod=set_params(phi,'bt',i);
              [phi_mod,rob]=synth_f14('F14',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
        elseif isfield(pp,'tau')
          dval=pp.tau;
          min=dval;
          max=dval*10;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'tau',i);
              [phi_mod,rob]=synth_f14('F14',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                  toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
      elseif isfield(pp,'epsi')
          dval=pp.epsi;
          min=dval;
          max=0.1;
          step=(max-min)/5;
          for i=min:step:max
              phi_mod=set_params(phi,'epsi',i);
              [phi_mod,rob]=synth_f14('F14',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                  toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
          phi=phi_mod;
      elseif isfield(pp,'tau')
          dval=pp.tau;
          min=dval;
          max=dval*10;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'tau',i);
              [phi_mod,rob]=synth_f14('F14',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
       end
   
  elseif modelno==15
      
     if specno==1
        phi_s = STL_Formula('phi_s', 'alw_[70,200] (abs(temp[t+dt]-temp[t]) < epsi)');
        phi = set_params(phi_s,{'dt', 'epsi'}, [0.1 0.001]);
     elseif specno==2
        phi_r = STL_Formula('phi_r', 'ev_[0,tau] ((temp[t] > setp[t]*bt) )');
        phi = set_params(phi_r,{'tau', 'bt'}, [20 0.8]);  
     elseif specno==3
        phi_c = STL_Formula('phi_c', 'ev_[0,tau] alw (abs(temp[t]-setp[t]) < epsi)');
        phi = set_params(phi_c,{'tau', 'epsi'}, [80 0.1]);
     elseif specno==4 
        phi_o = STL_Formula('phi_o', 'alw (temp[t] < al*setp[t])');
        phi = set_params(phi_o,{'al'}, [2]);
     elseif specno==5
        phi_sp = STL_Formula('phi_sp', 'alw (not ( ((temp[t+dt]-temp[t])*10 > m) and ev_[0,tau] ((temp[t+dt]-temp[t])*10 < -1*m) ) )');
        phi = set_params(phi_sp,{'tau', 'dt','m'}, [3 0.1 0.01]);
     end
       
        %phi=phi_r;
        pp=get_params(phi);
        clear phi_mod;
       if isfield(pp,'epsi')
          dval=pp.epsi;
          min=dval;
          max=dval*10;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'epsi',i);
              [phi_mod,rob]=synth_heatex('heatex_sim',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                  toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end    
        elseif isfield(pp,'bt')
          dval=pp.bt;
          min=dval;
          exl=0.1;
          step=-0.02;
          for i=min:step:exl
              phi_mod=set_params(phi,'bt',i);
              [phi_mod,rob]=synth_heatex('heatex_sim',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
        elseif isfield(pp,'al')
          dval=pp.al;
          min=dval;
          exl=dval*2;
          step=(exl-min)/10;
          for i=min:step:exl
              phi_mod=set_params(phi,'al',i);
              [phi_mod,rob]=synth_heatex('heatex_sim',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
      elseif isfield(pp,'m')
          dval=pp.m;
          min=dval;
          max=100;
          step=(max-min)/100;
          for i=min:step:max
              phi_mod=set_params(phi,'m',i);
              [phi_mod,rob]=synth_heatex('heatex_sim',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                  toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end  
       elseif isfield(pp,'tau')
          dval=pp.tau;
          min=dval;
          max=dval*10;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'tau',i);
              [phi_mod,rob]=synth_heatex('heatex_sim',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                  toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
       end
   elseif modelno==9
     
     if specno==1   
        phi_s = STL_Formula('phi_s', 'alw_[4,20] ((abs(theta2m[t+dt]-theta2m[t]) < epsi) and (abs(theta3m[t+dt]-theta3m[t]) < epsi))');
        phi = set_params(phi_s,{'dt', 'epsi'}, [0.1 0.05]);
     elseif specno==4
        phi_o = STL_Formula('phi_o', 'alw ((theta2m[t] < al*theta2md[t]) and (theta3m[t] < al*theta3md[t]))');
        phi = set_params(phi_o,{'al'}, [2.3]);
     elseif specno==5 
        phi_sp = STL_Formula('phi_sp', 'alw ((not(((theta2m[t+dt]-theta2m[t])*10 > m) and ev_[0,tau] ((theta2m[t+dt]-theta2m[t])*10 < -1*m))) and (not(((theta3m[t+dt]-theta3m[t])*10 > m) and ev_[0,tau] ((theta3m[t+dt]-theta3m[t])*10 < -1*m))) )');
        phi = set_params(phi_sp,{'tau', 'dt','m'}, [2 0.1 12]);
     end
       
        %phi=phi_r;
        pp=get_params(phi);
        clear phi_mod;
       if isfield(pp,'epsi')
          dval=pp.epsi;
          min=dval;
          max=dval*10;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'epsi',i);
              [phi_mod,rob]=synth_robotarm('RobotArm_Full',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                  toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
        elseif isfield(pp,'al')
          dval=pp.al;
          min=dval;
          exl=dval*2;
          step=(exl-min)/10;
          for i=min:step:exl
              phi_mod=set_params(phi,'al',i);
              [phi_mod,rob]=synth_robotarm('RobotArm_Full',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
      elseif isfield(pp,'m')
          dval=pp.m;
          min=dval;
          max=100;
          step=(max-min)/100;
          for i=min:step:max
              phi_mod=set_params(phi,'m',i);
              [phi_mod,rob]=synth_robotarm('RobotArm_Full',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                  toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end  
       
        elseif isfield(pp,'tau')
          dval=pp.tau;
          min=dval;
          max=dval*10;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'tau',i);
              [phi_mod,rob]=synth_robotarm('RobotArm_Full',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                 toc
                 disp("time for param synth");
               
                 return;
              end
           disp(i);   
          end
       end
       
   elseif modelno==16
     
     if specno==2   
        phi_2 = STL_Formula('phi_2', 'alw (a_ego[t]>lb and a_ego[t]<ub and v_ego[t]>epsi)');
        phi = set_params(phi_2,{'lb','ub','epsi'}, [-1 1 0.5]); %0.5
     elseif specno==3
        phi_o = STL_Formula('phi_o', 'alw ((theta2m[t] < al*theta2md[t]) and (theta3m[t] < al*theta3md[t]))');
        phi = set_params(phi_o,{'al'}, [2.3]);
     end
       
        %phi=phi_r;
        pp=get_params(phi);
        clear phi_mod;
       if isfield(pp,'epsi')
          dval=pp.epsi;
          min=dval;
          max = -1*dval;
          step=(max-min)/10;
          for i=min:step:max
              phi_mod=set_params(phi,'epsi',i);
              [phi_mod,rob]=synth_demo('demo2',phi_mod);
               %phi_mod,rob]=synth_demo('demo3',phi_mod);
              if rob>=0
                 disp("new spec is ");
                 phi_mod
                 disp("with params ");
                 disp(get_params(phi_mod));
                  toc
                 disp("time for param synth");
                 return;
              end
           disp(i);   
          end
       end
end
  
toc
disp("time for param synth");
return;
