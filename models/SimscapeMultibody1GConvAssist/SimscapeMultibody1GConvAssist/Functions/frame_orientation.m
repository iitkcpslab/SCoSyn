function frame_orientation(frame_data,block_handle)
% frame_orientation - Convert Simscape Multibody 1G orientation to 2G orientation

% Copyright 2014-2019 The MathWorks Inc.

% DETERMINE ROTATION SETTINGS FOR 2G TRANSFORM BLOCKS
body_sys = get_param(block_handle,'Parent');

if strfind(char(frame_data(8)),'Euler')
    % EXTRACT EULER ANGLES, RETAINING PARAMETERIZATION
    order = strrep(strrep(char(frame_data(8)),'Euler ',''),'-','');
    EUAng_str = char(frame_data(7));
    clear EUAng tEUAng
    tEUAng = strsplit(EUAng_str,' ');
    if (length(tEUAng)==1)
        % SINGLE VARIABLE CONTAINING VECTOR OF ANGLES - REFERENCE BY INDEX
        EUAng1 = [strrep(strrep(char(tEUAng),'[',''),']','') '(1)'];
        EUAng2 = [strrep(strrep(char(tEUAng),'[',''),']','') '(2)'];
        EUAng3 = [strrep(strrep(char(tEUAng),'[',''),']','') '(3)'];
        %disp(['EUAng OK: ' EUAngX ' ' EUAngY ' ' EUAngZ]);
    elseif (length(tEUAng)==3)
        % VECTOR OF ANGLES (VARIABLES OR HARDCODED) - REFERENCE ELEMENTS
        EUAng1 = strrep(char(tEUAng(1)),'[','');
        EUAng2 = char(tEUAng(2));
        EUAng3 = strrep(char(tEUAng(3)),']','');
        %disp(['EUAng OK: ' EUAngX ' ' EUAngY ' ' EUAngZ]);
    else
        convSM1G2GMsg(['EUAng unhandled case: ' EUAng]);
    end
    
    % CHECK FOR ROTATIONS ABOUT ONLY ONE AXIS
    EUA1Is0=strcmp(EUAng1,'0');
    EUA2Is0=strcmp(EUAng2,'0');
    EUA3Is0=strcmp(EUAng3,'0');
    if(EUA1Is0 && EUA2Is0 && EUA3Is0)
        % ROTATION IS NONE - NO CHANGE TO TRANSFORM BLOCK
    elseif(EUA1Is0 && EUA2Is0)
        % ROTATION IS ONLY ABOUT THIRD EULER ANGLE
        set_param(block_handle,'RotationMethod','StandardAxis',...
            'RotationStandardAxis',['+' order(3)],...
            'RotationAngle',EUAng3,...
            'RotationAngleUnits',char(frame_data(9)));
    elseif(EUA1Is0 && EUA3Is0)
        % ROTATION IS ONLY ABOUT SECOND EULER ANGLE
        set_param(block_handle,'RotationMethod','StandardAxis',...
            'RotationStandardAxis',['+' order(2)],...
            'RotationAngle',EUAng2,...
            'RotationAngleUnits',char(frame_data(9)));
    elseif(EUA2Is0 && EUA3Is0)
        % ROTATION IS ONLY ABOUT FIRST EULER ANGLE
        set_param(block_handle,'RotationMethod','StandardAxis',...
            'RotationStandardAxis',['+' order(1)],...
            'RotationAngle',EUAng1,...
            'RotationAngleUnits',char(frame_data(9)));
    else
        % ROTATION MATRIX STRING METHOD - NOT USED      
        %[RM] =  EUA_to_RotM_str(order,{EUAngX EUAngY EUAngZ},char(frame_data(9)));
        %disp(['RM: ' RM]);
        %set_param(block_handle,'RotationMethod','RotationMatrix',...
        %    'RotationMatrix',RM);

        %** REPLACE TRANSFORM WITH SUBSYSTEM CONTAINING 3 TRANSFORM BLOCKS
        % GET LOCATION, ORIENTATION, NAME OF CURRENT TRANSFORM BLOCK
        bl_pos = get_param(block_handle,'Position');
        bl_ori = get_param(block_handle,'Orientation');
        bl_nam = get_param(block_handle,'Name');
        % DELETE TRANSFORM BLOCK, ADD SUBSYSTEM
        delete_block(block_handle);
        xf_sys_h = add_block('simulink/Ports & Subsystems/Subsystem',[body_sys '/Subsystem'],'Name',bl_nam,...
            'Position',bl_pos,...
            'Orientation',bl_ori);
        xf_sys = [body_sys '/' bl_nam];        
        % CLEAN OUT NEW SUBSYSTEM
        in_h = find_system(xf_sys_h,'Name','In1');
        out_h = find_system(xf_sys_h,'Name','Out1');
        delete_line(xf_sys_h,'In1/1','Out1/1');
        delete_block(in_h);
        delete_block(out_h);
        
        frame_name = strrep(bl_nam,'Transform ','');
        
        % ADD B PORT
        add_block('nesl_utility/Connection Port',[xf_sys '/Connection Port'],'Name','B',...
            'Position',[40    86    70   104]);
        
        % ADD TRANSFORM FOR FIRST ROTATION AND CONNECT TO B PORT
        % APPLY TRANSLATION TO FIRST TRANSFORM
        add_block('sm_lib/Frames and Transforms/Rigid Transform',[xf_sys '/Rigid Transform'],...
            'Position',[125    75   165   115],'Name',[frame_name ' R' lower(order(1)) 'Txyz'],...
            'RotationMethod','StandardAxis',...
            'RotationStandardAxis',['+' order(1)],...
            'RotationAngle',EUAng1,...
            'RotationAngleUnits',char(frame_data(9)),...
            'TranslationMethod','Cartesian',...
            'TranslationCartesianOffset',char(frame_data(3)),...
            'TranslationLengthUnit',char(frame_data(6)));
        add_line(xf_sys_h,'B/RConn1',[frame_name ' R' lower(order(1)) 'Txyz/LConn1']);
        
        % ADD TRANSFORM FOR 2ND ROTATION AND CONNECT TO 1ST TRANSFORM
        add_block('sm_lib/Frames and Transforms/Rigid Transform',[xf_sys '/Rigid Transform'],...
            'Position',[240    75   280   115],'Name',[frame_name ' R' lower(order(2))],...
            'RotationMethod','StandardAxis',...
            'RotationStandardAxis',['+' order(2)],...
            'RotationAngle',EUAng2,...
            'RotationAngleUnits',char(frame_data(9)));
        add_line(xf_sys_h,[frame_name ' R' lower(order(1)) 'Txyz/RConn1'],[frame_name ' R' lower(order(2)) '/LConn1']);
        
        % ADD TRANSFORM FOR 3ND ROTATION AND CONNECT TO 2ND TRANSFORM
        add_block('sm_lib/Frames and Transforms/Rigid Transform',[xf_sys '/Rigid Transform'],...
            'Position',[345    75   385   115],'Name',[frame_name ' R' lower(order(3))],...
            'RotationMethod','StandardAxis',...
            'RotationStandardAxis',['+' order(3)],...
            'RotationAngle',EUAng3,...
            'RotationAngleUnits',char(frame_data(9)));  
        add_line(xf_sys_h,[frame_name ' R' lower(order(2)) '/RConn1'],[frame_name ' R' lower(order(3)) '/LConn1']);
        
        % ADD F PORT AND CONNECT TO 3RD TRANSFORM
        add_block('nesl_utility/Connection Port',[xf_sys '/Connection Port'],'Name','F',...
            'Position',[460    86   490   104],'Orientation','left','Side','Right');
        add_line(xf_sys_h,[frame_name ' R' lower(order(3)) '/RConn1'],'F/RConn1');
    end
elseif strfind(char(frame_data(8)),'3x3')
    convSM1G2GMsg('Orientation is 3x3 transform - not handled');
elseif strfind(char(frame_data(8)),'Quaternion')
    convSM1G2GMsg('Orientation is Quaternion - not handled');
end

