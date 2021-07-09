function J = pidtest(parms)
modelno=9;
specno=6;
%sind={'Gain1';'Gain';'Gain2'};
%sind={'Kp1','Ki1','Kd1','Kp2','Ki2','Kd2'};
if modelno==1
      sind={'Gain1';'Gain';'Gain2'};
    elseif modelno==2
      sind={'Gain1';'Gain';'Gain2'};
    elseif modelno==7 
        sind={'Kp','Ki','Kd','Kp1','Ki1','Kd1','Kp2','Ki2','Kd2','Kp3','Ki3','Kd3','Kp4','Ki4','Kd4','Kp5','Ki5','Kd5'};
    elseif modelno==3
        sind={'Gain1';'Gain';'Gain2'};
    elseif modelno==4
        sind={'Gain1';'Gain';'Gain2'};
    elseif modelno==5
        sind={'Gain1';'Gain';'Gain2'};
    elseif modelno==6
        sind={'Kf';'Ki';'Kp';'Kq';'RollOff'};
    elseif modelno==8
        sind={'Gain1';'Gain2';'Gain3';'Gain4';'Gain5';'Gain6';'Gain7';'Gain8';'Gain9';'Gain10';'Gain11';'Gain12';'Gain13';'Gain14';'Gain15';'Gain16';'Gain17';'Gain18';'Gain19';'Gain20';'Gain21';'Gain22';'Gain23';'Gain24';'Gain25';'Gain26';'Gain27';'Gain28';'Gain29';'Gain30';'Gain31';'Gain32';'Gain33';'Gain34';'Gain35';'Gain36'};
    elseif modelno==9
        sind={'Kp1','Ki1','Kd1','Kp2','Ki2','Kd2'};
    elseif modelno==10
        sind={'COF1';'COF2'};
     elseif modelno==11
        sind={'PIC';'ASF';'PRF'};
    elseif modelno==12
        sind={'Kp1','Ki1','Kp2','Ki2','Kp3','Ki3'};
    elseif modelno==13
        sind={'Ki1';'Kp1';'Ki2';'Kp2'};
    elseif modelno==14
        sind={'Kaz';'Kq'};
     elseif modelno==15
        sind={'Kff';'Kfb'};
     end
    
%newfile='model';
%newfile='RobotArm_Full';
%newfile='cruise_ctrl';
 if modelno==1
            quad_vars;
            newfile='model';
        elseif modelno==2
            newfile='cruise_ctrl';
        elseif modelno==3
            newfile='Aircraft_Pitch';
        elseif modelno==4
            newfile='Inverted_Pendulum';
        elseif modelno==5
            dcm_vars;
            newfile='DCMotor';
        elseif modelno==7
            init_vars;
            newfile='Quad_sim';
        elseif modelno==6
            addpath f16;
            newfile = 'rct_concorde';
        elseif modelno==8
            newfile = 'walkingRobot';
        elseif modelno==9   
            newfile='RobotArm_Full';
        elseif modelno==10
            newfile='Car_sliding';
         elseif modelno==11
            newfile='F14';
        elseif modelno==12
            newfile='rct_helico';
        elseif modelno==13
            newfile='scdcascade';
        elseif modelno==14
            newfile='scdairframectrl';
        elseif modelno==15
            newfile='heatex_sim';
        end

pval=parms;
%pval=get_values(newfile,sind);
quad_vars;
for i=1:length(pval)
   set_values(newfile,i,sind,pval);
end

[phi,rob,BrFalse]=initialize(modelno,specno);
%[phi,rob,BrFalse] = init_quadrotor(newfile,6,1);
%[phi,rob,BrFalse] = init_robotarm(newfile,6,1);


J=-1*rob;



 if specno==6 %%this is for verbosity when running all specs conjunct    
     disp("****************************************");
     disp("****************************************");
     disp("****************************************");
     disp("****************************************");
     
     disp("pval is :");
     %newval=get_values(newfile,sind);
     %disp(newval);
     %disp(pv2);
     %disp(pv3);
     
     [count,wcount]=maximal_specifications(modelno,pval);
     disp("max+spec_count ");
     disp(count);
     disp("maximum weight is ");
     disp(wcount);
     disp("****************************************");
     disp("****************************************");
     disp("****************************************");
     disp("****************************************");
 end     

 dlmwrite('costfcn.csv',{rob,pval,count,wcount},'delimiter',',','-append');
toc
disp("pso time")
if rob>=0
    return;
end
%[phi,rob,BrFalse]=initialize(1,1);

%{
s = tf('s');
K = parms(1) + parms(2)/s + parms(3)*s/(1+.001*s);
Loop = series(K,G);
ClosedLoop = feedback(Loop,1);
t = 0:dt:20;
[y,t] = step(ClosedLoop,t);

CTRLtf = K/(1+K*G);
u = lsim(K,1-y,t);

Q = 1;
R = .001;
J = dt*sum(Q*(1-y(:)).^2 + R*u(:).^2)
%}
