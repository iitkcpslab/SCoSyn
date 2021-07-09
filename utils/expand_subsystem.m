%% Flattening the subsystems in the Simulink model

%global modelno;
%global specno;
%modelno=1;
file = 'model';
newfile = 'model_expanded'; 
open_system(file);
save_system(file,strcat(file,'.xml'),'ExportToXML',true);

[status,data]=system(['python3 list_subsystem.py ' char(file) '.xml all']);
allsub=parse_data(data);

[status,data]=system(['python3 list_subsystem.py ' char(file) '.xml atomic']);
atomic=parse_data(data);

n=length(atomic);
for i=1:n
    suffix = strsplit(char(atomic(i)),'/');
    suffix = suffix(length(suffix));
    atomic(i)=suffix;
end

[status,data]=system(['python3 list_subsystem.py ' char(file) '.xml masked']);
masked=parse_data(data);

data = intersect(allsub,atomic); % atomic ss
data1 = intersect(allsub,masked);  % masked ss
data = [data; data1]; %% both atomic and masked sss
data = setxor(allsub,data); %% return data in either of the two lists but not in both

n=length(data);
%disp(n);

i=1;
while i<=n
    %disp(i);
    prefix = strsplit(char(data(i)),'/');
    if any(strcmp(atomic,prefix(length(prefix)))) || any(strcmp(atomic,prefix(1)))
        %data(i) = erase(data(i),prefix(1))
        data(i)=[];
        %disp(data);
        n=n-1;
        i=i-1;
    end
    i=i+1;
end
  
%disp(data);

hws = get_param(file, 'modelworkspace');
hws.DataSource = 'MAT-File';
hws.FileName = strcat(newfile,'_params');


pattern = "/"; % represents hierarchy
%load sldemo_autotrans_data;
n=length(data);
for h=0:5
% need to handle case - prevent exploration inside atomic subsystem    
   for i=1:n
      
      if count(data(i),"/") == h
         suffix = strsplit(char(data(i)),'/');
         check=suffix(1);
         if any(strcmp(atomic,check))
             %disp(check);
             data(i)=[];
             i=i-1;
             n=n-1;
             continue;
         end
         suffix = suffix(length(suffix));
         suffix = char(strcat('/',suffix));
         %disp(file);
         %disp(suffix);
         Simulink.BlockDiagram.expandSubsystem(char(strcat(file,suffix)));
         %disp(char(strcat(file,suffix)));
      end
   end
   
   for i=1:length(masked)
     
     if (count(masked(i),"/") == h) && not (isequal(masked,{''}))
        suffix = strsplit(char(masked(i)),'/');
        suffix = suffix(length(suffix));
        suffix=char(strcat('/',suffix));
        maskObj = Simulink.Mask.get(char(strcat(file,suffix)));
        vars = maskObj.getWorkspaceVariables;
        for i=1:length(vars)
           hws.assignin(vars(i).Name,vars(i).Value);
        end
        hws.saveToSource;
        maskObj.delete;
        Simulink.BlockDiagram.expandSubsystem(char(strcat(file,suffix)));
        %disp(char(strcat(file,suffix)));
     end
   end
   
end

save_system(file,newfile,'SaveModelWorkspace');

save_system(newfile,strcat(newfile,'.xml'),'ExportToXML',true);

close_system(file);
close_system(newfile);

open_system(newfile);
b = find_system(newfile,'Type','Block');

for i=1:length(b)
   prefix = strsplit(char(b(i)),'/');
   ph = get_param(b{i},'PortHandles');
   if any(strcmp(atomic,prefix(2)))
      continue;
   end
   if isempty(ph.Outport)
       continue;
   end
   for j=1:length(ph.Outport)
      set_param(ph.Outport(j),'DataLogging','off');
   end
end  

list=[];
for i=1:length(b)
   prefix = strsplit(char(b(i)),'/');
   if length(prefix)>2
       continue;
   end
   if any(strcmp(atomic,prefix(2)))
      continue;
   end
   
   ph = get_param(b{i},'PortHandles');
   if isempty(ph.Outport)
       continue;
   end
   for j=1:length(ph.Outport)
      item=cellstr(get_param(ph.Outport(j), 'Name'));
      %disp(item);
      %disp(i);
      if any(strcmp(list,item)) && ~strcmp(char(item),"")
         continue;
      end
      set_param(ph.Outport(j),'DataLogging','on');
      list= [list;item];
   end
   %for j=1:length(ph.Inport)
   %   set_param(ph.Inport(j),'DataLogging','on');
   %end
end
save_system(newfile);
close_system(newfile);

%common_script;
%toc
%disp("total time");


function data=parse_data(data)
   data = erase(data,"[");
   data = erase(data,"]");
   data = split(data,", ");
   data = erase(data,"'");
   data=strip(data);
end

%{
xmlfile='Autotrans_shift_annotated';
%Simulink.BlockDiagram.expandSubsystem(char(strcat(xmlfile,'/Engine')));
%Simulink.BlockDiagram.expandSubsystem(char(strcat(xmlfile,'/Transmission')));

maskObj = Simulink.Mask.get(char(strcat(xmlfile,'/Vehicle')));
for i=1:length(maskObj.Parameters)
    maskObj.Parameters(i).Name=maskObj.Parameters(i).Value;
end
%maskObj.delete;
%Simulink.BlockDiagram.expandSubsystem(char(strcat(xmlfile,'/Vehicle')));

%Simulink.BlockDiagram.expandSubsystem(char(strcat(xmlfile,'/ShiftLogic')));
%}
