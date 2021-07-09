function num_warnings = createSM2GScan(blk_param,Dst_mdl)
% createSM2GScan - Create links in Simulink model to
%                  Simscape Multibody 1G elements with no 2G direct equivalent

% Copyright 2014-2019 The MathWorks Inc.

% BLOCK POSITIONS (RECTANGLE)
initial_ann_offset = 70;
subsystem_2g_pos   = [260  29+initial_ann_offset  260  29+initial_ann_offset];
Transform_2g_off_ud= [  0  80    0  80];
open_subsys_pos    = [ 50  29+initial_ann_offset  240  51+initial_ann_offset];
subsystem_gap      = 80;

num_blk_warn = 0;
num_warnings = 0;

% ADD SUBSYSTEM FOR 1G ONLY BLOCKS
scansys_h = add_block('simulink/Ports & Subsystems/Subsystem',[Dst_mdl '/No direct conversion'],...
    'Position',[560    40   640   100]);

% CLEAN OUT NEW SUBSYSTEM
in_h = find_system(scansys_h,'Name','In1');
out_h = find_system(scansys_h,'Name','Out1');
delete_line(scansys_h,'In1/1','Out1/1');
delete_block(in_h);
delete_block(out_h);
scansys_pth = getfullname(scansys_h);

% INITIALIZE LOOP VARIABLES
subsys_pos_last = subsystem_2g_pos;
opsys_pos_last  = open_subsys_pos;
body_off_ud_total = [0 0 0 0];

for i=1:length(blk_param)
    num_blk_warn = 0;
    % CALCULATE OFFSETS FOR SUBSYSTEMS
    body_off_ud = Transform_2g_off_ud+subsystem_gap;
    
    % ADD SUBSYSTEM WITH CALLBACK TO SHOW JOINT BLOCK IN 1G MODEL
    opsys_h = add_block('simulink/Ports & Subsystems/Subsystem',[scansys_pth '/View Original Block ' strrep(char(blk_param(i).Name),'/','//')],...
        'MakeNameUnique', 'on');
    set_param(opsys_h,...
        'Position',opsys_pos_last,...
        'DropShadow','on',...
        'MaskDisplay',['disp(['' View Original Block ' regexprep(char(blk_param(i).Name),'\n',' ') ''']);'],...
        'ShowName','off',...
        'OpenFcn',['hilite_system(''' regexprep(char(blk_param(i).BlockPath),'\n',' ') ''');']);
    % CLEAN OUT NEW SUBSYSTEM
    in_h = find_system(opsys_h,'Name','In1');
    out_h = find_system(opsys_h,'Name','Out1');
    delete_line(opsys_h,'In1/1','Out1/1');
    delete_block(in_h);
    delete_block(out_h);
    
    annotate2GBlks('fix_1G',[scansys_pth '/' strrep(char(blk_param(i).WarnStr),'/','//')],'left',...
        opsys_pos_last+[0 5 0 5]+[0 1 0 1]*(open_subsys_pos(4)-open_subsys_pos(2)));
    
    % INCREMENT VERTICAL POSITION OF JOINTS
    body_off_ud_total = body_off_ud_total+Transform_2g_off_ud;
    subsys_pos_last = subsystem_2g_pos+body_off_ud_total;
    opsys_pos_last = open_subsys_pos+body_off_ud_total;
    num_warnings=num_warnings+num_blk_warn;
    
end

if(~isempty(blk_param))
    set_param(scansys_h,'BackGroundColor','red');
    num_warnings = length(blk_param);
    
    GlobalInfoStr = sprintf('%s\n%s\n%s\n%s',...
        'Elements below could not be converted by the Conversion Assistant.',...
        'Features are either not available in 2G, or depend on too many factors',...
        'for an automatic conversion. Look at the diagnostics, 2G libraries, and',...
        'documentation to see how to model this effect in 2G.');
    annotate2GBlks('info',[scansys_pth '/' strrep(GlobalInfoStr,'/','//')],'left',...
        open_subsys_pos-[0 1 0 1]*initial_ann_offset);
    
else
    set_param(scansys_h,'BackGroundColor','[0.75, 1, 0.75]');
    num_warnings = 0;
end




