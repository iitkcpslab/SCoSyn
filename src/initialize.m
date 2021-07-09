    % init script
    
function [phi,rob,BrFalse]=initialize(modelno,specno)
   
    if modelno==1
        [phi,rob,BrFalse]=init_quadrotor('model',specno,1);
    elseif modelno==2 
        [phi,rob,BrFalse]=init_cc('cruise_ctrl',specno,1);
    elseif modelno==7
        [phi,rob,BrFalse]=init_quadrotor_full('Quad_sim',specno,1);
    elseif modelno==3
        [phi,rob,BrFalse]=init_aircraft('Aircraft_Pitch',specno,1);
    elseif modelno==4
        [phi,rob,BrFalse]=init_pendulum('Inverted_Pendulum',specno,1);
    elseif modelno==5
        [phi,rob,BrFalse]=init_dcmotor('DCMotor',specno,1);
    elseif modelno==6
        [phi,rob,BrFalse]=init_f16('rct_concorde',specno,1);    
    elseif modelno==8
        [phi,rob,BrFalse]=init_walkingRobot('walkingRobot',specno,1);    
    elseif modelno==9
        [phi,rob,BrFalse]=init_robotarm('RobotArm_Full',specno,1);    
    elseif modelno==10
        [phi,rob,BrFalse]=init_car('Car_sliding',specno,1);
    elseif modelno==11
        [phi,rob,BrFalse]=init_f14('F14',specno,1);
    elseif modelno==12
        [phi,rob,BrFalse]=init_helicopter('rct_helico',specno,1);
    elseif modelno==13
        [phi,rob,BrFalse]=init_cascade('scdcascade',specno,1);
    elseif modelno==14
        [phi,rob,BrFalse]=init_airframe('scdairframectrl',specno,1);
    elseif modelno==15
        [phi,rob,BrFalse]=init_heatex('heatex_sim',specno,1);
    elseif modelno==16
        [phi,rob,BrFalse]=init_demo('demo3',specno,1);
    end
end   
