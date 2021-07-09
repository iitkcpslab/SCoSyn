
%% main script for the ToolBox
%% run it and select the modelno and specno

clear all;
close all;
addpath breach;
InitBreach;
setenv PYTHON 'LD_LIBRARY_PATH="" python3';
%%export LD_PRELOAD=/lib/x86_64-linux-gnu/libexpat.so.1
warning off;
addpath models;
addpath src;

disp("********* SELECT MODEL ******************");
disp("select 1 for Quadcopter-SISO");
disp("select 2 for Cruise Control");
disp("select 3 for Aircraft Pitch");
disp("select 4 for Inverted Pendulum");
disp("select 5 for DC Motor");
disp("select 6 for AutoPilot for Pass Jet");
disp("select 7 for Quadcopter-MIMO");
disp("select 9 for Robot Arm");
disp("select 11 for DPC");
disp("select 14 for Airframe")
disp("select 15 for Heatex");
disp("select 16 for Comparison with [18]");
disp("***************************************");

modelno=input('enter the model number'); % select model number
disp(" ");
disp("********* SELECT SPECIFICATION ************");
disp("select 1 for settling time");
disp("select 2 for rise time");
disp("select 3 for convergence");
disp("select 4 for overshoot");
disp("select 5 for smoothness")
disp("select 6 for Conjunct of all specs")
disp("*******************************************");

specno=input('enter the specification number');  % select spec no

disp("---------------------------------------");
disp("selected model is : "+modelno);
disp("---------------------------------------");

disp("--------------------------------------");
disp("selected specification is phi : "+specno);
disp("---------------------------------------");

 
%global newfile;

init_flag=1; % this disables debugging mode
verbosity=1; % enable this when running on set of specifications

%specno=2;
%modelno=1;
tic

% if init_flag==1
%         %clc;
%         clear all;
        delete 'dataset.csv';
        delete 'mylog.out';
%        close all;
        %modelno=1;
        %specno=2;
        mode=1;
        addpath models;
        addpath src;
        addpath utils;

        if modelno==1
            quad_vars;
            newfile='model';
        elseif modelno==2
            newfile='cruise_ctrl';
        elseif modelno==3
            newfile='Aircraft_Pitch';
        elseif modelno==4
            pend_vars;
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
         elseif modelno==16
            newfile='demo3';
        end

        max_wt=0;
        old_rob=0;
        new_rob=0;
        max_rob=log(0);

        %% SIMULATED ANNEALING  
        iter=10;
        optimal_rob=1;
        alpha=0.5;
        c=1;
        k=1;

        % storing the old robustness valueglobal old_rob;

        alpha_old=0;
        % we accept alpha wih some probability
        %global pval;
        %global id;
        [default_val,sind]=init_values(newfile,modelno);
        %pval=[0.1,0.5,1];
        %init_values;
        %return;
        max_spec_count=0;
        pval_best=default_val;
        pval=default_val;
        
%end        

        [phi,rob,BrFalse]=initialize(modelno,specno);
        old_rob=rob;
        %tic
        id=find_parameter(modelno,specno);
        %toc
        %disp("time to find parameter");

        %for index=[id]
        index=id(1);
         disp("#############################");
         disp(" tuning ")
         disp(index);
         disp("#############################");
         %for alpha = [0.8,1.1,0.9,0.5,0.4,1.5]
           %while abs(alpha-alpha_old)>0.1

        %disp(pval);
        %return;
        %init_values;
        
        %% here exps for diff val of delta
        alpha_l = 0.5 ;  alpha_r = 1.5 ;
        %alpha_l=0.8; alpha_r=1.2;
        echo off;
        diary mylog.out;
        disp("$$$$$$ default value $$$$$$$");
        disp(default_val);
        %newval=default_val;

toc
disp("initialisation time");
tic
while 1   
   %init_values;      
   %for k=1:10
   %total=c+k+1;
   toc
   disp("time taken");
   if abs(alpha_l-alpha_r)<0.01
       alpha_l=-0.5;
       alpha_r=4;
   end
   disp("------------------ITERATION");
   disp(c);
   disp("----------------------------");
   
   %[status,data]=system(['python3 src_dst.py ' char(newfile) '.xml ' char(sind(index))]);
   %data=parse_data(data);
   open_system(newfile);
   b = find_system(newfile,'Type','Block');  
    for i=1:length(b)
       prefix = strsplit(char(b(i)),'/');
       if length(prefix)>2
           continue;
       end

       if strcmp(prefix(2),sind(index))
          handle = get_param(b{i},'handle');
          block = get(handle);
       end    
    end
       
            
          if block.BlockType=="Saturate"
             %set_param(handle(j),'UpperLimit',num2str(pval(j)));
             newval=get_param(handle,'UpperLimit');
             newval=str2num(newval);
          elseif block.BlockType=="TransferFcn"
             %deval=str2num(block.Denominator);
             %newval=deval(2);
             deval=str2num(block.Numerator);
             newval=deval;
          else
             newval=get_param(handle,block.BlockType); 
             newval=str2num(newval);
          end
       %newval=get_param(handle,block.BlockType);
       
    
       if  any(pval>default_val*100) || any(pval<default_val*0.01)|| k>30 
           [default_val,sind]=init_values(newfile,modelno);
           %make this newval
           newval=default_val(index);
           k=1;
           alpha_l = (1+alpha_l)/2;
           alpha_r = (1+alpha_r)/2;
       end
       
       pval(index)=newval*alpha_l;
       %disp("#####");
       %disp(newval);
      
       set_values(newfile,index,sind,pval);
       [phi,rob,BrFalse]=initialize(modelno,specno);
       rob_l=rob;
       if rob_l>=0
          disp("*************************************************");
          disp(" the controller is synthesized in "+c+"iterations");
          disp(" the final value of the parameters is ");
          disp(pval);
          disp("*************************************************");
          toc
          disp("time for Whole CS Algo");
          close all;
          return;
       end 
    

       pval(index)=newval*alpha_r;
       set_values(newfile,index,sind,pval);
       [phi,rob,BrFalse]=initialize(modelno,specno);
       rob_r=rob;
       if rob_r>=0
          disp("*************************************************");
          disp(" the controller is synthesized in "+c+"iterations");
          disp(" the final value of the parameters is ");
          disp(pval);
          disp("*************************************************");
          toc
          disp("time for Whole CS Algo");
          close all;
          return;
       end 
         
       if rob_r==rob_l
           [default_val,sind]=init_values(newfile,modelno);
           %make this newval
           newval=default_val(index);
           k=1;
           alpha_l=alpha_l-0.1;
           alpha_r=alpha_r+0.1;
           %alpha_l = (1+alpha_l)/2;
           %alpha_r = (1+alpha_r)/2;
           c=c+1;
           continue;
       end
       
           
       %disp(new_rob);
       if rob_r>rob_l
          max_rob=rob_r;
          new_rob=rob_l;
          newval=newval*alpha_r;
          while max_rob>new_rob*0.95 && max_rob-new_rob>1e-4
            pval(index)=newval*alpha_r;
            newval=pval(index);
            set_values(newfile,index,sind,pval);
            [phi,rob,BrFalse]=initialize(modelno,specno);
            new_rob=max_rob;
            max_rob=rob;
            if max_rob>=0
                disp("*************************************************");
                disp(" the controller is synthesized in "+c+"iterations");
                disp(" the final value of the parameters is ");
                disp(pval);
                disp("*************************************************");
                toc
                disp("time for Whole CS Algo");
                close all;
                return;
            end
            
               %if  any(pval>default_val*50) || any(pval<default_val*0.05)
               %    break;
               %end
            c=c+1;
            k=k+1;
          end
       elseif rob_r<rob_l
          max_rob=rob_l;
          new_rob=rob_r;
          newval=newval*alpha_l;
          while max_rob>new_rob*0.95 && max_rob-new_rob>1e-4 
             %&& max_rob-new_rob>0.0001
            pval(index)=newval*alpha_l;
            newval=pval(index);
            set_values(newfile,index,sind,pval);          
            [phi,rob,BrFalse]=initialize(modelno,specno);
            new_rob=max_rob;
            max_rob=rob;
            if max_rob>=0
                disp("*************************************************");
                disp(" the controller is synthesized in "+c+"iterations");
                disp(" the final value of the parameters is ");
                disp(pval);
                disp("*************************************************");
                toc
                disp("time for Whole CS Algo");
                close all;             
                return;
            end
            
               %if  any(pval>default_val*50) || any(pval<default_val*0.05)
               %    break;
               %end
            c=c+1;
            k=k+1;
          end
       end
       
       %dlmwrite('dataset.csv',{transpose(pval(1)),transpose(pval(2)),transpose(pval(3)),transpose(new_rob)},'delimiter',',','-append'); 
       if rob>=0
          disp("*************************************************");
          disp(" the controller is synthesized in "+c+"iterations");
          disp(" the final value of the parameters is ");
          disp(pval);
          disp("*************************************************");
          toc
          disp("time for Whole CS Algo");
          close all;
          return;
       end  
       close_system(newfile);
     %end
   
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
     
     [max_spec_count,pval_best,max_wt]=maximal_specifications(modelno,pval,max_spec_count,pval_best,max_wt);
     disp("max+spec_count ");
     disp(max_spec_count);
     disp("maximum weight is ");
     disp(max_wt);
     disp("****************************************");
     disp("****************************************");
     disp("****************************************");
     disp("****************************************");
 end     

     
     %alpha_old=alpha;
     %tic
     id=find_parameter(modelno,specno);
     %toc
     %disp("time to find the parameter")
     if id==-1
          disp("*************************************************");
          disp(" the controller is synthesized in "+c+"iterations");
          disp(" the final value of the parameters is ");
          disp(pval);
          disp("*************************************************");
          toc 
          disp("time for Whole CS Algo");
          close all;
          return;
      end
     index=id(1);
     disp("*******************************************");
     disp(" index chosen is "+index); 
     disp("*******************************************");
     %c=c+10;
     c=c+1;
     k=k+1;
end
toc
disp("time for Whole CS Algo");

diary off;
close all;
close_system(newfile);

function data=parse_data(data)
   data = erase(data,"[");
   data = erase(data,"]");
   data = split(data,", ");
   data = erase(data,"'");
   data=strip(data);
end

