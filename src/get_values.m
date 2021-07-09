% 
%    global index;
%    global pval;
%    global newfile;
%    global sind;

 function newval=get_values(newfile,sind) 
   open_system(newfile);
   b = find_system(newfile,'Type','Block');  
    for i=1:length(b)
       prefix = strsplit(char(b(i)),'/');
       if length(prefix)>2
           continue;
       end
       
           for j=1:length(sind)
              if strcmp(prefix(2),sind(j))
                handle(j) = get_param(b{i},'handle');
                %block = get(handle(j));
              end
           end

%        if strcmp(prefix(2),sind(1))
%           handle1 = get_param(b{i},'handle');
%           block = get(handle1);
%        end
%        if strcmp(prefix(2),sind(2))
%           handle2 = get_param(b{i},'handle');
%        end
%        if strcmp(prefix(2),sind(3))
%           handle3 = get_param(b{i},'handle');
%        end
    end
       
       newval=[];
       for j=1:length(sind)
          block = get(handle(j)); 
          if block.BlockType=="Saturate"
             newval(j)=get_param(handle(j),'UpperLimit');
          else
             newval(j)=get_param(handle(j),block.BlockType); 
          end
       end
       %pv1=get_param(handle1,block.BlockType);
       %pv2=get_param(handle2,block.BlockType);
       %pv3=get_param(handle3,block.BlockType);
       
       %newval=str2num(newval);
      close_system(newfile);
 end
