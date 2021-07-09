function [alpha1,alpha2] = fcn(w1,th1,w2,th2,tau1,tau2)
    m1=1;
    m2=1;
    l1=0.2;
    l2=0.2;
    g=9.81;
    
    alpha2 = (tau2*((m1+m2)*l1^2 + m2*l2^2 + 2*m2*l1*l2*cos(th2))
             +(-m2*l1*l2*sin(th2)*(w1^2)-m2*g*l2*sin(th1+th2))*((m1+m2)*(l1^2) +
             m2*(l2^2) + 2*m2*l1*l2*cos(th2))-tau1*(m2*(l2^2)+ m2*l1*l2*cos(th2)) -
             (2*m2*l1*l2*sin(th2)*w1*w2 + m2*l1*l2*sin(th2)*(w2^2)-(m1+m2)*g*l1*sin(th1)
             -m2*g*l2*sin(th1+th2))*(m2*(l2^2)+m2*l1*l2*cos(th2)))/((m2*(l2^2))*
             ((m1+m2)*(l1^2)+m2*(l2^2)+2*m1*l1*l2*cos(th2))-
             (m2*(l2^2)+m2*l1*l2*cos(th2))^2);
    
    alpha1 = (tau1 - ((m2*l2^2 + m2*l1*l2*cos(th2))*alpha2+2*m2*l1*l2
              *sin(th2)*w1*w2 + m2*l1*l2*sin(th2)*w2^2 - (m1+m2)*g*l1*sin(th1)
              -m2*g*l2*sin(th1+th2)))/((m1+m2)*(l1^2)+m2*(l2^2)+2*m2*l1*l2*cos(th2));
      
