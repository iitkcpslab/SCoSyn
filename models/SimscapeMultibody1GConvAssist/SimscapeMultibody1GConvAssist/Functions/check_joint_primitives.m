function [primitive_err, Primitive2G_str]=check_joint_primitives(joint_type,primitive,primitive_data,jnt_h)
%convertSM1G2G - Convert Simscape Multibody 1G blocks to 2G equivalents
% Arguments: 1G joint type ("Bushing"), Primitive ("P1")
%    primitive data from 1G dialog box in a structure
%    Returns 1 if error; also returns 2G axis prefix (Rz, Px, etc.)
%    Only request one return argument to verify primitive
%    Request two return arguments to get axis prefix

% Copyright 2014-2019 The MathWorks Inc.

% CONVENTIONS FOR JOINTS IN 2G
JointPriAxis2G.Prismatic.P1.Axis=[0 0 1];
JointPriAxis2G.Prismatic.P1.Ref='Base';

JointPriAxis2G.Revolute.R1.Axis=[0 0 1];
JointPriAxis2G.Revolute.R1.Ref='Base';

JointPriAxis2G.Screw.R1.Axis=[0 0 1];
JointPriAxis2G.Screw.R1.Ref='Base';

JointPriAxis2G.Cylindrical.P1.Axis=[0 0 1];
JointPriAxis2G.Cylindrical.P1.Ref='Base';
JointPriAxis2G.Cylindrical.R1.Axis=[0 0 1];
JointPriAxis2G.Cylindrical.R1.Ref='Base';

JointPriAxis2G.Bearing.P1.Axis=[0 0 1];
JointPriAxis2G.Bearing.P1.Ref='Base';
JointPriAxis2G.Bearing.R1.Axis=[1 0 0];
JointPriAxis2G.Bearing.R1.Ref='Follower';
JointPriAxis2G.Bearing.R2.Axis=[0 1 0];
JointPriAxis2G.Bearing.R2.Ref='Follower';
JointPriAxis2G.Bearing.R3.Axis=[0 0 1];
JointPriAxis2G.Bearing.R3.Ref='Follower';
JointPriAxis2G.Telescoping.P1.Axis=[0 0 1];
JointPriAxis2G.Telescoping.P1.Ref='Base';
JointPriAxis2G.Telescoping.S.Axis=[0 0 0];  % Entry for N/A
JointPriAxis2G.Telescoping.S.Ref='World';   % Entry for N/A

JointPriAxis2G.Bushing.P1.Axis=[1 0 0];
JointPriAxis2G.Bushing.P1.Ref='Follower';
JointPriAxis2G.Bushing.P2.Axis=[0 1 0];
JointPriAxis2G.Bushing.P2.Ref='Follower';
JointPriAxis2G.Bushing.P3.Axis=[0 0 1];
JointPriAxis2G.Bushing.P3.Ref='Follower';
JointPriAxis2G.Bushing.R1.Axis=[1 0 0];
JointPriAxis2G.Bushing.R1.Ref='Follower';
JointPriAxis2G.Bushing.R2.Axis=[0 1 0];
JointPriAxis2G.Bushing.R2.Ref='Follower';
JointPriAxis2G.Bushing.R3.Axis=[0 0 1];
JointPriAxis2G.Bushing.R3.Ref='Follower';

JointPriAxis2G.Gimbal.R1.Axis=[1 0 0];
JointPriAxis2G.Gimbal.R1.Ref='Follower';
JointPriAxis2G.Gimbal.R2.Axis=[0 1 0];
JointPriAxis2G.Gimbal.R2.Ref='Follower';
JointPriAxis2G.Gimbal.R3.Axis=[0 0 1];
JointPriAxis2G.Gimbal.R3.Ref='Follower';

JointPriAxis2G.Inplane.P1.Axis=[1 0 0];
JointPriAxis2G.Inplane.P1.Ref='Base';
JointPriAxis2G.Inplane.P2.Axis=[0 1 0];
JointPriAxis2G.Inplane.P2.Ref='Base';

JointPriAxis2G.Planar.P1.Axis=[1 0 0];
JointPriAxis2G.Planar.P1.Ref='Base';
JointPriAxis2G.Planar.P2.Axis=[0 1 0];
JointPriAxis2G.Planar.P2.Ref='Base';
JointPriAxis2G.Planar.R1.Axis=[0 0 1];
JointPriAxis2G.Planar.R1.Ref='Follower';

JointPriAxis2G.SixDoF.P1.Axis=[1 0 0];
JointPriAxis2G.SixDoF.P1.Ref='Base';
JointPriAxis2G.SixDoF.P2.Axis=[0 1 0];
JointPriAxis2G.SixDoF.P2.Ref='Base';
JointPriAxis2G.SixDoF.P3.Axis=[0 0 1];
JointPriAxis2G.SixDoF.P3.Ref='Base';
JointPriAxis2G.SixDoF.S.Axis=[0 0 0];
JointPriAxis2G.SixDoF.S.Ref='World';

JointPriAxis2G.Spherical.S.Axis=[0 0 0];
JointPriAxis2G.Spherical.S.Ref='World';

JointPriAxis2G.Universal.S.Axis=[0 0 0];
JointPriAxis2G.Universal.S.Ref='World';

JointPriAxis2G.Universal.R1.Axis=[1 0 0];
JointPriAxis2G.Universal.R1.Ref='Base';
JointPriAxis2G.Universal.R2.Axis=[0 1 0];
JointPriAxis2G.Universal.R2.Ref='Base';

JointPriAxis2G.Weld.W.Axis=[0 0 0];
JointPriAxis2G.Weld.W.Ref='World';

JointPriAxis2G.AngleConstraint.R1.Axis=[0 0 1];
JointPriAxis2G.AngleConstraint.R1.Ref='Base';


% DYNAMIC FIELDS CANNOT HAVE SPACES OR HYPHENS
joint_type_field = strrep(strrep(joint_type,' ',''),'-','');

% INITIALIZE COUNT OF PRIMITIVE ERRORS
primitive_err = 0;

if ~strcmpi(joint_type_field,'Weld')
    % CHECK JOINT AXIS REFERENCE FRAME (NOT USED FOR WELD JOINT)
    %disp(['In: ' primitive_data{1} ' Ref: '
    %JointPriAxis2G.(joint_type_field).(primitive).Ref]); % Debug
    if (~strcmpi(primitive_data{1},JointPriAxis2G.(joint_type_field).(primitive).Ref) && nargout == 1)
        convSM1G2GMsg([primitive ': Joint axis reference is ' primitive_data{1} ', should be ' JointPriAxis2G.(joint_type_field).(primitive).Ref]);
        primitive_err(1) = 1;
    end
    try
        % Constraints doe not have prefixes on the Axis parameter 
        prim_fieldname = primitive;
        if(strcmpi(joint_type_field,'AngleConstraint')),prim_fieldname = '';end 
        
        % USE slResolve IN CASE IT IS A VARIABLE
        joint_axis = slResolve([prim_fieldname 'Axis'], jnt_h, 'variable');
        % IF slResolve DOES NOT WORK CAN RESORT TO evalin
        %joint_axis = evalin('base',primitive_data{2});
        
        if ((sum(reshape(joint_axis,[1,3])==JointPriAxis2G.(joint_type_field).(primitive).Axis)~=3)&& nargout == 1)
            convSM1G2GMsg([primitive ': Joint axis of action is ' primitive_data{2} ', should be [' num2str(JointPriAxis2G.(joint_type_field).(primitive).Axis) ']']);
            primitive_err(1) = 1;
        else
            %disp(['Joint ref: ' lower(primitive_data{2})]);
        end
    catch
        % IF IT IS A VARIABLE WHOSE VALUE IS NOT ACCESSIBLE
        % GENERATE WARNING
        convSM1G2GMsg([primitive ': Joint axis data not accessible (' primitive_data{2} ')'])
        primitive_err(1) = 1;
    end
else
    primitive_err(1) = 0;
end

% DETERMINE 2G AXIS - USED AS PREFIX IN SETTING PARAMETERS
axis1G = JointPriAxis2G.(joint_type_field).(primitive).Axis;
    if (axis1G == [1 0 0])
        axis2G = 'x';
    elseif (axis1G == [0 1 0])
        axis2G = 'y';
    elseif (axis1G == [0 0 1])
        axis2G = 'z';
    elseif (axis1G == [0 0 0])
        axis2G = '';
end

Primitive2G_str = [primitive(1) axis2G];

% PRISMATIC AND REVOLUTE HAVE NO PREFIX
if (strcmpi(joint_type, 'Prismatic') || strcmpi(joint_type, 'Revolute') || strcmpi(joint_type, 'Angle Constraint'))
    Primitive2G_str = '';
end
