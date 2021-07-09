function [blk_param_out] = scan1Gmodel(Src_mdl)
%scan1Gmodel - Scan Simscape Multibody 1G model for elements that cannot
%              be converted to Simscape Multibody 2G

% Copyright 2014-2019 The MathWorks Inc.

blk_param = [];
load_system(Src_mdl);   % LOAD MODELS

% 1G ONLY BLOCKS/FEATURES  Block, Block Type, Mapping
Elem_1Gonly = {
    'Angle Driver',             'Constraint','indirect';...
    'Distance Driver',          'Constraint','indirect';...
    'Linear Driver'  ,          'Constraint','indirect';...
    'Point-Curve Constraint',   'Constraint','R2015b';...
    'Velocity Driver',          'Constraint','indirect';...
    'Screw',                    'Joint',    'R2015a';...
    'Variable Mass & Inertia Actuator','Actuator','R2017a';...
    'Joint Stiction Actuator',  'Actuator', 'indirect';...
    'Joint Sensor',             'Sensor',   'partial';...
    'Joint Actuator',           'Actuator', 'partial';...
    'Constraint & Driver  Sensor','Sensor', 'partial';...
    'Machine Environment',      'Body',     'partial';...
    };

KeyParam = { ...
    'Name','Name';...
    'Handle','Handle'};

% FIND ELEMENTS THAT MAY HAVE NO DIRECT 2G EQUIVALENT
constraint_paths = find_system(Src_mdl,'FollowLinks','on','LookUnderMasks','all','regexp','on','ReferenceBlock','mblibv.*/Constraints &  Drivers/.*');
joint_paths = find_system(Src_mdl,'FollowLinks','on','LookUnderMasks','all','regexp','on','ReferenceBlock','mblibv.*/Joints/.*');
actsn_paths_t = find_system(Src_mdl,'FollowLinks','on','LookUnderMasks','all','regexp','on','ReferenceBlock','mblibv.*/Sensors &  Actuators/');
bodies_paths_t = find_system(Src_mdl,'FollowLinks','on','LookUnderMasks','all','regexp','on','ReferenceBlock','mblibv.*/Bodies/');

% EXCLUDE PORTS FROM LIST OF ACTUATORS AND SENSORS
actsn_paths = [];
for i=1:length(actsn_paths_t)
    if (~strcmpi(get_param(actsn_paths_t{i},'BlockType'),'PMIOPort') && ...
            ~strcmpi(get_param(actsn_paths_t{i},'BlockType'),'Inport') && ...
            ~strcmpi(get_param(actsn_paths_t{i},'BlockType'),'Outport') && ...
            ~strcmpi(get_param(actsn_paths_t{i},'BlockType'),'Terminator') && ...
            ~strcmpi(get_param(actsn_paths_t{i},'BlockType'),'Constant'))
        actsn_paths{end+1,1}=actsn_paths_t{i};
    end
end

% EXCLUDE PORTS FROM LIST OF BODIES
bodies_paths = [];
for i=1:length(bodies_paths_t)
    if (~strcmpi(get_param(bodies_paths_t{i},'BlockType'),'PMIOPort'))
        bodies_paths{end+1,1}=bodies_paths_t{i};
    end
end

% ASSEMBLE FULL LIST OF PATHS
blk_paths = [constraint_paths;joint_paths;actsn_paths;bodies_paths];

% LOOP OVER ALL BLOCKS
for blk_i = 1:length(blk_paths)
    % GET COMMON KEY PARAMETERS
    for p_i=1:length(KeyParam)
        blk_param(blk_i).(char(KeyParam{p_i,2})) = get_param(char(blk_paths(blk_i)),char(KeyParam{p_i,1}));
    end
    blk_param(blk_i).BlockPath=blk_paths(blk_i);
    blk_param(blk_i).WarnStr=[];
    
    % EXTRACT REFERENCE BLOCK NAME
    refblk_str = regexprep(get_param(blk_param(blk_i).Handle,'ReferenceBlock'),'\n',' ');
    refblk_str = strrep(refblk_str,'mblibv1/Constraints &  Drivers/','');
    refblk_str = strrep(refblk_str,'mblibv1/Joints/','');
    refblk_str = strrep(refblk_str,'mblibv1/Sensors &  Actuators/','');
    refblk_str = strrep(refblk_str,'mblibv1/Bodies/','');
    blk_param(blk_i).Type = refblk_str;
    %disp(char(blk_param(blk_i).Type)); % For Debugging
    
    % EXTRACT BLOCK TYPE AND MAPPING AND FROM Elem_1Gonly DATA STRUCTURE
    mapping   =char(Elem_1Gonly(strcmp(Elem_1Gonly(:,1),char(blk_param(blk_i).Type)),3));
    block_type=char(Elem_1Gonly(strcmp(Elem_1Gonly(:,1),char(blk_param(blk_i).Type)),2));
    
    % CONSTRUCT WARNING MESSAGE
    if(strcmp(mapping,'indirect'))
        warn_str = ['Block "' regexprep(char(blk_param(blk_i).Name),'\n',' ') '": No automatic conversion for 1G block ' blk_param(blk_i).Type];
    elseif(strcmp(mapping,'none'))
        warn_str = ['Block "' regexprep(char(blk_param(blk_i).Name),'\n',' ') '": No 2G equivalent for 1G block ' blk_param(blk_i).Type];
    elseif(strncmp(mapping,'R',1))
        if(verLessThan('matlab',release2ver(mapping)))
            warn_str = ['Block "' regexprep(char(blk_param(blk_i).Name),'\n',' ') '": 2G equivalent added in release ' mapping];
        else
            warn_str=[];
        end
    else
        warn_str=[];
    end
    
    ver_str = version('-release');
    ver_num = str2num(ver_str(3:4));
    ver_let = ver_str(5);
    % ver_num=13;ver_let='a'; % TESTING FOR OLD RELEASES
    cp_warn_str = [];
    
    % SWITCH FOR BLOCKS WHERE SETTINGS NEED TO BE EXAMINED
    switch refblk_str
        case 'Joint Sensor'
            % REACTION AND COMPUTED FORCES NOT AVAILABLE IN ALL RELEASES
            rxf = strcmpi(get_param(blk_param(blk_i).Handle,'ReactionForce'),'on');
            rxt = strcmpi(get_param(blk_param(blk_i).Handle,'ReactionMoment'),'on');
            cpf = strcmpi(get_param(blk_param(blk_i).Handle,'Force'),'on');
            cpt = strcmpi(get_param(blk_param(blk_i).Handle,'Torque'),'on');
            if((cpf||cpt) && (ver_num < 13 || (ver_num == 13 && strcmpi(ver_let,'a'))))
                cp_warn_str = ['Block "' regexprep(char(blk_param(blk_i).Name),'\n',' ') '": Computed Force/Torque added in release R2013b'];
            end
            if((rxf||rxt) && (ver_num < 14))
                rx_warn_str = ['Block "' regexprep(char(blk_param(blk_i).Name),'\n',' ') '": Reaction Force/Torque added in release R2014a'];
                if(~isempty(cp_warn_str))
                    warn_str = sprintf('%s\n%s',cp_warn_str,rx_warn_str);
                else
                    warn_str = rx_warn_str;
                end
            end
        case 'Constraint & Driver  Sensor'
            % REACTION FORCES NOT AVAILABLE IN ALL RELEASES
            rxf = strcmpi(get_param(blk_param(blk_i).Handle,'ReactionForce'),'on');
            rxt = strcmpi(get_param(blk_param(blk_i).Handle,'ReactionMoment'),'on');
            if((rxf||rxt) && (ver_num < 14 || (ver_num == 14 && strcmpi(ver_let,'a'))))
                warn_str = ['Block "' regexprep(char(blk_param(blk_i).Name),'\n',' ') '": Reaction Force/Torque addded in release R2014b'];
            end
        case 'Joint Actuator'
            % MOTION ACTUATION NOT AVAILABLE IN ALL RELEASES
            actuation_type = get_param(blk_param(blk_i).Handle,'ActuationStyle');
            if(strcmpi(actuation_type,'Motion') && (ver_num < 13 || (ver_num == 13 && strcmpi(ver_let,'a'))))
                warn_str = ['Block "' regexprep(char(blk_param(blk_i).Name),'\n',' ') '": Motion actuation added in release R2013b'];
            end
        case 'Machine Environment'
            % GRAVITY AS A SIGNAL NOT AVAILABLE IN ALL RELEASES
            if(verLessThan('matlab',release2ver('R2014a')))
                gravity_as_signal = get_param(blk_param(blk_i).Handle,'GravityAsSignal');
                if(strcmpi(gravity_as_signal,'on'))
                    warn_str = ['Block "' regexprep(char(blk_param(blk_i).Name),'\n',' ') '": Gravity input as signal added in release R2014a'];
                end
            end
        otherwise
    end
    convSM1G2GMsg(warn_str);
    % ADD WARNING STRING AS SUBFIELD SO IT CAN BE ADDED
    % AS ANNOTATION TO CONVERTED BLOCKS
    blk_param(blk_i).WarnStr = warn_str;
end

% ONLY RETURN INFORMATION ON BLOCKS THAT GENERATED WARNINGS
blk_param_out=[];
if(~isempty(blk_param))
    inds = ~cellfun(@isempty,{blk_param.WarnStr});
    blk_param_out = blk_param(inds);
    if isempty(find(inds, 1))
        convSM1G2GMsg('No elements unique to 1G were found');
    end
end

