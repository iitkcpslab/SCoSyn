%% This file is a demo parameter tuning file
% One of the assumption that we make is that the parameters are not some 
% variables but constants. For instance in case of suspect signal Eii, the
% source block of Eii has parameter "1/Iei". Since the value of Iei is 
% 0.02, we replace the parameter of source block by 50 (i.e. 1/0.02).

%% Another imporant point is the way we generate the "newval" (v) using 
% the "val" (p.val). We can use various functions of our choice to 
% generate the newvalue using val. For instance, we can use stochastic 
% techniques i.e. P(newval|val). Here for the Autotrans model and 
% specification phi1, we propose a very basic version of the Proposer 
% Scheme "PS" function for the sake of simplicity.
clc;
clear all;

delete 'dataset.csv';
delete 'mylog.out';
close all;

 %global max_spec_count;
 %global pval_best;
 
%global newfile;
modelno=2;
specno=3;


mode=1;

if modelno==3
    newfile='Quad_sim';
elseif modelno==4
    newfile='Aircraft_Pitch';
elseif modelno==1
    newfile='model';
elseif modelno==2
    newfile='cruise_ctrl';
elseif modelno==5
    newfile='Inverted_Pendulum';
elseif modelno==6
    newfile='DCMotor';
elseif modelno==7
    newfile='suspmod';
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
%init_values;
%return;
[phi,rob,BrFalse]=initialize(modelno,specno);
old_rob=rob;
id=bug_localisation(modelno,specno);

 
%for index=[id]
index=id(1);
 disp("#####################");
 disp(" tuning ")
 disp(index);
 disp("####################");
 %for alpha = [0.8,1.1,0.9,0.5,0.4,1.5]
   %while abs(alpha-alpha_old)>0.1

base=1;
range=0;
%global default_val;

%disp(pval);
%return;
%init_values;
alpha_l = 0.5 ; 
%alpha_l=0.8;
alpha_r = 1.5 ;
%alpha_r=1.2;
max_spec_count=0;
pval_best=default_val;
pval=default_val;
echo off;
diary mylog.out;
disp("$$$$$$ default value $$$$$$$");
disp(default_val);

while 1   
   %init_values;   
   
   %for k=1:10
   %total=c+k+1;
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
    
       newval=get_param(handle,block.BlockType);
       newval=str2num(newval);
    
       
       if any(pval>default_val*10) || any(pval<default_val*0.1)||  k>30
           [default_val,sind]=init_values(newfile,modelno);
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
          disp("****************************************");
          disp(" the model is fixed in "+c+"iterations");
          disp(" the final value of the parameters is ");
          disp(pval);
          disp("*******************************************");
          return;
       end 
    

       pval(index)=newval*alpha_r;
       set_values(newfile,index,sind,pval);
       [phi,rob,BrFalse]=initialize(modelno,specno);
       rob_r=rob;
       if rob_r>=0
          disp("****************************************");
          disp(" the model is fixed in "+c+"iterations");
          disp(" the final value of the parameters is ");
          disp(pval);
          disp("*******************************************");
          return;
       end 
               
       %disp(new_rob);
       if rob_r>rob_l
          max_rob=rob_r;
          new_rob=rob_l;
          newval=newval*alpha_r;
          while max_rob-new_rob > 0.1 
            pval(index)=newval*alpha_r;
            set_values(newfile,index,sind,pval);
            [phi,rob,BrFalse]=initialize(modelno,specno);
            new_rob=max_rob;
            max_rob=rob;
            if max_rob>0
                disp("****************************************");
                disp(" the model is fixed in "+c+"iterations");
                disp(" the final value of the parameters is ");
                disp(pval);
                disp("*******************************************");
                return;
            end
            c=c+1;
            k=k+1;
          end
       else
          max_rob=rob_l;
          new_rob=rob_r;
          newval=newval*alpha_l;
          while max_rob-new_rob > 0.1 
            pval(index)=newval*alpha_l;
            set_values(newfile,index,sind,pval);
            [phi,rob,BrFalse]=initialize(modelno,specno);
            new_rob=max_rob;
            max_rob=rob;
            if max_rob>0
                disp("****************************************");
                disp(" the model is fixed in "+c+"iterations");
                disp(" the final value of the parameters is ");
                disp(pval);
                disp("*******************************************");
                return;
            end
            c=c+1;
            k=k+1;
          end
       end
       
       dlmwrite('dataset.csv',{transpose(pval(1)),transpose(pval(2)),transpose(pval(3)),transpose(new_rob)},'delimiter',',','-append'); 
       if rob>=0
          disp("****************************************");
          disp(" the model is fixed in "+c+"iterations");
          disp(" the final value of the parameters is ");
          disp(pval);
          disp("*******************************************");
          return;
       end  
       close_system(newfile);
     %end
     
     count=0;
     disp("****************************************");
     disp("****************************************");
     disp("****************************************");
     disp("****************************************");
     
     [max_spec_count,pval_best,max_wt]=maximal_specifications(modelno,pval,max_spec_count,pval_best,max_wt);
     disp("max+spec_count ");
     disp(max_spec_count);
     disp("maximum weight is ");
     disp(max_wt);
     disp("****************************************");
     disp("****************************************");
     disp("****************************************");
     disp("****************************************");
     

     %alpha_old=alpha;
     id=bug_localisation(modelno,specno);
     index=id(1);
     disp("****************************************");
     disp(" index chosen is "+index); 
     disp("*******************************************");
     %c=c+10;
     c=c+1;
     k=k+1;
end

diary off;
close_system(newfile);

function data=parse_data(data)
   data = erase(data,"[");
   data = erase(data,"]");
   data = split(data,", ");
   data = erase(data,"'");
   data=strip(data);
end

