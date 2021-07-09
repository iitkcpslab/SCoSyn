
function f = objfunc(modelno,specno)
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
    
    set_values;
    initialize;
    f=falsif_pb.obj_best;
end
