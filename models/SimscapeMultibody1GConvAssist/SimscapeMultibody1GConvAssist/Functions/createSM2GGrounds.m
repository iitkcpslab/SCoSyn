function num_warnings = createSM2GGrounds(ground_param,Dst_mdl)
% createSM2GGrounds - Create Simscape Multibody 2G equivalents for 1G grounds

% Copyright 2014-2019 The MathWorks Inc.

% BLOCK POSITIONS (RECTANGLE)
subsystem_2g_pos   = [260  29  260  29];
open_subsys_pos    = [ 50  29  240  51];
subsystem_gap      = 30;

Transform_2g_pos_l = [150 100  150 100];
Transform_2g_off_lr= [ 80   0   80   0];
Transform_2g_off_ud= [  0  80    0  80];
Transform_2g_off_size=[ 0   0   40  40];

ConnPort_2G_pos_r =  [550 111  550 111];
ConnPort_2G_off_size= [ 0   0   30  18];

num_warnings = 0;
num_blk_warnings = 0;


% ADD SUBSYSTEM FOR GROUND BLOCKS
gndsys_h = add_block('simulink/Ports & Subsystems/Subsystem',[Dst_mdl '/Grounds'],...
    'Position',[320    40   400   100]);

% CLEAN OUT NEW SUBSYSTEM
in_h = find_system(gndsys_h,'Name','In1');
out_h = find_system(gndsys_h,'Name','Out1');
delete_line(gndsys_h,'In1/1','Out1/1');
delete_block(in_h);
delete_block(out_h);
gndsys_pth = getfullname(gndsys_h);

% INITIALIZE LOOP VARIABLES
subsys_pos_last = subsystem_2g_pos;
opsys_pos_last  = open_subsys_pos;
body_off_ud_total = [0 0 0 0];

% LOOP OVER GROUND BLOCKS
for i=1:length(ground_param)
    convSM1G2GMsg(['*** Creating Ground ' regexprep(char(ground_param(i).Name),'\n',' ')]);
    num_blk_warn = 0;
    
    % CALCULATE OFFSETS FOR SUBSYSTEMS
    pos_rect = ground_param(i).Position;
    body_off_size = [0 0 (pos_rect(3)-pos_rect(1)) (pos_rect(4)-pos_rect(2))];
    body_off_ud = [0 1 0 1]*(pos_rect(4)-pos_rect(2)+subsystem_gap);
    
    % ADD SUBSYSTEM WITH CALLBACK TO SHOW BODY BLOCK IN 1G MODEL
    opsys_h = add_block('simulink/Ports & Subsystems/Subsystem',[gndsys_pth '/View Original Ground ' strrep(char(ground_param(i).Name),'/','//')],...
        'MakeNameUnique', 'on');
    set_param(opsys_h,...
        'Position',opsys_pos_last,...
        'DropShadow','on',...
        'MaskDisplay',['disp([''View Original Ground ' regexprep(char(ground_param(i).Name),'\n',' ') ''']);'],...
        'ShowName','off',...
        'OpenFcn',['hilite_system(''' regexprep(char(ground_param(i).BlockPath),'\n',' ') ''');']);
    
    % CLEAN OUT NEW SUBSYSTEM
    in_h = find_system(opsys_h,'Name','In1');
    out_h = find_system(opsys_h,'Name','Out1');
    delete_line(opsys_h,'In1/1','Out1/1');
    delete_block(in_h);
    delete_block(out_h);
    
    % ADD SUBSYSTEM FOR GROUND BLOCK
    gnd_h = add_block('simulink/Ports & Subsystems/Subsystem',[gndsys_pth '/' strrep(char(ground_param(i).Name),'/','//')],...
        'MakeNameUnique', 'on',...
        'Orientation',char(ground_param(i).Orientation),...
        'Position',subsys_pos_last+body_off_size);
    gnd_pth = getfullname(gnd_h);
    
    % CLEAN OUT NEW SUBSYSTEM
    in_h = find_system(gnd_pth,'Name','In1');
    out_h = find_system(gnd_pth,'Name','Out1');
    delete_line(gnd_pth,'In1/1','Out1/1');
    delete_block(in_h);
    delete_block(out_h);
    name = get_param(gnd_pth,'Name');
    
    % INCREMENT VERTICAL POSITION OF BLOCKS
    body_off_ud_total = body_off_ud_total+body_off_ud;
    subsys_pos_last = subsystem_2g_pos+body_off_ud_total;
    opsys_pos_last = open_subsys_pos+body_off_ud_total;
    
    % ADD WORLD
    wf_blk = 'sm_lib/Frames and Transforms/World Frame';
    % ADJUST FOR DIFFERENT LIBRARY PATHS R2012a-R2013a
    ver_str = version('-release');
    if (strcmpi(ver_str,'2012a') || strcmpi(ver_str,'2012b') || strcmpi(ver_str,'2013a'))
        wf_blk = 'sm_lib/Frames and  Transforms/World Frame';
    end
    wld_h = add_block(wf_blk,[gnd_pth '/World Frame'],...
        'Position',Transform_2g_pos_l+Transform_2g_off_size,...
        'Orientation','right');
    wld_pth = getfullname(wld_h);
    
    % ADD PORT
    pt_h = add_block('nesl_utility/Connection Port',[gnd_pth '/Connection Port'],...
        'Name','W',...
        'Position',ConnPort_2G_pos_r+[-1 0 -1 0]*140+ConnPort_2G_off_size,...
        'Orientation','left',...
        'Side','right');
    
    % ADD TRANSFORM IF NON-ZERO COORDINATE
    if(~strcmp(char(ground_param(i).XYZOffset),'[0 0 0]'))
        % ADD TRANSFORM
        rt_blk = 'sm_lib/Frames and Transforms/Rigid Transform';
        % ADJUST FOR DIFFERENT LIBRARY PATHS R2012a-R2013a
        ver_str = version('-release');
        if (strcmpi(ver_str,'2012a') || strcmpi(ver_str,'2012b') || strcmpi(ver_str,'2013a'))
            rt_blk = 'sm_lib/Frames and  Transforms/Rigid  Transform';
        end
        fr_h = add_block(rt_blk,...
            [gnd_pth '/Transform ' strrep(char(ground_param(i).Name),'/','//')]);
        set_param(fr_h,...
            'Position',Transform_2g_pos_l+Transform_2g_off_lr+[40 0 40 0]+Transform_2g_off_size,...
            'Orientation','right',...
            'TranslationMethod','Cartesian',...
            'TranslationCartesianOffset',char(ground_param(i).XYZOffset),...
            'TranslationLengthUnit',char(ground_param(i).XYZOffsetUnits));
        add_line(gnd_pth,...
            'World Frame/RConn1',['Transform ' strrep(char(ground_param(i).Name),'/','//') '/LConn1'],...
            'Autorouting','on');
        add_line(gnd_pth,...
            ['Transform ' strrep(char(ground_param(i).Name),'/','//') '/RConn1'],'W/RConn1',...
            'Autorouting','on');
    else
        add_line(gnd_pth,...
            'World Frame/RConn1','W/RConn1',...
            'Autorouting','on');
    end
    
    % ADD MECHANISM CONFIGURATION IF 1G MODEL HAD MACHINE ENVIRONMENT BLOCK
    if(~isempty(ground_param(i).GravityVector))
        % R2013a
        mc_blk = 'sm_lib/Utilities/Mechanism Configuration';
        % ADJUST FOR DIFFERENT LIBRARY PATHS R2012a-R2013a
        ver_str = version('-release');
        if (strcmpi(ver_str,'2012a') || strcmpi(ver_str,'2012b') || strcmpi(ver_str,'2013a'))
            mc_blk = 'sm_lib/Utilities/Mechanism  Configuration';
        end
        mc_h = add_block(mc_blk,...
            [gnd_pth '/Mechanism Configuration']);
        set_param(mc_h,...
            'Position',Transform_2g_pos_l+Transform_2g_off_ud+Transform_2g_off_size,...
            'Orientation','right',...
            'GravityVector',char(ground_param(i).GravityVector),...
            'GravityUnits',char(ground_param(i).GravityUnits));
        add_line(gnd_pth,...
            'Mechanism Configuration/RConn1','World Frame/RConn1',...
            'Autorouting','on');
        if(strcmpi(char(ground_param(i).GravityAsSignal),'on'))
            if(verLessThan('matlab',release2ver('R2014a')))
                convSM1G2GMsg('Gravity input as signal');
                num_warnings=num_warnings+1;
                num_blk_warn=num_blk_warn+1;
                annotate2GBlks('fix_1G',[gnd_pth '/Gravity input as signal'],'right',...
                    Transform_2g_pos_l+Transform_2g_off_ud+Transform_2g_off_size+[-10 20 0 20]);
            else
                set_param(mc_h,'UniformGravity','TimeVarying');
                pt_h = add_block('nesl_utility/Connection Port',[gnd_pth '/Connection Port'],...
                    'Name','g',...
                    'Position',Transform_2g_pos_l-[1 0 1 0]*80+Transform_2g_off_ud+[0 1 0 1]*10+ConnPort_2G_off_size,...
                    'Orientation','right',...
                    'Side','left');
                add_line(gnd_pth,...
                    'Mechanism Configuration/LConn1','g/RConn1',...
                    'Autorouting','on');
            end
        end
    end
    if(num_blk_warn>0)
        annotate2GBlks('fix_1G',[gndsys_pth '/' num2str(num_blk_warn) ' warnings'],'left',...
            opsys_pos_last-body_off_ud+[0 5 0 5]+[0 1 0 1]*(open_subsys_pos(4)-open_subsys_pos(2)));
    end
end
if(num_warnings>0)
    set_param(gndsys_h,'BackGroundColor','[1, 0.75, 0.75]');
end
if(num_warnings==0 && ~isempty(ground_param))
    set_param(gndsys_h,'BackGroundColor','[0.75, 1, 0.75]');
end
