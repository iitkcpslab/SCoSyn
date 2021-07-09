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

%modelno=1; % select model no

disp("*************************");
disp("select 1 for Automatic transmission");
disp("select 2 for Abstract furl control");
disp("select 3 for Neural Network based maglev");
disp("select 4 for Anti Lock braking system");
disp("select 5 for helicopter")
disp("*******************************");

modelno=input('enter the model number'); % select model number
specno=input('enter the specification number');  % select spec no

% if modelno==1
%    newfile='Autotrans_shift_expanded';
% elseif modelno==2
%    newfile='AbstractFuelControl_expanded';
% elseif modelno==3
%    newfile='narmamaglev_expanded';
% elseif modelno==4
%    newfile='absbrake_expanded';
% elseif modelno==5
%    newfile='helicopter_expanded';
% else
%     disp("wrong model selected");
% end
disp("---------------------------------------");
disp("selected model is"+newfile);
disp("---------------------------------------");

disp("--------------------------------------");
disp("selected specification is phi"+specno);
disp("---------------------------------------");

expand_subsystem; % flattening script
bug_localisation;  % bug localisation script

% [Q, R, E] = qr(N,0);
% sing=svds(N,5);
% diagr = abs(diag(R));
 %return;

old_rob=0;
newrob=0;
max_rob=log(0);

global newfile;
if  specno==11
    index=2;
else
    index=1;
end

%index=1; % selecting the signal from the sind set
%index=2; % for phi2,phi11
[status,data]=system(['python3 src_dst.py ' char(newfile) '.xml ' char(sind(index))]);
data=parse_data(data);

%global handle;
%global block;
 
%% SIMULATED ANNEALING  
iter=10;
optimal_rob=1;
alpha=0.5;
c=0;
old_rob=falsif_pb.obj_best; % storing the old robustness valueglobal old_rob;
% we accept alpha wih some probability
    
alpha_old=0;
%for alpha = [0.5,0.8,1.5,1.2]
while abs(alpha-alpha_old)>0.1
    %% below we mention the default parameter value
    %% identified the case of a specification
    %% NOTE- spec 13,14,15 are for regression testing
   if specno==1 || specno==2 || specno==3 ||specno==13 || specno==16 ||specno == 17
       newval=50;
   %elseif specno==2
   %    newval=6.28;
   elseif specno==5 || specno==7 || specno==15
       newval=0.10;
   elseif specno==4 || specno==6 || specno==14
       newval=9.55;
   elseif specno==8 | specno==9
       newval=15;
   elseif specno==10
       newval=1;
   elseif specno==11
       newval=100;
   elseif specno==12
       newval=10;
   end


   %newval=50; % for phi1   7 iterations , final val: 0.7812 ie mean
   %Iei=1.2, for phi3 9 iterations final val: 0.2
   %newval=6.28; % for phi2 2 iterations, final val :3.14 Rw=0.5
   
   %newval=0.10; % for phi7   22 iterations, final val: 0.0875
   % for phi5 7 iterations, final val=0.0016
   %newval=9.55; % for phi4 & phi6   19 iterations, final val: 0.96
   
   %newval=15; % for phi8, 4 iterations, final val: 1.87
   %newval=15; % for phi9, 3 iterations, final val:3.75
   
   %newval=1; %for phi10  4 iterations, final val:0.125
   %newval=100; % for phi11 , 2 iterations, final val=50
   %newval=10; % for phi12   
   
 for k=1:iter
   total=c+k+1;
   disp("------------------ITERATION");
   disp(total);
   disp("----------------------------");
  
   open_system(newfile);
   b = find_system(newfile,'Type','Block');  
    for i=1:length(b)
       prefix = strsplit(char(b(i)),'/');
       if length(prefix)>2
           continue;
       end

       if strcmp(prefix(2),data)
          %ph = get_param(b{i},'PortHandles');
          handle = get_param(b{i},'handle');
          block = get(handle);
       elseif length(data)==2 && strcmp(prefix(2),data(2))
           %ph = get_param(b{i},'PortHandles');
           handle = get_param(b{i},'handle');
           block = get(handle);
       end
       
     end
  
       %val=block.(block.BlockType);
       %disp("current value");
       %disp(val);
       %val=str2num(val);
       %for i=1:5
       %newval=PS(val,x,y,z);
  
       newval=newval*alpha;
       disp("#####");
       disp(k);
       disp(newval);
       if specno==11
          set_param(handle,'Numerator',num2str(newval)); %for phi11
       else
          set_param(handle,block.BlockType,num2str(newval));
       end
       save_system(newfile);
       close_system(newfile);
       disp("changing parameter to");
       disp(newval);
       
       if modelno==1
          init_autotrans;
       elseif modelno==2
          init_afc;
       elseif modelno==3
          init_narmamaglev;
       elseif modelno==4
          init_absbrake;
       elseif modelno==5
          init_helicopter;
       end
       %init_autotrans;
       %init_afc;
       %init_absbrake;
       %init_narmamaglev;
       %init_helicopter;
       %% checking whether the robustness has improved
       new_rob=falsif_pb.obj_best;
       disp(new_rob);
       if new_rob>max_rob
          max_rob=new_rob;
       end
       
       if falsif_pb.obj_best>=0
          disp("****************************************");
          disp(" the model is fixed in "+total+"iterations");
          disp(" the final value of the parameter is "+newval); 
          disp("*******************************************");
          return;
       end       
   end
   alpha_old=alpha;
   if max_rob>old_rob
      alpha=(1+alpha)/2;
   else
      alpha=1+alpha;
   end
   c=c+10;
end
close_system(newfile);

%%%%^ VV Imp below code
%{
mdl = 'sldemo_househeat';
in = Simulink.SimulationInput(mdl);

Modify block parameter.

in = in.setBlockParameter('sldemo_househeat/Set Point','Value','300');

Simulate the model.

out = sim(in)
%}
%%%%


%B = BreachSimulinkSystem(newfile);

%phi1 = STL_Formula('phi1', '(alw (speed[t]<vmax)) and (alw (RPM[t]<rpm_max))');
%phi1 = set_params(phi1,{'vmax', 'rpm_max'}, [160 4500]);

%BrSensi = B.copy();
%params = {'Iei', 'Rw','Rfd'};
%ranges = [ 0.01 0.1; 0.99 1.01; 3 4];
%BrSensi.SensiSpec(phi1, params, ranges);
function data=parse_data(data)
   data = erase(data,"[");
   data = erase(data,"]");
   data = split(data,", ");
   data = erase(data,"'");
   data=strip(data);
end

% %function newval=PS(val,x,y,z)
%    R = containers.Map(y,z);
%    E = containers.Map(x,y);
%    T = containers.Map(y,x);
%    
%    
% end