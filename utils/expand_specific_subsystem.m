src='Transmission';



file='Autotrans_shift_annotated';
%file='sldemo_fuelsys_original';
%file='AbstractFuelControl_M11';
newfile = 'Autotrans_shift_expanded';  
%newfile = 'AbstractFuelControl_expanded';
%newfile = 'sldemo_fuelsys_expanded';
open_system(file);
save_system(file,'Autotrans_shift_annotated.xml','ExportToXML',true);
%save_system(file,'AbstractFuelControl_M11.xml','ExportToXML',true);
%save_system(file,'sldemo_fuelsys_original.xml','ExportToXML',true);

[status,data]=system(['python3 list_subsystem.py ' char(file) '.xml all']);
data = erase(data,"[");
data = erase(data,"]");
data = split(data,", ");
data = erase(data,"'");
data=strip(data);
allsub=data;
[status,data]=system(['python3 list_subsystem.py ' char(file) '.xml atomic']);
data = erase(data,"[");
data = erase(data,"]");
data = split(data,", ");
data = erase(data,"'");
data=strip(data);
atomic=data;

n=length(atomic);
for i=1:n
    suffix = strsplit(char(atomic(i)),'/');
    suffix = suffix(length(suffix));
    atomic(i)=suffix;
end

[status,data]=system(['python3 list_subsystem.py ' char(file) '.xml masked']);
data = erase(data,"[");
data = erase(data,"]");
data = split(data,", ");
data = erase(data,"'");
data=strip(data);
masked=data;

data = intersect(allsub,atomic);
data1 = intersect(allsub,masked);
data = [data; data1];
data = setxor(allsub,data);

n=length(data);
%disp(n);
%%Here src is the input i.e name of the subsystem that has to be expanded
%src='Transmission';


i=1;
while i<=n
    %disp(i);
    prefix = strsplit(char(data(i)),'/');
    if ~(strcmp(src,prefix(1)))
        %data(i) = erase(data(i),prefix(1))
        data(i)=[];
        %disp(data);
        n=n-1;
        i=i-1;
    end
    i=i+1;
end

n=length(masked);
i=1;
while i<=n
    %disp(i);
    prefix = strsplit(char(masked(i)),'/');
    if ~(strcmp(src,prefix(1)))
        %data(i) = erase(data(i),prefix(1))
        masked(i)=[];
        %disp(data);
        n=n-1;
        i=i-1;
    end
    i=i+1;
end

disp(data);


%% TODO : We need to create a list of atomic and masked and prune smartly from the allsub;

hws = get_param(file, 'modelworkspace');
hws.DataSource = 'MAT-File';
hws.FileName = 'params';


pattern = "/"; % represents hierarchy
%load sldemo_autotrans_data;
%for h=0:5
% need to handle case - prevent exploration inside atomic subsystem    
   for i=1:length(data)
      disp(i);
      disp(data(i));
      if count(data(i),"/") == 0
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
         Simulink.BlockDiagram.expandSubsystem(char(strcat(file,suffix)));
         %disp(char(strcat(file,suffix)));
      end
   end

   for i=1:length(masked)

     if (count(masked(i),"/") == 0) && not (isequal(masked,{''}))
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
%end


save_system(file,newfile,'SaveModelWorkspace');

save_system(newfile,'Autotrans_shift_expanded.xml','ExportToXML',true);
%save_system(newfile,'AbstractFuelControl_expanded.xml','ExportToXML',true);
close_system(file);
close_system(newfile);

close all;
%load_system(newfile);
%blocks=find_system(newfile);


open_system(newfile);
b = find_system(newfile,'Type','Block');  
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
      %disp(cellstr(get_param(ph.Outport(j), 'Name'))); 
      %disp(i);
      set_param(ph.Outport(j),'DataLogging','on');
   end
   %for j=1:length(ph.Inport)
   %   set_param(ph.Inport(j),'DataLogging','on');
   %end
end
save_system(newfile);
close_system(newfile);





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