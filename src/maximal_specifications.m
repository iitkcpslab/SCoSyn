
 %global max_spec_count;
 %global pval_best;
 %global max_wt;
 function [max_spec_count,pval_best,max_wt] = maximal_specifications(modelno,pval,max_spec_count,pval_best,max_wt)
    count=0;
    wcount=0;
    disp(pval);
    if modelno==3   
             w1=2;w2=2;w3=1;w4=1;w5=3;
             disp("phi_settle");
             specno=1;
             [phi,rob,BrFalse]=init_aircraft('Aircraft_Pitch',specno,1);
             if rob>=0
               count = count+1;
               wcount = wcount+1;
             end
             disp("phi_rise");
             specno=2;
             [phi,rob,BrFalse]=init_aircraft('Aircraft_Pitch',specno,1);
             if rob>=0
               count = count+1;
               wcount = wcount+2;
             end
             disp("phi_conv");
             specno=3;
             [phi,rob,BrFalse]=init_aircraft('Aircraft_Pitch',specno,1);
             if rob>=0
               count = count+1;
               wcount = wcount+3;
             end
             disp("phi_ov");
             specno=4;
             [phi,rob,BrFalse]=init_aircraft('Aircraft_Pitch',specno,1);
             if rob>=0
               count = count+1;
               wcount = wcount+4;
             end
             disp("phi_spike");
             specno=5;
             [phi,rob,BrFalse]=init_aircraft('Aircraft_Pitch',specno,1);
             if rob>=0
               count = count+1;
               wcount = wcount+5;
             end

             specno=6;     
             if count>max_spec_count
                 max_spec_count=count;
                 pval_best=pval;
                 disp("pval_best");
                 disp(pval_best);
                 if wcount>=max_wt
                     max_wt=wcount;             
                 end   
             elseif count==max_spec_count
                 if wcount>=max_wt
                     max_wt=wcount;
                     pval_best=pval;
                 end
             end
   elseif modelno==2
                 w1=1;w2=2;w3=3;
                 disp("phi_settle");
                 specno=1;
                 [phi,rob,BrFalse]=init_cc('cruise_ctrl',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+2;
                 end
                 
                 disp("phi_rise");
                 specno=2;
                 [phi,rob,BrFalse]=init_cc('cruise_ctrl',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+2;
                 end
                 disp("phi_conv");
                 specno=3;
                 [phi,rob,BrFalse]=init_cc('cruise_ctrl',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+2;
                 end

                 specno=4;
                 if count>max_spec_count
                     max_spec_count=count;
                     pval_best=pval;
                     disp("pval_best");
                     if wcount>=max_wt
                         max_wt=wcount;             
                     end   
                 elseif count==max_spec_count
                     if wcount>=max_wt
                         max_wt=wcount;
                         pval_best=pval;
                     end
                 end
     elseif modelno==7
                 w1=1;w2=2;w3=3;w4=4;
                 
                 disp("phi_settle");
                 specno=1;
                 [phi,rob,BrFalse]=init_quadrotor_full('Quad_sim',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+1;
                 end
                 
                 disp("phi_rise");
                 specno=2;
                 [phi,rob,BrFalse]=init_quadrotor_full('Quad_sim',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+2;
                 end
                 disp("phi_conv");
                 specno=3;
                 [phi,rob,BrFalse]=init_quadrotor_full('Quad_sim',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+3;
                 end
                 
                 disp("phi_ov");
                 specno=4;
                 [phi,rob,BrFalse]=init_quadrotor_full('Quad_sim',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+4;
                 end
                 specno=6;
                 if count>max_spec_count
                     max_spec_count=count;
                     pval_best=pval;
                     disp("pval_best");
                     if wcount>=max_wt
                         max_wt=wcount;             
                     end   
                 elseif count==max_spec_count
                     if wcount>=max_wt
                         max_wt=wcount;
                         pval_best=pval;
                     end
                 end            
     elseif modelno==1
                 w1=1;w2=2;w3=3;w4=1;
                 disp("phi_settle");
                 specno=1;
                 [phi,rob,BrFalse]=init_quadrotor('model',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+2;
                 end
                 
                 disp("phi_rise");
                 specno=2;
                 [phi,rob,BrFalse]=init_quadrotor('model',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+2;
                 end
                 disp("phi_conv");
                 specno=3;
                 [phi,rob,BrFalse]=init_quadrotor('model',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+2;
                 end
                 
                 disp("phi_ov");
                 specno=4;
                 [phi,rob,BrFalse]=init_quadrotor('model',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+1;
                 end
                 specno=6;
                 if count>max_spec_count
                     max_spec_count=count;
                     pval_best=pval;
                     disp("pval_best");
                     if wcount>=max_wt
                         max_wt=wcount;             
                     end   
                 elseif count==max_spec_count
                     if wcount>=max_wt
                         max_wt=wcount;
                         pval_best=pval;
                     end
                 end
     
     elseif modelno==4
                 w1=1;w2=2;w3=3;w4=4;
                 disp("phi_settle");
                 specno=1;
                 [phi,rob,BrFalse]=init_pendulum('Inverted_Pendulum',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+1;
                 end
                 
%                  disp("phi_rise");
%                  specno=2;
%                  [phi,rob,BrFalse]=init_pendulum('Inverted_Pendulum',specno,1);
%                  if rob>=0
%                    count = count+1;
%                    wcount = wcount+2;
%                  end                 
                 disp("phi_ov");
                 specno=4;
                 [phi,rob,BrFalse]=init_pendulum('Inverted_Pendulum',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+4;
                 end
                 disp("phi_spike");
                 specno=5;
                 [phi,rob,BrFalse]=init_pendulum('Inverted_Pendulum',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+5;
                 end

                 specno=6;
                 if count>max_spec_count
                     max_spec_count=count;
                     pval_best=pval;
                     disp("pval_best");
                     if wcount>=max_wt
                         max_wt=wcount;             
                     end   
                 elseif count==max_spec_count
                     if wcount>=max_wt
                         max_wt=wcount;
                         pval_best=pval;
                     end
                 end
    elseif modelno==5
                 w1=1;w2=2;w3=2;w4=3;
                 disp("phi_settle");
                 specno=1;
                 [phi,rob,BrFalse]=init_dcmotor('DCMotor',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+1;
                 end
                 
                 %disp("phi_rise");
                 %specno=2;
                 %[phi,rob,BrFalse]=init_dcmotor('DCMotor',specno,1);
                 %if rob>=0
                 %  count = count+1;
                 %  wcount = wcount+2;
                 %end                 
                 disp("phi_ov");
                 specno=4;
                 [phi,rob,BrFalse]=init_dcmotor('DCMotor',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+4;
                 end
                 disp("phi_spike");
                 specno=5;
                 [phi,rob,BrFalse]=init_dcmotor('DCMotor',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+5;
                 end

                 specno=6;
                 if count>max_spec_count
                     max_spec_count=count;
                     pval_best=pval;
                     disp("pval_best");
                     if wcount>=max_wt
                         max_wt=wcount;             
                     end   
                 elseif count==max_spec_count
                     if wcount>=max_wt
                         max_wt=wcount;
                         pval_best=pval;
                     end
                 end   
     
     
     elseif modelno==6
                 
                 w1=1;w2=2;w3=3;w4=4;w5=5;
                 disp("phi_settle");
                 specno=1;
                 [phi,rob,BrFalse]=init_f16('rct_concorde',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+1;
                 end
                 
                 disp("phi_rise");
                 specno=2;
                 [phi,rob,BrFalse]=init_f16('rct_concorde',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+2;
                 end
                 
                 disp("phi_conv");
                 specno=3;
                 [phi,rob,BrFalse]=init_f16('rct_concorde',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+3;
                 end
                 
%                  disp("phi_ov");
%                  specno=4;
%                  [phi,rob,BrFalse]=init_f16('rct_concorde',specno,1);
%                  if rob>=0
%                    count = count+1;
%                    wcount = wcount+4;
%                  end
%                  disp("phi_spike");
%                  specno=5;
%                  [phi,rob,BrFalse]=init_f16('rct_concorde',specno,1);
%                  if rob>=0
%                    count = count+1;
%                    wcount = wcount+5;
%                  end

                 if count>max_spec_count
                     max_spec_count=count;
                     pval_best=pval;
                     disp("pval_best");
                     if wcount>=max_wt
                         max_wt=wcount;             
                     end   
                 elseif count==max_spec_count
                     if wcount>=max_wt
                         max_wt=wcount;
                         pval_best=pval;
                     end
                 end
      elseif modelno==9
                 
                 w1=1;w2=2;w3=3;w4=4;w5=5;
                 disp("phi_settle");
                 specno=1;
                 [phi,rob,BrFalse]=init_robotarm('RobotArm_Full',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+1;
                 end
                 
                 disp("phi_conv");
                 specno=3;
                 [phi,rob,BrFalse]=init_robotarm('RobotArm_Full',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+3;
                 end
                 
                 disp("phi_ov");
                 specno=4;
                 [phi,rob,BrFalse]=init_robotarm('RobotArm_Full',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+4;
                 end
                 disp("phi_spike");
                 specno=5;
                 [phi,rob,BrFalse]=init_robotarm('RobotArm_Full',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+5;
                 end

                 if count>max_spec_count
                     max_spec_count=count;
                     pval_best=pval;
                     disp("pval_best");
                     if wcount>=max_wt
                         max_wt=wcount;             
                     end   
                 elseif count==max_spec_count
                     if wcount>=max_wt
                         max_wt=wcount;
                         pval_best=pval;
                     end
                 end
     elseif modelno==15
                 
                 w1=1;w2=2;w3=3;w4=4;w5=5;
                 disp("phi_settle");
                 specno=1;
                 [phi,rob,BrFalse]=init_heatex('heatex_sim',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+1;
                 end
                 
                 disp("phi_rise");
                 specno=2;
                 [phi,rob,BrFalse]=init_heatex('heatex_sim',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+2;
                 end
                 
                 disp("phi_conv");
                 specno=3;
                [phi,rob,BrFalse]=init_heatex('heatex_sim',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+3;
                 end
                 
                 disp("phi_ov");
                 specno=4;
                 [phi,rob,BrFalse]=init_heatex('heatex_sim',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+4;
                 end
                 disp("phi_spike");
                 specno=5;
                 [phi,rob,BrFalse]=init_heatex('heatex_sim',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+5;
                 end

                 if count>max_spec_count
                     max_spec_count=count;
                     pval_best=pval;
                     disp("pval_best");
                     if wcount>=max_wt
                         max_wt=wcount;             
                     end   
                 elseif count==max_spec_count
                     if wcount>=max_wt
                         max_wt=wcount;
                         pval_best=pval;
                     end
                 end
                 
       elseif modelno==11          
                 w1=1;w2=1;w3=1;w4=4;w5=5;
                 disp("phi_settle");
                 specno=1;
                 [phi,rob,BrFalse]=init_f14('F14',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+1;
                 end
                 
                 disp("phi_rise");
                 specno=2;
                 [phi,rob,BrFalse]=init_f14('F14',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+2;
                 end
                 
                 disp("phi_conv");
                 specno=3;
                [phi,rob,BrFalse]=init_f14('F14',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+3;
                 end
                 
                 if count>max_spec_count
                     max_spec_count=count;
                     pval_best=pval;
                     disp("pval_best >");
                     if wcount>=max_wt
                         max_wt=wcount;             
                     end   
                 elseif count==max_spec_count
                     if wcount>=max_wt
                         max_wt=wcount;
                         pval_best=pval;
                         disp("pval_best = ");
                     end
                 end
                 
       elseif modelno==14          
                 w1=1;w2=2;w3=3;w4=4;w5=5;
                 disp("phi_settle");
                 specno=1;
                 [phi,rob,BrFalse]=init_airframe('scdairframectrl',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+1;
                 end
                 
                 disp("phi_rise");
                 specno=2;
                 [phi,rob,BrFalse]=init_airframe('scdairframectrl',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+2;
                 end
                 
                 disp("phi_conv");
                 specno=3;
                [phi,rob,BrFalse]=init_airframe('scdairframectrl',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+3;
                 end
                 
                 disp("phi_spike");
                 specno=5;
                [phi,rob,BrFalse]=init_airframe('scdairframectrl',specno,1);
                 if rob>=0
                   count = count+1;
                   wcount = wcount+5;
                 end
                 
                 if count>max_spec_count
                     max_spec_count=count;
                     pval_best=pval;
                     disp("pval_best");
                     if wcount>=max_wt
                         max_wt=wcount;             
                     end   
                 elseif count==max_spec_count
                     if wcount>=max_wt
                         max_wt=wcount;
                         pval_best=pval;
                     end
                 end
           
    end
 end     