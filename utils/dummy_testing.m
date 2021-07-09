   addpath f16;
   newfile='rct_concorde';
   sind={'RollOff'};
   index=1;
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
                  deval=str2num(block.Denominator);
                  newval=deval(2);
          else
             newval=get_param(handle,block.BlockType); 
             newval=str2num(newval);
          end
       %newval=get_param(handle,block.BlockType);
       
        Fro = ['[1 ' num2str(newval) ' 23.04]']); % parametric transfer function
        set_param(block.Handle,'Denominator',Fro);   % use Fro to parameterize "RollOff" block
    
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
          disp("****************************************");
          disp(" the model is fixed in "+c+"iterations");
          disp(" the final value of the parameters is ");
          disp(pval);
          disp("*******************************************");
          return;
       end 
   