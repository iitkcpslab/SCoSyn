  %% This is the main script that implements the bug localisation algorithm
  %% mentioned in the paper.
  function id=find_parameter(modelno,specno)
    close all;
    delete 'sort1.csv';
    delete 'sort2.csv'; 
    delete 'join.csv';
    delete 'BrFalse_Robust_neg.csv'; 
    delete 'BrFalse_Robust_all.csv'; 
    delete 'BrFalse.csv';
    
    [phi,rob,BrFalse]=initialize(modelno,specno);
    if rob>=0
         BrFalse='';
         id=-1;
         return;
    end
    
    %BrFalse = falsif_pb.GetBrSet_False();
    %BrFalse=BrFalse.BrSet;
    
     % impl new debug algo
    disp(phi);
    
    % the list of sub-specifications
    flag=0; %if unsat core exists then flag=1
    sub_spec=[];
    sphi=[];
    res_spec=phi;
    tphi = STL_Break(phi,2);
    while(length(tphi)>2)
      pphi = tphi(1);
      sub_spec=[sub_spec pphi];
      sphi = tphi(2);
      tphi = STL_Break(sphi,2);
    end
    sub_spec=[sub_spec sphi];
    
    
    % different comb of sub-specs
    for i=1: length(sub_spec)-1
       %disp("i = "+i); 
       comb_spec = nchoosek(sub_spec,i);
       for j=1:length(comb_spec)
         %disp("j = "+j);  
         jspec = joinspec(comb_spec(j,:));
         %disp(jspec)
         if BrFalse.CheckSpec(jspec)<0
            res_spec=jspec;
            flag=1;
            %disp("break");
            %disp(res_spec)
            %disp(BrFalse.CheckSpec(jspec))
            break;
         end
       end       
       if flag==1
           break;
       end
    end
    
    % if no minimal unsat core found
    if flag==0
      res_spec=phi;
    end
  

 
     %% Algo 2 : slicing
     %tic
     %global modelno;
     if modelno==1 || modelno==2 || modelno==4 || modelno==5 || modelno==3
       slice={'gain1','gain','gain2'};
     elseif modelno==7
       slice={'x_kp','x_ki','x_kd','y_kp','y_ki','y_kd','z_kp','z_ki','z_kd','phi_kp','phi_ki','phi_kd','theta_kp','theta_ki','theta_kd','psi_kp','psi_ki','psi_kd'};
     elseif modelno==6
       %slice={'gain1','gain2','gain3','gain4','gain5'};
       slice={'gain1','gain2','gain3','gain4'};
     elseif modelno==8
        slice={'gain1','gain2','gain3','gain4','gain5','gain6','gain7','gain8','gain9','gain10','gain11','gain12','gain13','gain14','gain15','gain16','gain17','gain18','gain19','gain20','gain21','gain22','gain23','gain24','gain25','gain26','gain27','gain28','gain29','gain30','gain31','gain32','gain33','gain34','gain35','gain36'}; 
     elseif modelno==9
       %slice={'Kp1','Ki1','Kd1','sp1','d1','r1','Kp2','Ki2','Kd2','sp2','d2','r2','Kp3','Ki3','Kd3','sp3','d3','r3','Kp4','Ki4','Kd4','sp4','d4','r4','Kp5','Ki5','Kd5','sp5','d5','r5','Kp6','Ki6','Kd6','sp6','d6','r6'};
       slice={'Kp1','Ki1','Kd1','Kp2','Ki2','Kd2','Kp3','Ki3','Kd3','Kp4','Ki4','Kd4','Kp5','Ki5','Kd5','Kp6','Ki6','Kd6'};
     elseif modelno==10
       slice={'cof1','cof2'};
     elseif modelno==11
       slice={'kpi','ka','kq','kf'};
     end
    delete 'BrFalse.csv';
    
    %% Algo3
    %pause(2);
    %tic
    figure;
        BrFalse.PlotSigPortrait(slice(1));
        h = findobj(gca,'Type','line');
        x = h.XData;
        y = h.YData;
        xlswrite('BrFalse',{transpose(x),transpose(y)});

   
    %signals = STL_ExtractSignals(phi); 
    %get_params(phi1);

    for i=2:length(slice)
            figure;
            BrFalse.PlotSigPortrait(slice(i));
            pause(0.1);
            h = findobj(gca,'Type','line');
            y = h.YData;
            %Step 1 - Read the file
            M = csvread('BrFalse.csv');
            % Step 2 - Add a column to the data
            M = [ M transpose(y)];
            % Step 3 - Save the file
            csvwrite('BrFalse.csv', M);
    end


    figure;
    BrFalse.PlotRobustSat(res_spec);
    h = findobj(gca);
    if isprop(h(2),'XData')
      x = h(2).XData;
      y = h(2).YData;
    else
      x = h(3).XData;
      y = h(3).YData;
    end
    %xlswrite('BrFalse_Plot_Robust_Sat',{transpose(x),transpose(y)});

    %delete 'BrFalse_Robust_all.csv';
    delete 'BrFalse_Robust_neg.csv';
    %[p,val]=BrFalse.PlotRobustSat(phi);
    %index=length(p.props);
    %y=p.props_values(index).val;
    %x=p.props_values(index).tau;
    %len=length(p.traj{1}.time);
    %j=1;
    
    for j=1:length(x)
        if y(j)<0
          if j==length(x)  
            dlmwrite('BrFalse_Robust_neg.csv',{transpose(x(j)),transpose(y(j))},'delimiter',',','-append'); 
            break;
          end
          dlmwrite('BrFalse_Robust_neg.csv',{transpose(x(j)),transpose(y(j))},'delimiter',',','-append'); 
          if x(j+1)-x(j)>0.01
            for i=x(j)+0.01:0.01:x(j+1)-0.01
              dlmwrite('BrFalse_Robust_neg.csv',{transpose(i),transpose(y(j))},'delimiter',',','-append');
            end
          end
        end
    end

 
    %below is the linux command for joining two csv files
    ! sort -t , -k 1,1 BrFalse.csv > sort1.csv
    ! sort -t , -k 1,1 BrFalse_Robust_neg.csv > sort2.csv
    ! join -t , -1 1 -2 1 sort1.csv sort2.csv > join.csv
  
    
    M = csvread('join.csv');
    %M=[slice;M]; 
    
     col=length(slice)+2;
     [ m , n ] = size(M);
     
     close all; 

     %profile on;
     
     %% Algo 4
     %tic
     M(:,1)=[];
     N=M(:,1:end-1); % removing robustness column
     n=n-2;
     for i=1:n
         xmin=N(1,i);
         xmax=N(1,i);
         for j=1:m
             if N(j,i)>xmin
                 xmin=N(j,i);
             end
             if N(j,i)<xmax
                 xmax=N(j,i);
             end
         end
         
         for j=1:m
             if xmin==xmax
                 N(j,i)=0;
             else
                 N(j,i)=(N(j,i)-xmin)/(xmax-xmin);
             end
         end
     end
                 
     %N=M(:,1:end);
     %[status,data]=system(['python3 heatmap.py ' N]);
     %h = heatmap(cdata);
     tol=0.01;
     id=licols(N,tol);
     while length(id)==0
        tol=tol*10; 
        id=licols(N,tol);
     end
     
     %[C,ia,ib] = intersect(slice,B.P.ParamList(id), 'stable');
     %disp("the suspected signals are");
     %sind=slice(id);
     disp(id);
     %disp("#############################");
     %disp("time for bug localisation");
     %[Y,id1]=lu_licols(N,0.01);
     %[W,id2]=svd_licols(N,0.01);
     %toc
     %disp("time to compute algo4");
     %plot(svd(N));
    %sind=bug_localisation(ans); 

    %function sind=bug_localisation(ans) 
    %   sind=ans;
    %end
    %% to delete ith column use a(:,i) = []; 
    % toc
    % disp("total time");
    %disp(length(B.P.ParamList));
    %disp(length(slice));
    %disp(length(sind));
  end  
   
    
 function idx=licols(X,tol)
%Extract a linearly independent set of columns of a given matrix X
     if ~nnz(X) %X has no non-zeros and hence no independent columns
         Xsub=[]; idx=[];
         return
     end
     if nargin<2, tol=1e-10; end
       [Q, R, E] = qr(X,0); 
       if ~isvector(R)
        diagr = abs(diag(R));
       else
        diagr = R(1);   
       end
       %Rank estimation
       r = find(diagr >= tol*diagr(1), 1, 'last');
       %r = find(diagr > 0, 1, 'last'); %rank estimation
       %idx=E(1);
       idx=E(1:r);
       %Xsub=X(:,idx);
 end
 
 
%lu decomposition
 function [Xsub,idx]=lu_licols(X,tol)
%Extract a linearly independent set of columns of a given matrix X
     if ~nnz(X) %X has no non-zeros and hence no independent columns
         Xsub=[]; idx=[];
         return
     end
     if nargin<2, tol=1e-10; end
       [Q,R] = lu(X);
       if ~isvector(R)
        diagr = abs(diag(R));
       else
        diagr = R(1);   
       end
       [diagr1,E]=sort(diagr,'descend');
       E=transpose(E);
       %Rank estimation
       r = find(diagr1 >= tol*diagr1(1), 1, 'last'); %rank estimation
       idx=sort(E(1:r));
       Xsub=X(:,idx);
 end
 
 %svd
  function [Xsub,idx]=svd_licols(X,tol)
%Extract a linearly independent set of columns of a given matrix X
     if ~nnz(X) %X has no non-zeros and hence no independent columns
         Xsub=[]; idx=[];
         return
     end
     if nargin<2, tol=1e-10; end
       [U,R,V] = svd(X,0);
       if ~isvector(R)
        diagr = abs(diag(R));
       else
        diagr = R(1);   
       end
       [diagr1,E]=sort(diagr,'descend');
       E=transpose(E);
       %Rank estimation
       r = find(diagr1 >= tol*diagr1(1), 1, 'last'); %rank estimation
       idx=sort(E(1:r));
       Xsub=X(:,idx);
  end
  
  function cspec=joinspec(phi)
       if length(phi)==1
          cspec=phi;
          return; 
       end
       sp = [disp(phi(1))];
       for j=2:length(phi)
           sp = [sp ' and ' disp(phi(j))];
       end
       cspec = STL_Formula('cspec',sp);
  end
  
 
 
