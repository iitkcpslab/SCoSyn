function num_warnings = createSM2GBodies(body_param,Dst_mdl)
% createSM2GBodies - Create Simscape Multibody 2G equivalents for 1G bodies

% Copyright 2014-2019 The MathWorks Inc.

% BLOCK POSITIONS (RECTANGLE)
subsystem_2g_pos   = [260  29  260  29];
open_subsys_pos    = [ 50  29  240  51];
solid_2g_pos       = [300  25  340  65];
subsystem_gap      = 30;

Transform_2g_pos_r = [450 100  450 100];
Transform_2g_pos_l = [150 100  150 100];
Transform_2g_off_ud= [  0  80    0  80];
Transform_2g_off_size=[ 0   0   40  40];

inertia_2g_pos     = solid_2g_pos+[1 0 1 0]*(Transform_2g_pos_r(1)-solid_2g_pos(1));

ConnPort_2G_pos_l =  [ 60 111   60 111];
ConnPort_2G_pos_r =  [550 111  550 111];
ConnPort_2G_off_size= [ 0   0   30  18];

num_warnings = 0;

% ADD SUBSYSTEM FOR BODIES
bodsys_h = add_block('simulink/Ports & Subsystems/Subsystem',[Dst_mdl '/Bodies'],...
    'Position',[60    40   140   100]);
% CLEAN OUT NEW SUBSYSTEM
in_h = find_system(bodsys_h,'Name','In1');
out_h = find_system(bodsys_h,'Name','Out1');
delete_line(bodsys_h,'In1/1','Out1/1');
delete_block(in_h);
delete_block(out_h);
bodsys_pth = getfullname(bodsys_h);

% INITIALIZE LOOP VARIABLES
subsys_pos_last = subsystem_2g_pos;
opsys_pos_last  = open_subsys_pos;
body_off_ud_total = [0 0 0 0];

% LOOP OVER BODY BLOCKS
for i=1:length(body_param)
    num_blk_warn=0;
    convSM1G2GMsg(['*** Creating Body ' regexprep(char(body_param(i).Name),'\n',' ')]);
    
    % CALCULATE OFFSETS FOR SUBSYSTEMS
    pos_rect = body_param(i).Position;
    body_off_size = [0 0 (pos_rect(3)-pos_rect(1)) (pos_rect(4)-pos_rect(2))];
    body_off_ud = [0 1 0 1]*(pos_rect(4)-pos_rect(2)+subsystem_gap);
    
    % ADD SUBSYSTEM WITH CALLBACK TO SHOW BODY BLOCK IN 1G MODEL
    opsys_h = add_block('simulink/Ports & Subsystems/Subsystem',[bodsys_pth '/View Original Body ' strrep(char(body_param(i).Name),'/','//')],...
        'MakeNameUnique', 'on');
    set_param(opsys_h,...
        'Position',opsys_pos_last,...
        'DropShadow','on',...
        'MaskDisplay',['disp(['' View Original Body ' regexprep(char(body_param(i).Name),'\n',' ') ''']);'],...
        'ShowName','off',...
        'OpenFcn',['hilite_system(''' regexprep(char(body_param(i).BlockPath),'\n',' ') ''');']);
    % CLEAN OUT NEW SUBSYSTEM
    in_h = find_system(opsys_h,'Name','In1');
    out_h = find_system(opsys_h,'Name','Out1');
    delete_line(opsys_h,'In1/1','Out1/1');
    delete_block(in_h);
    delete_block(out_h);
    
    % ADD SUBSYSTEM FOR BODY BLOCK
    sys_h = add_block('simulink/Ports & Subsystems/Subsystem',[bodsys_pth '/' strrep(char(body_param(i).Name),'/','//')],...
        'MakeNameUnique', 'on',...
        'Orientation',char(body_param(i).Orientation),...
        'Position',subsys_pos_last+body_off_size);
    sys_pth = getfullname(sys_h);
    % CLEAN OUT NEW SUBSYSTEM
    in_h = find_system(sys_h,'Name','In1');
    out_h = find_system(sys_h,'Name','Out1');
    delete_line(sys_h,'In1/1','Out1/1');
    delete_block(in_h);
    delete_block(out_h);
    name = get_param(sys_h,'Name');
    
    % INCREMENT VERTICAL POSITION OF BLOCKS
    body_off_ud_total = body_off_ud_total+body_off_ud;
    subsys_pos_last = subsystem_2g_pos+body_off_ud_total;
    opsys_pos_last = open_subsys_pos+body_off_ud_total;
    
    % EXTRACT INERTIA MATRIX (1G) TO VECTORS (2G)
    try
        inertia_temp = slResolve('Inertia', body_param(i).Handle, 'variable');
        % IF slresolve DOESN'T WORK, REVERT TO evalin
        %inertia_temp = evalin('base',body_param(i).MomentsOfInertia);
        body_param(i).ProductsOfInertia = ['[' num2str([inertia_temp(2,3) inertia_temp(1,3) inertia_temp(1,3)]) ']'];
        body_param(i).MomentsOfInertia = ['[' num2str([inertia_temp(1,1) inertia_temp(2,2) inertia_temp(3,3)]) ']'];
        inertia_val = 'Accessible';
    catch
        body_param(i).ProductsOfInertia = '[0 0 0]';
        body_param(i).MomentsOfInertia = '[0 0 0]';
        inertia_val = 'Not Accessible';
    end
    
    % ADD SOLID
    solid_on_CG = 1; % ASSUME SOLID IS ATTACHED TO CG FRAME
    sld_h = add_block('sm_lib/Body Elements/Solid',[sys_pth '/Solid']);
    set_param(sld_h,'Orientation','down',...
        'Position',solid_2g_pos,...
        'InertiaType','Custom',...
        'Mass',char(body_param(i).Mass),...
        'MassUnits',char(body_param(i).MassUnits),...
        'MomentsOfInertia',char(body_param(i).MomentsOfInertia),...
        'MomentsOfInertiaUnits',char(body_param(i).MomentsOfInertiaUnits),...
        'ProductsOfInertia',char(body_param(i).ProductsOfInertia),...
        'ProductsOfInertiaUnits',char(body_param(i).MomentsOfInertiaUnits),...
        'GraphicDiffuseColor',char(body_param(i).GraphicDiffuseColor));
    convSM1G2GMsg('Inertia vectors hardcoded');
    if verLessThan('matlab','9.0')
        % Offset for MATLAB R2015b and earlier
        solid_ann_pos = solid_2g_pos+[-10 5 0 5];
    else
        % Offset for MATLAB R2016a and later
        solid_ann_pos = solid_2g_pos+[-140 5 -130 5];
    end
    
    annotate2GBlks('fix_2G',[sys_pth '/Inertia vectors hardcoded'],'right',solid_ann_pos);
    if(strcmp(inertia_val,'Not Accessible'))
        convSM1G2GMsg('Inertia vectors could not be extracted');
        if verLessThan('matlab','9.0')
            % Offset for MATLAB R2015b and earlier
            solid_ann_pos = solid_2g_pos+[-10 25 0 25];
        else
            % Offset for MATLAB R2016a and later
            solid_ann_pos = solid_2g_pos+[-200 25 -190 25];
        end
        annotate2GBlks('fix_2G',[sys_pth '/Inertia vectors could not be extracted'],'right',solid_ann_pos);
        num_blk_warn=num_blk_warn+1;
    end
    if(~isempty(char(body_param(i).ExtGeomFileName)))
        % ASSOCIATE GEOMETRY WITH SOLID BLOCK
        fname = char(body_param(i).ExtGeomFileName);
        ftype = upper(fname(end-2:end));
        attcs = char(body_param(i).AttachedToCS);
        stl_frame_data = getfield(body_param(i).Frames,attcs);
        stl_units = stl_frame_data{6};
        set_param(sld_h,'GeometryShape','FromFile',...
            'ExtGeomFileType',ftype,...
            'ExtGeomFileName',fname,...
            'ExtGeomFileUnits',stl_units);
        if(~strcmpi(char(body_param(i).AttachedToCS),'CG'))
            solid_on_CG = 0; % SOLID SHOULD NOT BE ATTACHED TO CG FRAME
            % CONVERT SOLID TO POINT MASS WITH NO MASS - GEOMETRY ONLY
            % REMOVE PARAMETERIZATION
            set_param(sld_h,...
                'InertiaType','PointMass',...
                'Mass','0',...
                'MomentsOfInertia','[0 0 0]',...
                'ProductsOfInertia','[0 0 0]');
            % ADD SOLID BLOCK WHICH CAN BE ATTACHED TO CG FRAME
            inr_h = add_block('sm_lib/Body Elements/Solid',[sys_pth '/Inertia']);
            set_param(inr_h,'Orientation','down',...
                'Position',inertia_2g_pos,...
                'InertiaType','Custom',...
                'GraphicType','None',...
                'Mass',char(body_param(i).Mass),...
                'MassUnits',char(body_param(i).MassUnits),...
                'MomentsOfInertia',char(body_param(i).MomentsOfInertia),...
                'MomentsOfInertiaUnits',char(body_param(i).MomentsOfInertiaUnits),...
                'ProductsOfInertia',char(body_param(i).ProductsOfInertia),...
                'ProductsOfInertiaUnits',char(body_param(i).MomentsOfInertiaUnits));
        end
    end
    
    % ADD TRANSFORMS
    numframes = length(fieldnames(body_param(i).Frames));
    framelist = fieldnames(body_param(i).Frames);
    rcnt=0;lcnt=0; % COUNT FOR VERTICAL POSITION ON LEFT AND RIGHT SIDES
    
    % LOOP OVER FRAMES
    for fr_num = 1:numframes
        frame_data = body_param(i).Frames.(char(framelist(fr_num)));
        frame_name = char(framelist(fr_num));
        % PLACE AND ORIENT TRANSFORM AND PORT BLOCK BASED ON PORT SIDE
        if strcmp(char(body_param(i).Frames.(char(framelist(fr_num)))(1)),'Right')
            xf_offset = Transform_2g_pos_r+Transform_2g_off_ud*(rcnt)+Transform_2g_off_size;
            pt_offset = ConnPort_2G_pos_r +Transform_2g_off_ud*(rcnt)+ConnPort_2G_off_size;
            pt_side = 'right';
            pt_ori = 'left';
            xf_ori = 'right';
            if strfind(lower(char(frame_data(4))),'adjoining')
                xf_ori = 'left';
            end
            rcnt=rcnt+1;
        else
            xf_offset = Transform_2g_pos_l+Transform_2g_off_ud*(lcnt)+Transform_2g_off_size;
            pt_offset = ConnPort_2G_pos_l +Transform_2g_off_ud*(lcnt)+ConnPort_2G_off_size;
            pt_side = 'left';
            pt_ori = 'right';
            xf_ori = 'left';
            if strfind(lower(char(frame_data(4))),'adjoining')
                xf_ori = 'right';
            end
            lcnt=lcnt+1;
        end
        
        % ADD TRANSFORM
        rt_blk = 'sm_lib/Frames and Transforms/Rigid Transform';
        % ADJUST FOR DIFFERENT LIBRARY PATHS R2012a-R2013a
        ver_str = version('-release');
        if (strcmpi(ver_str,'2012a') || strcmpi(ver_str,'2012b') || strcmpi(ver_str,'2013a'))
            rt_blk = 'sm_lib/Frames and  Transforms/Rigid  Transform';
        end
        fr_h = add_block(rt_blk,[sys_pth '/Rigid Transform']);
        set_param(fr_h,'Name',['Transform ' char(framelist(fr_num))],...
            'Position',xf_offset,...
            'Orientation',xf_ori,...
            'TranslationMethod','Cartesian',...
            'TranslationCartesianOffset',char(body_param(i).Frames.(char(framelist(fr_num)))(3)),...
            'TranslationLengthUnit',char(body_param(i).Frames.(char(framelist(fr_num)))(6)));
        
        % SET TRANSFORM ORIENTATION
        frame_orientation(body_param(i).Frames.(char(framelist(fr_num))),fr_h);
        
        % ADD PORT IF PORT IS EXPOSED ON 1G BODY BLOCK
        if(strcmp(char(body_param(i).Frames.(char(framelist(fr_num)))(11)),'true'))
            pt_h = add_block('nesl_utility/Connection Port',[sys_pth '/Connection Port'],...
                'Name',char(framelist(fr_num)),...
                'Position',pt_offset,...
                'Orientation',pt_ori,...
                'Side',pt_side);
            
            if strfind(lower(char(frame_data(4))),'adjoining')
                add_line(sys_pth,...
                    ['Transform ' char(framelist(fr_num)) '/LConn1'],[char(framelist(fr_num)) '/RConn1'],...
                    'Autorouting','on');
            else
                add_line(sys_pth,...
                    ['Transform ' char(framelist(fr_num)) '/RConn1'],[char(framelist(fr_num)) '/RConn1'],...
                    'Autorouting','on');
            end
        end
    end
    
    % ADD CONNECTIONS - LOOP OVER FRAMES AGAIN
    % (FRAMES MUST BE CREATED BEFORE ADDING CONNECTIONS)
    for fr_num = 1:numframes
        %** PREPARE ANNOTATION IF CONNECTION CANNOT BE CREATED
        % DETERMINE LOCATION AND ALIGNMENT BASED
        % ON FRAME POSITION AND ORIENTATION
        frame_data = body_param(i).Frames.(char(framelist(fr_num)));
        frame_name = char(framelist(fr_num));
        pos_data = get_param([sys_pth '/Transform ' frame_name],'Position');
        if(strcmp(char(body_param(i).Frames.(char(framelist(fr_num)))(1)),'Left'))
            xan_pos = pos_data+[50 -15 60 -15]; % ANNOTATION OFFSET LEFT
            xan_ori = 'left';
        else
            if verLessThan('matlab','9.0')
                % Offset for MATLAB R2015b and earlier
                xan_pos = pos_data+[-10 -15 0 -15];
            else
                % Offset for MATLAB R2016a and later
                xan_pos = pos_data+[-80 -15 -70 -15];
            end
            xan_ori = 'right';
        end
        % ANNOTATION STRING
        str_an = sprintf('%s\n%s\n%s\n%s',...
            [sys_pth '/' strrep(char(body_param(i).Frames.(char(framelist(fr_num)))(3)),'/','//')],...
            ['From:' char(frame_data(4))],...
            ['In:' char(frame_data(5))],...
            ['Ori:' char(frame_data(10))]);
        
        % DETERMINE IF CONNECTION CAN BE CREATED
        if strfind(lower(char(frame_data(4))),'world')
            % FRAME POSITIONED AND/OR ORIENTED RELATIVE TO WORLD
            % GENERATE WARNING
            convSM1G2GMsg([frame_name ' Ref Frame World: Reference frames should only be local or Adjoining']);
            annotate2GBlks('fix_1G',str_an,xan_ori,xan_pos);
            num_blk_warn=num_blk_warn+1;
        elseif (~strcmp(char(frame_data(4)),char(frame_data(5))) || ~strcmp(char(frame_data(4)),char(frame_data(10))))
            % FRAME POSITIONED AND/OR ORIENTED RELATIVE TO MULTIPLE FRAMES
            % GENERATE WARNING
            convSM1G2GMsg([frame_name ' Ref Frames Unmatched: Translated From, Axes in, and Relative CS should match']);
            annotate2GBlks('fix_1G',str_an,xan_ori,xan_pos);
            num_blk_warn=num_blk_warn+1;
        elseif strfind(lower(char(frame_data(4))),'adjoining')
            % ADJOINING FRAME CASE
            % 1. DO NOT CREATE CONNECTION TO ANOTHER TRANSFORM
            % 2. GENERATE MESSAGE IN REPORT AND BLOCK DIAGRAM BUT NO WARNING
            %    USER MUST VERIFY DOWNSTREAM FRAMES
            convSM1G2GMsg([frame_name ' Ref Frame Adjoining: Check downstream frame positions and orientations']);
            str_an = sprintf('%s\n%s\n%s\n%s\n%s',...
                [sys_pth '/' strrep(char(body_param(i).Frames.(char(framelist(fr_num)))(3)),'/','//')],...
                ['From:' char(frame_data(4))],...
                ['In:' char(frame_data(5))],...
                [char(frame_data(7))],...
                ['Ori:' char(frame_data(10))]);
            annotate2GBlks('info',str_an,xan_ori,xan_pos);
            % CODE FOR WARNING IF LATER NEEDED
            %if (strcmpi(char(frame_data(4)),'adjoining') && strcmpi(char(frame_data(10)),'adjoining')...
            %        && (strfind(lower(char(frame_data(8))),'euler') && strcmp(char(frame_data(7)),'[0 0 0]'))...
            %        && (strcmp(char(frame_data(3)),'[0 0 0]')))
            %else
            %    num_blk_warn=num_blk_warn+1;
            %end
        else
            % CONNECTION CAN BE CREATED
            srcframe = char(frame_data(4));
            dstframe = frame_name;
            % DEBUGGING
            %convSM1G2GMsg([frame_name ': Source = ' srcframe ', Dest = ' dstframe]);
            add_line(sys_pth,...
                ['Transform ' srcframe '/RConn1'],['Transform ' dstframe '/LConn1'],'Autorouting','on');
        end
    end
    
    % IDENTIFY FRAME TO WHICH THE SOLID BLOCK SHOULD CONNECT
    if (solid_on_CG)
        % CONNECT SOLID TO CG
        solid_fr = 'CG';
    else
        % CONNECT SOLID TO REFERENCE FRAME FOR GEOMETRY
        solid_fr = char(body_param(i).AttachedToCS);
        add_line(sys_pth,...
            ['Transform CG/RConn1'],'Inertia/RConn1','Autorouting','on');
    end
    % CONNECT SOLID
    add_line(sys_pth,...
        ['Transform ' solid_fr '/RConn1'],'Solid/RConn1','Autorouting','on');
    
    % ADD DIAGNOSTIC NOTE WITH NUMBER OF WARNINGS
    if(num_blk_warn>0)
        annotate2GBlks('fix_1G',[bodsys_pth '/' num2str(num_blk_warn) ' warnings'],'left',...
            opsys_pos_last-body_off_ud+[0 5 0 5]+[0 1 0 1]*(open_subsys_pos(4)-open_subsys_pos(2)));
        num_warnings=num_warnings+1;
    end
end

% SET SUBSYSTEM BACKGROUND COLOR TO RED IF THERE ARE WARNINGS
if(num_warnings>0)
    set_param(bodsys_h,'BackGroundColor','[1, 0.75, 0.75]');
end
% SET SUBSYSTEM BACKGROUND COLOR TO GREEN
% IF THERE ARE NO WARNINGS AND CONVERTED BLOCKS
% OTHERWISE, EMPTY SYSTEM STAYS GRAY
if(num_warnings==0 && ~isempty(body_param))
    set_param(bodsys_h,'BackGroundColor','[0.75, 1, 0.75]');
end

