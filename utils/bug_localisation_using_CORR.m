  %% This is the main script that implements the bug localisation algorithm
  %% mentioned in the paper.
  function id=bug_localisation_using_CORR(modelno,specno)
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

   
     %% Algo 2 : slicing
     %tic
     %global modelno;
     if modelno==1 || modelno==2 || modelno==4 || modelno==5 || modelno==6 ||modelno==7
       slice={'gain','gain1','gain2'};
     elseif modelno==3
       slice={'x_kp','x_ki','x_kd','y_kp','y_ki','y_kd','z_kp','z_ki','z_kd','phi_kp','phi_ki','phi_kd','theta_kp','theta_ki','theta_kd','psi_kp','psi_ki','psi_kd'};
     end
    delete 'BrFalse.csv';
    
    %% Algo3
    
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
    BrFalse.PlotRobustSat(phi);
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
    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%
     %%%%%% correlation method impl
     M(:,1)=[];
     R = corrcoef(M);
     [m,n]=size(R);
     [maxi,id]=max(abs(R(m,1:m-1)))
     %return;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     close all; 
     disp(id);
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
  
 
 
