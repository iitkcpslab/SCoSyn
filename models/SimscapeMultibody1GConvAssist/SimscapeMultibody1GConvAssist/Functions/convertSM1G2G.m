function convertSM1G2G(Source_mdl, varargin)
%convertSM1G2G - Convert Simscape Multibody 1G blocks to 2G equivalents
%  convertSM1G2G(source_model, <destination_model>, <report>)
%  For use with MATLAB R2013a and higher
%
%  This MATLAB function assists in the conversion of Simscape Multibody 1G models
%  to Simscape Multibody 2G technology.  It can produce a report indicating
%  elements which have no direct 2G equivalent.  It can also convert joints,
%  grounds, and constraints to Simscape Multibody Second Generation equivalents.
%
%  >> convertSM1G2G('MySM1GModel')
%     Report 1G-only elements to Command Window
%
%  >> convertSM1G2G('MySM1GModel',where) Report 1G-only elements
%     "where" controls where conversion messages are shown or saved
%           'cmdwindow' Command Window only
%           'file'      Text file only [Src_mdl '_conv1G2G.txt']
%           'both'      Text file and Command Window
%
%  >> convertSM1G2G('MySM1GModel','My2GBlocks')
%     Create model 'My2GBlocks' with 2G equivalents for 1G blocks in 'MySM1GModel'
%     Messages shown in Command window only
%
%  >> convertSM1G2G('MySM1GModel','My2GBlocks',where)
%     Create model 'My2GBlocks' with 2G equivalents and report
%
%  Due to the different conventions used in the two technologies, not
%  everything can be converted automatically to the new model.
%  Blocks in the new model are annotated with information indicating
%  where manual adjustments are required.
%
%  The recommended process for converting from Simscape Multibody 1G to 2G
%  is to use the diagnostics from this tool to identify and eliminate
%  modeling constructs in 1G models that are not available in 2G.
%
%  Add subfolders 'Functions' and 'Help' to your path.

% Copyright 2014-2019 The MathWorks Inc.

% OPEN MODELS
[Src_path,Src_mdl] = fileparts(Source_mdl);

open_system([Src_path Src_mdl]);

if (nargin==1)
    Dst_mdl=[];
    where='cmdwindow';
end

if (nargin==2)
    if (strcmp(varargin(1),'both')||strcmp(varargin(1),'file')||strcmp(varargin(1),'cmdwindow'))
        Dst_mdl=[];
        where=varargin{1};
    else
        Dst_mdl = varargin{1};
        where='cmdwindow';
    end
end

if (nargin==3)
    Dst_mdl = varargin{1};
    where=varargin{2};
end

convSM1G2GMsg([],Src_mdl,where)

if (~isempty(Dst_mdl))
    try
        new_system(Dst_mdl,'Library');
    catch
        bdclose(Dst_mdl);
        new_system(Dst_mdl,'Library');
    end
    open_system(Dst_mdl);
    
    ann_str = sprintf('%s\n%s',[Dst_mdl '/Converted Simscape Multibody 2G elements for model'],Src_mdl);
    add_block('built-in/Note',ann_str,...
        'HorizontalAlignment','center',...
        'FontSize','12',...
        'Position',[300   150   315   150])
end

if (~isempty(Dst_mdl))
    body_param   = getSM1GBodies(Src_mdl);
    num_bdy_warn = createSM2GBodies(body_param,Dst_mdl);
    joint_param  = getSM1GJoints(Src_mdl);
    num_jnt_warn = createSM2GJoints(joint_param,Dst_mdl);
    ground_param = getSM1GGrounds(Src_mdl);
    num_gnd_warn = createSM2GGrounds(ground_param,Dst_mdl);
    cns_param    = getSM1GConstraints(Src_mdl);
    num_cns_warn = createSM2GConstraints(cns_param,Dst_mdl);
end

blk_param    = scan1Gmodel(Src_mdl);

if (~isempty(Dst_mdl))
    num_blk_warn = createSM2GScan(blk_param,Dst_mdl);
    annotate2GBlks('info',[Dst_mdl '/' num2str(length(body_param)) ' Bodies, ' num2str(num_bdy_warn) ' may need adjustments in 1G model.'],...
            'left',[60    210   140   210]);
    annotate2GBlks('info',[Dst_mdl '/' num2str(length(joint_param)) ' Joints, ' num2str(num_jnt_warn) ' may need adjustments in 1G model.'],...
            'left',[60    230   140   230]);
    annotate2GBlks('info',[Dst_mdl '/' num2str(length(ground_param)) ' Grounds, ' num2str(num_gnd_warn) ' may need adjustments in 1G model.'],...
            'left',[60    250   140   250]);
    annotate2GBlks('info',[Dst_mdl '/' num2str(length(cns_param)) ' Constraints, ' num2str(num_cns_warn) ' may need adjustments in 1G model.'],...
            'left',[60    270   140   270]);
    annotate2GBlks('info',[Dst_mdl '/' num2str(length(blk_param)) ' elements with no direct 2G conversion.'],...
            'left',[60    290   140   290]);
    
    docsys_h = add_block('simulink/Ports & Subsystems/Subsystem',[Dst_mdl '/Doc'],...
        'MakeNameUnique', 'on');
    set_param(docsys_h,...
        'Position',[370   214   480   266],...
        'DropShadow','on',...
        'MaskDisplay',['disp(''Double-click\nfor Information\nabout Diagnostics'');'],...
        'ShowName','off',...
        'OpenFcn',['web(''SM1G2G_Warnings_Help.html'');']);
    % CLEAN OUT NEW SUBSYSTEM
    in_h = find_system(docsys_h,'Name','In1');
    out_h = find_system(docsys_h,'Name','Out1');
    delete_line(docsys_h,'In1/1','Out1/1');
    delete_block(in_h);
    delete_block(out_h);
end

if strcmp(where,'both')||strcmp(where,'file')
    convSM1G2GMsg('END OF REPORT');
end
