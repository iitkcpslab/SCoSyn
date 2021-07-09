
   %global index;
   %global pval;
   %global newfile;
   %global modelno;
function [pval,sind]=init_values(newfile,modelno)  
     addpath models;
     addpath src;
     addpath utils;

    lenp=3; 
    if modelno==1
      sind={'Gain1';'Gain';'Gain2'};
      pval=[5,1,10]; 
      %lenp=3; 
      %dlmwrite('dataset.csv',{transpose(1),transpose(2),transpose(20),transpose(old_rob)},'delimiter',',','-append'); 
    elseif modelno==2
      sind={'Gain1';'Gain';'Gain2'};
      pval=[0.5,0.1,1];
      %lenp=3; 
      %dlmwrite('dataset.csv',{transpose(0.1),transpose(0.2),transpose(5),transpose(old_rob)},'delimiter',',','-append'); 
    elseif modelno==7 
      %init_vars
      %global Q;
      sind={'Kp','Ki','Kd','Kp1','Ki1','Kd1','Kp2','Ki2','Kd2','Kp3','Ki3','Kd3','Kp4','Ki4','Kd4','Kp5','Ki5','Kd5'};
      %pval=[Q.Kp_x,Q.Ki_x,Q.Kd_x,Q.Kp_y,Q.Ki_y,Q.Kd_y,Q.Kp_z,Q.Ki_z,Q.Kd_z,Q.Kp_phi,Q.Ki_phi,Q.Kd_phi,Q.Kp_theta,Q.Ki_theta,Q.Kd_theta,Q.Kp_psi,Q.Ki_psi,Q.Kd_psi];       
      %pval=[0.1,0,-0.16,0.1,0,-0.16,4,0,-4,4.5,0,0,4.5,0,0,10,0,0];
      pval=[.1,0,-.1,.1,0,-.1,4,0,-4,4.5,0,0,4.5,0,0,10,0,0];
      %pval=[.1,.1,-1,.1,.1,-1,1.5625,.1,-6.4072,4.5,0,0,4.5,0,0,10,0,0];%all
      %lenp=18;
    elseif modelno==3
        sind={'Gain1';'Gain';'Gain2'};
        pval=[0.495,0.348,0.115];
        %lenp=3; 
    elseif modelno==4
        sind={'Gain1';'Gain';'Gain2'};
        pval=[41.76,65.58,3.87];
        %lenp=3; 
    elseif modelno==5
        sind={'Gain1';'Gain';'Gain2'};
        pval=[20,50,1.65];
        %lenp=3; 
    elseif modelno==6
        sind={'Kf';'Ki';'Kp';'Kq';'RollOff'};
        pval=[-0.02233,-0.0297,-0.009821,-0.2843,4.81]; %init
        %pval=[-0.0051,-0.0167,-0.009821,-0.2843,4.81]; %SAT
        %lenp=3; 
    elseif modelno==8
        sind={'Gain1';'Gain2';'Gain3';'Gain4';'Gain5';'Gain6';'Gain7';'Gain8';'Gain9';'Gain10';'Gain11';'Gain12';'Gain13';'Gain14';'Gain15';'Gain16';'Gain17';'Gain18';'Gain19';'Gain20';'Gain21';'Gain22';'Gain23';'Gain24';'Gain25';'Gain26';'Gain27';'Gain28';'Gain29';'Gain30';'Gain31';'Gain32';'Gain33';'Gain34';'Gain35';'Gain36'};
        pval={2000,7500,50,2000,7500,50,2750,10000,75,3500,12500,100,3500,12500,100,3500,12500,100,2000,7500,50,2000,7500,50,2750,10000,75,3500,12500,100,3500,12500,100,3500,12500,100};
    elseif modelno==9
        sind={'Kp1','Ki1','Kd1','Kp2','Ki2','Kd2'};
        pval=[50,2,0.5,50,1,2];
        %pval=[11.76,10.19,10,17.40,19.28,10,12.40,11.69,10,11.09,9.18,10,12.27,11.18,10,12.06,10.84,10];
        %lenp=36; 
    elseif modelno==10
        sind={'COF1';'COF2'};
        pval=[-20,2];
        %lenp=3;
     elseif modelno==11
        sind={'PIC';'ASF';'PRF'};
        pval=[-3.864,0.677,0.8156];
        %lenp=3;
    elseif modelno==12
        SOF= [2.211 -0.31 -0.00336 0.7854 -0.01518;
             -0.1923  -1.291 0.0182  -0.08502 -0.1195;
             -0.01936  -0.01205 -1.895 -0.004121 0.06797];
        
        sind={'Kp1','Ki1','Kp2','Ki2','Kp3','Ki3'};
        pval=[1.04,2.07,-0.0991,-1.35,0.137,-2.2];
    elseif modelno==13
        sind={'Ki1';'Kp1';'Ki2';'Kp2'};
        pval=[0.02,0.015,1.82,0.244];
        %lenp=3;
    elseif modelno==14
        sind={'Kaz';'Kq'};
        pval=[0.00027507,2.7717622];
        %lenp=3;
     elseif modelno==15
        sind={'Kff';'Kfb'};
        pval=[1,1];
    elseif modelno==16
        sind={'Gain1';'Gain';'Gain2'};
        %pval=[1.414,0.493,0.126];
        pval=[2.034,1.022,0.144];
        %pval=[0.714,0.056,2.237];
        %lenp=3; 
    end
    default_val=pval;
    lenp=length(pval);
       open_system(newfile);
       b = find_system(newfile,'Type','Block');  
        for i=1:length(b)
           prefix = strsplit(char(b(i)),'/');
           if length(prefix)>2
               continue;
           end

           for j=1:lenp
              if strcmp(prefix(2),sind(j))
                handle(j) = get_param(b{i},'handle');
                block = get(handle(j));
              end
           end
        end  
           %{
           if strcmp(prefix(2),sind(1))
              handle1 = get_param(b{i},'handle');
              block1 = get(handle1);
           end    
           if strcmp(prefix(2),sind(2))
              handle2 = get_param(b{i},'handle');
              block2 = get(handle2);
           end    
           if strcmp(prefix(2),sind(3))
              handle3 = get_param(b{i},'handle');
              block3 = get(handle3);
           end    
           %}
        %end
        for j=1:lenp
          %disp(j);  
          block = get(handle(j));  
          if block.BlockType=="Saturate"
             set_param(handle(j),'UpperLimit',num2str(pval(j)));
          elseif block.BlockType=="TransferFcn"
             %val=['[1 ' num2str(pval(j)) ' 23.04]'];    
             %set_param(handle(j),'Denominator',val);
             
             val=num2str(pval(j));    
             set_param(handle(j),'Numerator',val);
          elseif block.BlockType=="Constant"
             set_param(handle(j),'Value',num2str(pval(j)));
          else
             set_param(handle(j),block.BlockType,num2str(pval(j)));
          end
        end  
        %set_param(handle2,block2.BlockType,num2str(pval(2)));
        %set_param(handle3,block3.BlockType,num2str(pval(3)));
        save_system(newfile);
    close_system(newfile);
end  
