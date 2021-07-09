function num_warnings = createSM2GConstraints(cns_param,Dst_mdl)
% createSM2GConstraints - Create Simscape Multibody 2G equivalents for 1G constraints

% Copyright 2014-2019 The MathWorks Inc.

% BLOCK POSITIONS (RECTANGLE)
subsystem_2g_pos   = [260  29  260  29];
open_subsys_pos    = [ 50  29  240  51];
subsystem_gap      = 30;

ConnPort_2G_pos_l =  [ 60 111   60 111];
ConnPort_2G_pos_r =  [550 111  550 111];
ConnPort_2G_off_size= [ 0   0   30  18];

% ADJUST FOR DIFFERENT LIBRARY PATHS R2012a-R2013a
if(verLessThan('matlab',release2ver('R2013b')))
    ConstraintMapping={...
        'Gear Constraint','Gears, Couplings and Drives/Gears/Common Gear','R2012a';...
        'Angle Driver','Constraints/Angle  Constraint','R2012a';
        'Parallel Constraint','Constraints/Angle  Constraint','R2012a';
        'Point-Curve Constraint','Constraints/Point on Curve Constraint','R2015b';
        'Distance Driver','Constraints/Distance  Constraint','R2012a'};
else
    ConstraintMapping={...
        'Gear Constraint','Gears and Couplings/Gears/Common Gear Constraint','R2012a';...
        'Angle Driver','Constraints/Angle Constraint','R2012a';
        'Parallel Constraint','Constraints/Angle Constraint','R2012a';
        'Point-Curve Constraint','Constraints/Point on Curve Constraint','R2015b';
        'Distance Driver','Constraints/Distance Constraint','R2012a'};
end

% ADD SUBSYSTEM FOR CONSTRAINT BLOCKS
cnssys_h = add_block('simulink/Ports & Subsystems/Subsystem',[Dst_mdl '/Constraints'],...
    'Position',[445    40   525   100]);

% CLEAN OUT NEW SUBSYSTEM
in_h = find_system(cnssys_h,'Name','In1');
out_h = find_system(cnssys_h,'Name','Out1');
delete_line(cnssys_h,'In1/1','Out1/1');
delete_block(in_h);
delete_block(out_h);
cnssys_pth = getfullname(cnssys_h);

num_warnings = 0;

% INITIALIZE LOOP VARIABLES
subsys_pos_last = subsystem_2g_pos;
opsys_pos_last  = open_subsys_pos;
body_off_ud_total = [0 0 0 0];

% LOOP OVER GROUND BLOCKS
for i=1:length(cns_param)
    convSM1G2GMsg(['*** Creating Constraint ' regexprep(char(cns_param(i).Name),'\n',' ')]);
    
    % CALCULATE OFFSETS FOR SUBSYSTEMS
    pos_rect = cns_param(i).Position;
    body_off_size = [0 0 (pos_rect(3)-pos_rect(1)) (pos_rect(4)-pos_rect(2))];
    body_off_ud = [0 1 0 1]*(pos_rect(4)-pos_rect(2)+subsystem_gap);
    
    % ADD SUBSYSTEM WITH CALLBACK TO SHOW CONSTRAINT BLOCK IN 1G MODEL
    opsys_h = add_block('simulink/Ports & Subsystems/Subsystem',[cnssys_pth '/View Original Constraint ' strrep(char(cns_param(i).Name),'/','//')],...
        'MakeNameUnique', 'on');
    set_param(opsys_h,...
        'Position',opsys_pos_last,...
        'DropShadow','on',...
        'MaskDisplay',['disp([''View Original Constraint ' regexprep(char(cns_param(i).Name),'\n',' ') ''']);'],...
        'ShowName','off',...
        'OpenFcn',['hilite_system(''' regexprep(char(cns_param(i).BlockPath),'\n',' ') ''');']);
    
    % CLEAN OUT NEW SUBSYSTEM
    in_h = find_system(opsys_h,'Name','In1');
    out_h = find_system(opsys_h,'Name','Out1');
    delete_line(opsys_h,'In1/1','Out1/1');
    delete_block(in_h);
    delete_block(out_h);
    
    % ADD 2G CONSTRAINT BLOCK
    cns_type1G = cns_param(i).ConstraintType;
    cns_type2G = char(ConstraintMapping(find(strcmp(ConstraintMapping(:,1),cns_type1G)),2));
    releaseOK = char(ConstraintMapping(find(strcmp(ConstraintMapping(:,1),cns_type1G)),3));
    
    if(~isempty(cns_type2G) && ~verLessThan('matlab',release2ver(releaseOK)))
        % Add constraint block if it is not Point-Curve Constraint
        % Point-Curve Constraint should go in a subsystem
        if(~strcmp(cns_type1G,'Point-Curve Constraint'))
            cns_h = add_block(['sm_lib/' cns_type2G],[cnssys_pth '/' strrep(char(cns_param(i).Name),'/','//')],...
                'MakeNameUnique', 'on',...
                'Orientation',char(cns_param(i).Orientation),...
                'Position',subsys_pos_last+body_off_size);
        end
        if(strcmp(cns_type1G,'Gear Constraint'))
            base_rad = get_param(cns_param(i).Handle,'BaseRadius');
            base_radu = get_param(cns_param(i).Handle,'BaseRadiusUnits');
            foll_rad = get_param(cns_param(i).Handle,'FollowerRadius');
            foll_radu = get_param(cns_param(i).Handle,'FollowerRadiusUnits');
            set_param(cns_h,...
                'SpecificationType','PitchCircleRadii',...
                'BaseGearRadius',base_rad,...
                'BaseGearRadiusUnits',base_radu,...
                'FollGearRadius',foll_rad,...
                'FollGearRadiusUnits',foll_radu);
            convSM1G2GMsg([regexprep(char(cns_param(i).Name),'\n',' ') ': Internal/External not verified']);
            convSM1G2GMsg([regexprep(char(cns_param(i).Name),'\n',' ') ': Gear axis orientation not verified']);
            ann_str = sprintf('%s\n%s',[cnssys_pth '/Internal//External not verified'],'Gear axis orientation not verified');
            annotate2GBlks('fix_2G',ann_str,'left',...
                opsys_pos_last+[0 5 0 5]+[0 1 0 1]*(open_subsys_pos(4)-open_subsys_pos(2)));
        elseif(strcmp(cns_type1G,'Point-Curve Constraint'))
            % In 2G, Point on Curve constraint requires a separate block
            % to define the spline.  This code puts both in one subsystem.
            %
            % To match the orientation of the 1G block, the subsystem is
            % created with default orientation, blocks are added to the
            % subsystem with a pre-defined orientation, and the subsystem
            % is then reoriented to match the 1G orientation at the end.
            
            block_origin = [200 0 200 0];
            
            % ADD SUBSYSTEM FOR SPLINE BLOCK
            sys_h = add_block('simulink/Ports & Subsystems/Subsystem',[cnssys_pth '/' strrep(char(cns_param(i).Name),'/','//')],...
                'MakeNameUnique', 'on',...
                'Orientation','right',...
                'Position',subsys_pos_last+body_off_size);
            sys_pth = getfullname(sys_h);
            
            % CLEAN OUT NEW SUBSYSTEM
            in_h = find_system(sys_h,'Name','In1');
            out_h = find_system(sys_h,'Name','Out1');
            delete_line(sys_h,'In1/1','Out1/1');
            delete_block(in_h);
            delete_block(out_h);
            name = get_param(sys_h,'Name');
            
            % ADD SPLINE BLOCK
            spl_h = add_block(['sm_lib/Curves and Surfaces/Spline'],[sys_pth '/Spline'],...
                'MakeNameUnique', 'on',...
                'Orientation','right',...
                'Position',block_origin+body_off_size);
            
            % GET PARAMETERS
            xpts = get_param(cns_param(i).Handle,'Xbreaks');
            ypts = get_param(cns_param(i).Handle,'Ybreaks');
            zpts = get_param(cns_param(i).Handle,'Zbreaks');
            endc = get_param(cns_param(i).Handle,'EndConditions');
            canx = get_param(cns_param(i).Handle,'CanExtrapolate');
            
            % In 1G, the spline points were defined as 3 vectors which
            % could be 1xn or nx1.  In 2G the spline must be an nx3 matrix.
            % MATLAB command reshape() is used to ensure the definition
            % matches the 2G convention.
            set_param(spl_h,'DataPoints',[...
                '[reshape(' xpts ',[],1)'...
                ' reshape(' ypts ',[],1)'...
                ' reshape(' zpts ',[],1)]']);
            switch lower(endc)
                case 'periodic'
                    ec2G = 'Closed';
                case 'natural'
                    ec2G = 'Natural';
                otherwise
                    % Not-a-knot option in 1G is not offered in 2G as it is
                    % very close to natural.  Use cases where Not-a-knot is
                    % critical should be brought to MathWorks attention.
                    ec2G = 'Natural';
                    ann_str = sprintf('%s',[cnssys_pth '/Not-a-knot option in 1G']);
                    annotate2GBlks('fix_2G',ann_str,'left',...
                        opsys_pos_last+[0 5 0 5]+[0 1 0 1]*(open_subsys_pos(4)-open_subsys_pos(2)));
            end
            set_param(spl_h,'EndConditionType',ec2G);
            if(strcmp(canx,'on'))
                % Point Falls off Curve is not offered in 2G
                convSM1G2GMsg([regexprep(char(cns_param(i).Name),'\n',' ') ' No Point Falls off Curve option in 2G']);
                annotate2GBlks('fix_1G',[cnssys_pth '/No Point Falls off Curve option in 2G'],'left',...
                    opsys_pos_last+[0 25 0 25]+[0 1 0 1]*(open_subsys_pos(4)-open_subsys_pos(2)));
                num_warnings=num_warnings+1;
            end
            
            % ADD CONSTRAINT BLOCK
            poc_h = add_block(['sm_lib/' cns_type2G],[sys_pth '/Point on Curve Constraint'],...
                'MakeNameUnique', 'on',...
                'Orientation','right',...
                'Position',block_origin+body_off_size+[1 0 1 0]*(body_off_size(4)+20)*1.5);
            
            add_line(sys_pth,'Spline/RConn1','Point on Curve Constraint/LConn1',...
                    'Autorouting','on');
            
            pt_offset = ConnPort_2G_pos_l+ConnPort_2G_off_size;
                
            Ppt_h = add_block('nesl_utility/Connection Port',[sys_pth '/Connection Port'],...
                'Name','P',...
                'Position',block_origin+ConnPort_2G_off_size+...
                [1 0 1 0]*(body_off_size(4)+20)*3+[0 1 0 1]*15,...
                'Orientation','left',...
                'Side','left');

            add_line(sys_pth,'P/RConn1','Point on Curve Constraint/RConn1',...
                    'Autorouting','on');

            Cpt_h = add_block('nesl_utility/Connection Port',[sys_pth '/Connection Port'],...
                'Name','C',...
                'Position',block_origin+ConnPort_2G_off_size+...
                [1 0 1 0]*(body_off_size(4)+20)*(-1.5)+[0 1 0 1]*15,...
                'Orientation','right',...
                'Side','right');
            
            add_line(sys_pth,'C/RConn1','Spline/LConn1',...
                    'Autorouting','on');

            % Rename Point on Curve block to match library
            set_param(poc_h,'Name',sprintf('%s\n%s','Point on Curve','Constraint'));
            
            % Set orientation to match 1G block
            set_param(sys_pth,'Orientation',char(cns_param(i).Orientation));
            
        elseif(strcmp(cns_type1G,'Parallel Constraint'))
            % Parallel Constraint is implemented by Angle Constraint in 2G
            axisData{1} = get_param(cns_param(i).Handle,'CSys');
            axisData{2} = get_param(cns_param(i).Handle,'Axis');
            primitive_err=check_joint_primitives(...
                'Angle Constraint','R1',axisData,cns_param(i).Handle);
            annotate2GBlks('fix_1G',[cnssys_pth ...
                '/Axis: Ref=' axisData{1},...
                ' | Axis=' axisData{2}],...
                'left',opsys_pos_last+[0 5 0 5]+[0 1 0 1]*(open_subsys_pos(4)-open_subsys_pos(2)));
            num_warnings=num_warnings+1;
            set_param(cns_h,'ConstraintType','Parallel');
        end
    else
        if(~isempty(cns_type2G))
            warn_str = [' 2G equivalent added in release ' releaseOK];
        else
            warn_str = [' No automatic conversion for 1G constraint: ' cns_type1G];
        end
        convSM1G2GMsg([regexprep(char(cns_param(i).Name),'\n',' ') warn_str]);
        annotate2GBlks('fix_1G',[cnssys_pth '/' warn_str],'left',...
            opsys_pos_last+[0 5 0 5]+[0 1 0 1]*(open_subsys_pos(4)-open_subsys_pos(2)));
        num_warnings=num_warnings+1;
    end
    
    % INCREMENT VERTICAL POSITION OF BLOCKS
    body_off_ud_total = body_off_ud_total+body_off_ud;
    subsys_pos_last = subsystem_2g_pos+body_off_ud_total;
    opsys_pos_last = open_subsys_pos+body_off_ud_total;
    
end

if(num_warnings>0)
    set_param(cnssys_h,'BackGroundColor','[1, 0.75, 0.75]');
end
if(num_warnings==0 && ~isempty(cns_param))
    set_param(cnssys_h,'BackGroundColor','[0.75, 1, 0.75]');
end
