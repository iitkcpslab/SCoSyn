function [joint_param] = getSM1GJoints(Src_mdl)
% getSM1GJoints - Get key parameters for joints in a Simscape Multibody 1G model

% Copyright 2014-2019 The MathWorks Inc.

joint_param = [];       % INITIALIZE STRUCTURE
load_system(Src_mdl);   % LOAD MODELS

% FIND BLOCKS
joint_paths = find_system(Src_mdl,'FollowLinks','on','LookUnderMasks','all','regexp','on','ReferenceBlock','mblibv.*/Joints/.*');

% JOINT PARAMETER NAMES (1G, joint_param STRUCTURE)
JointParameters={...
    'Name','Name';...
    'Handle','Handle';...
    'Position','Position';...
    'Orientation','Orientation';...
    'PrimitiveProps','PrimitiveStr';...
    };

% LOOP OVER JOINT BLOCKS
for i=1:length(joint_paths)
    for j=1:length(JointParameters)
        joint_param(i).(char(JointParameters{j,2})) = get_param(char(joint_paths(i)),char(JointParameters{j,1}));
    end
    joint_param(i).BlockPath = joint_paths(i);
    jtype_temp = strrep(get_param(joint_param(i).Handle,'ReferenceBlock'),'mblibv1/Joints/','');
    % PROCESS JOINT TYPE STRING FOR DISASSEMBLED JOINTS, MASSLESS CONNECTORS
    jtype_temp = strrep(jtype_temp,'Disassembled Joints/','');
    joint_param(i).JointType = strrep(jtype_temp,'Massless Connectors/','');
    joint_param(i).JointSprDmp = [];
    joint_param(i).InitialConditions = [];
    
    % CHECK FOR INITIAL CONDITIONS AND SPRING-DAMPER
    pc_data = get_param(joint_param(i).Handle,'PortConnectivity');
    for pind=1:length(pc_data)
        cblk_ref = get_param(pc_data(pind).DstBlock,'ReferenceBlock');
        cblk_hdl = get_param(pc_data(pind).DstBlock,'Handle');
        if(strfind(char(cblk_ref),'Joint Initial Condition'))
            joint_param(i).ICStr = get_param(cblk_hdl,'InitialConditions');
            % EXTRACT TO SUBFIELDS BY PRIMITIVE IN InitialConditions
            icstr_temp = strsplit(joint_param(i).ICStr,'#');
            for k=1:length(icstr_temp)
                icstr_data_temp = strsplit(char(icstr_temp(k)),'$');
                joint_param(i).InitialConditions.(char(icstr_data_temp(1))) = icstr_data_temp;
            end
        elseif(strfind(char(cblk_ref),'Joint Spring & Damper'))
            joint_param(i).JSDStr = get_param(cblk_hdl,'JFEParameters');
            % EXTRACT TO SUBFIELDS BY PRIMITIVE IN JointSprDmp
            jsdstr_temp = strsplit(joint_param(i).JSDStr,'#');
            for k=1:length(jsdstr_temp)
                jsdstr_data_temp = strsplit(char(jsdstr_temp(k)),'$');
                joint_param(i).JointSprDmp.(char(jsdstr_data_temp(1))) = jsdstr_data_temp;
            end
        end
    end
	primitives_temp = strsplit([joint_param(i).PrimitiveStr],'#');
    for k=1:length(primitives_temp)
        primitive_data_temp = strsplit(char(primitives_temp(k)),'$');
        joint_param(i).Primitives.(char(primitive_data_temp(1))) = primitive_data_temp(2:end);
    end
end

