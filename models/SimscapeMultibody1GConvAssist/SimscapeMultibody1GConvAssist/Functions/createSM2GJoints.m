function num_warnings = createSM2GJoints(joint_param,Dst_mdl)
% createSM2GJoints - Create Simscape Multibody 2G equivalents for 1G joints

% Copyright 2014-2019 The MathWorks Inc.

% BLOCK POSITIONS (RECTANGLE)
subsystem_2g_pos   = [260  29  260  29];
open_subsys_pos    = [ 50  29  240  51];
subsystem_gap      = 80;

num_blk_warn = 0;
num_warnings = 0;
JointMapping={...
    'Bearing','Telescoping Joint';...   % MISMATCH DUE TO PRISMATIC AXIS
    'Bushing','Bushing Joint';...
    'Cylindrical','Cylindrical Joint';...
    'Gimbal','Gimbal Joint';...
    'In-plane','Rectangular Joint';...
    'Planar','Planar Joint';...
    'Prismatic','Prismatic Joint';...
    'Revolute','Revolute Joint';...
    'Six-DoF','6-DOF Joint';...
    'Spherical','Spherical Joint';...
    'Telescoping','Telescoping Joint';...
    'Universal','Universal Joint';...
    'Weld','Weld Joint';...
    };

% ADJUST FOR DIFFERENT LIBRARY PATHS R2012a-R2013a
ver_str = version('-release');
if (strcmpi(ver_str,'2012a') || strcmpi(ver_str,'2012b') || strcmpi(ver_str,'2013a'))
    JointMapping={...
        'Bearing','Telescoping Joint';...   % MISMATCH DUE TO PRISMATIC AXIS
        'Bushing','Bushing Joint';...
        'Cylindrical','Cylindrical  Joint';...
        'Gimbal','Gimbal Joint';...
        'In-plane','Rectangular  Joint';...
        'Planar','Planar Joint';...
        'Prismatic','Prismatic  Joint';...
        'Revolute','Revolute Joint';...
        'Six-DoF','6-DOF Joint';...
        'Spherical','Spherical  Joint';...
        'Telescoping','Telescoping  Joint';...
        'Universal','Universal  Joint';...
        'Weld','Weld Joint';...
        };
end

% Joints added later
if(~verLessThan('matlab',release2ver('R2015a')))
    JointMapping(end+1,:)={'Screw','Lead Screw Joint'};
end


% ADD SUBSYSTEM FOR JOINTS
jntsys_h = add_block('simulink/Ports & Subsystems/Subsystem',[Dst_mdl '/Joints'],...
    'Position',[195    40   275   100]);

% CLEAN OUT NEW SUBSYSTEM
in_h = find_system(jntsys_h,'Name','In1');
out_h = find_system(jntsys_h,'Name','Out1');
delete_line(jntsys_h,'In1/1','Out1/1');
delete_block(in_h);
delete_block(out_h);
jntsys_pth = getfullname(jntsys_h);

% INITIALIZE LOOP VARIABLES
subsys_pos_last = subsystem_2g_pos;
opsys_pos_last  = open_subsys_pos;
body_off_ud_total = [0 0 0 0];

for i=1:length(joint_param)
    convSM1G2GMsg(['*** Creating Joint ' regexprep(char(joint_param(i).Name),'\n',' ')]);
    num_blk_warn = 0;
    % CALCULATE OFFSETS FOR SUBSYSTEMS
    pos_rect = joint_param(i).Position;
    body_off_size = [0 0 (pos_rect(3)-pos_rect(1)) (pos_rect(4)-pos_rect(2))];
    body_off_ud = [0 1 0 1]*(pos_rect(4)-pos_rect(2)+subsystem_gap);
    
    % ADD SUBSYSTEM WITH CALLBACK TO SHOW JOINT BLOCK IN 1G MODEL
    opsys_h = add_block('simulink/Ports & Subsystems/Subsystem',[jntsys_pth '/View Original Joint ' strrep(char(joint_param(i).Name),'/','//')],...
        'MakeNameUnique', 'on');
    set_param(opsys_h,...
        'Position',opsys_pos_last,...
        'DropShadow','on',...
        'MaskDisplay',['disp(['' View Original Joint ' regexprep(char(joint_param(i).Name),'\n',' ') ''']);'],...
        'ShowName','off',...
        'OpenFcn',['hilite_system(''' regexprep(char(joint_param(i).BlockPath),'\n',' ') ''');']);
    % CLEAN OUT NEW SUBSYSTEM
    in_h = find_system(opsys_h,'Name','In1');
    out_h = find_system(opsys_h,'Name','Out1');
    delete_line(opsys_h,'In1/1','Out1/1');
    delete_block(in_h);
    delete_block(out_h);
    
    % ADD 2G JOINT BLOCK
    joint_type1G = char(joint_param(i).JointType);
    joint_type2G = char(JointMapping(strcmp(JointMapping(:,1),joint_type1G),2));
    if(~isempty(joint_type2G))
        jnt_h = add_block(['sm_lib/Joints/' joint_type2G],[jntsys_pth '/' strrep(char(joint_param(i).Name),'/','//')],...
            'MakeNameUnique', 'on',...
            'Orientation',char(joint_param(i).Orientation),...
            'Position',subsys_pos_last+body_off_size);
        % CHECK FOR INITIAL CONDITIONS
        if(~isempty(joint_param(i).InitialConditions))
            primitive_list = fieldnames(joint_param(i).Primitives);
            % LOOP OVER PRIMITIVES TO ASSIGN JOINT TARGETS
            for pr_i = 1:length(primitive_list)
                % GET 2G PRIMITIVE AXIS
                [~,pr_str]=check_joint_primitives(...
                    joint_type1G,char(primitive_list(pr_i)),...
                    joint_param(i).Primitives.(char(primitive_list(pr_i))),...
                    joint_param(i).Handle);
                % EXTRACT DATA FOR TARGETS FROM PRIMITIVE FIELD
                if (~strcmpi(char(primitive_list(pr_i)),'W'))  % NOT FOR WELD JOINTS
                    prim_data = getfield(joint_param(i).InitialConditions,char(primitive_list(pr_i)));
                    if strcmpi(prim_data{2},'true')
                        if strcmp(prim_data{1}(1),'R')
                            posUnit_i = 5; velUnit_i = 8;
                        else
                            posUnit_i = 4; velUnit_i = 7;
                        end
                        set_param(jnt_h,...
                            [pr_str 'PositionTargetSpecify'],'on',...
                            [pr_str 'PositionTargetPriority'],'High',...
                            [pr_str 'PositionTargetValue'],char(prim_data(3)),...
                            [pr_str 'PositionTargetValueUnits'],char(prim_data(posUnit_i)),...
                            [pr_str 'VelocityTargetSpecify'],'on',...
                            [pr_str  'VelocityTargetPriority'],'High',...
                            [pr_str  'VelocityTargetValue'],char(prim_data(6)),...
                            [pr_str  'VelocityTargetValueUnits'],char(prim_data(velUnit_i)));
                    end
                end
            end
        end
        % CHECK FOR SPRING-DAMPER
        if(~isempty(joint_param(i).JointSprDmp))
            primitive_list = fieldnames(joint_param(i).Primitives);
            % LOOP OVER PRIMITIVES TO SET SPRING DAMPER VALUES
            for pr_i = 1:length(primitive_list)
                % GET 2G PRIMITIVE AXIS
                [~,pr_str]=check_joint_primitives(...
                    joint_type1G,char(primitive_list(pr_i)),...
                    joint_param(i).Primitives.(char(primitive_list(pr_i))),...
                    joint_param(i).Handle);
                % EXTRACT DATA FOR TARGETS FROM PRIMITIVE FIELD
                if (~strcmpi(char(primitive_list(pr_i)),'W'))  % NOT FOR WELD JOINTS
                    prim_data = getfield(joint_param(i).JointSprDmp,char(primitive_list(pr_i)));
                    % INDEX FOR UNITS BASED ON PRIMITIVE TYPE (PRISMATIC/REVOLUTE)
                    if strcmpi(prim_data{2},'true')
                        if strcmp(prim_data{1}(1),'R')
                            posUnit_i = 9; velUnit_i = 10; frcUnit_i = 11;
                        else
                            posUnit_i = 6; velUnit_i = 7; frcUnit_i = 8;
                        end
                        pos_unit = char(prim_data(posUnit_i));
                        vel_unit = char(prim_data(velUnit_i));
                        frc_unit = char(prim_data(frcUnit_i));
                        set_param(jnt_h,...
                            [pr_str 'SpringStiffness'],          char(prim_data(3)),...
                            [pr_str 'SpringStiffnessUnits'],     [frc_unit '/' pos_unit],...
                            [pr_str 'DampingCoefficient'],       char(prim_data(4)),...
                            [pr_str 'DampingCoefficientUnits'],  [frc_unit '/(' vel_unit ')'],...
                            [pr_str 'EquilibriumPosition'],      char(prim_data(5)),...
                            [pr_str 'EquilibriumPositionUnits'], pos_unit);
                    end
                end
            end
        end
        
        % COMPARE PRIMITIVE AXES AND REFERENCE FRAMES TO 2G CONVENTION
        primitive_err=[];
        primitive_err_set={};
        primitive_list = fieldnames(joint_param(i).Primitives);
        
        % LOOP OVER PRIMITIVES PER JOINT
        for pr_i = 1:length(primitive_list)
            primitive_err=check_joint_primitives(...
                joint_type1G,char(primitive_list(pr_i)),...
                joint_param(i).Primitives.(char(primitive_list(pr_i))),...
                joint_param(i).Handle);
            if (primitive_err(1))
                primitive_err_set(end+1)= primitive_list(pr_i);
            end
        end
        % LOOP OVER PRIMITIVES WHICH HAVE ERRORS
        for pes_i=1:length(primitive_err_set)
            annotate2GBlks('fix_1G',[jntsys_pth ...
                '/' char(primitive_err_set(pes_i)) ': Ref=' char(joint_param(i).Primitives.(char(primitive_err_set(pes_i)))(1)),...
                ' | Axis=' char(joint_param(i).Primitives.(char(primitive_err_set(pes_i)))(2))],...
                'left',opsys_pos_last+[0 5 0 5]+[0 1 0 1]*15*(pes_i-1)+[0 1 0 1]*(open_subsys_pos(4)-open_subsys_pos(2)));
            num_blk_warn=1;
        end
    else
        convSM1G2GMsg([regexprep(char(joint_param(i).Name),'\n',' ') ' 1G Joint not translated: ' joint_type1G]);
        annotate2GBlks('fix_1G',[jntsys_pth '/1G Joint not translated: ' joint_type1G],...
            'left',opsys_pos_last+[0 5 0 5]+[0 1 0 1]*(open_subsys_pos(4)-open_subsys_pos(2)));
        num_blk_warn=1;
    end
    
    % Special Parameters
    if(strcmp(joint_type1G,'Screw') && ~isempty(joint_type2G))
        screwPitch = get_param(joint_param(i).Handle,'Pitch');
        screwUnits = get_param(joint_param(i).Handle,'Units');
        set_param(jnt_h,'Lead',screwPitch,'LeadUnits',[screwUnits '/rev']);
        try
            screwPitchVal = slResolve('Pitch', joint_param(i).Handle, 'variable');
            if (screwPitchVal < 0)
                set_param(jnt_h,'Direction','LeftHand');
            end
        catch
            convSM1G2GMsg('Check direction of Screw Joint');
            annotate2GBlks('fix_2G',[jntsys_pth '/Check direction of Screw Joint'],'left',opsys_pos_last+[0 5 0 5]+[0 1 0 1]*(open_subsys_pos(4)-open_subsys_pos(2)));
            num_blk_warn=1;
        end
        
    end
    
    % INCREMENT VERTICAL POSITION OF JOINTS
    body_off_ud_total = body_off_ud_total+body_off_ud;
    subsys_pos_last = subsystem_2g_pos+body_off_ud_total;
    opsys_pos_last = open_subsys_pos+body_off_ud_total;
    num_warnings=num_warnings+num_blk_warn;
    
end
if(num_warnings>0)
    set_param(jntsys_h,'BackGroundColor','[1, 0.75, 0.75]');
end
if(num_warnings==0 && ~isempty(joint_param))
    set_param(jntsys_h,'BackGroundColor','[0.75, 1, 0.75]');
end


