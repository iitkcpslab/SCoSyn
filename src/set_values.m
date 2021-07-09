% 
%    global index;
%    global pval;
%    global newfile;
%    global sind;
   

 function set_values(newfile,index,sind,pval)   
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
        set_param(handle,'UpperLimit',num2str(pval(index)));
    else if block.BlockType=="TransferFcn"
        %val=['[1 ' num2str(pval(index)) ' 23.04]'];    
        %set_param(handle,'Denominator',val);
        val=num2str(pval(index));    
        set_param(handle,'Numerator',val);
    else
        set_param(handle,block.BlockType,num2str(pval(index)));
    end
    save_system(newfile);
   close_system(newfile);
 end   
