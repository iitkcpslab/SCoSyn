function [ground_param] = getSM1GGrounds(Src_mdl)
% getSM1GGrounds - Get key parameters for grounds in a Simscape Multibody 1G model

% Copyright 2014-2019 The MathWorks Inc.

ground_param=[];        % INITIALIZE STRUCTURE
load_system(Src_mdl);   % LOAD MODELS

% FIND BLOCKS
gnd_paths = find_system(Src_mdl,'FollowLinks','on','LookUnderMasks','all','regexp','on','ReferenceBlock','mblibv.*/Bodies/Ground','BlockType','SubSystem');

% GROUND PARAMETER NAMES (1G, ground_param STRUCTURE)
GroundParameters={...
    'Name','Name';...
    'Handle','Handle';...
    'Position','Position';...
    'Orientation','Orientation';...
    'CoordPosition','XYZOffset';...
    'CoordPositionUnits','XYZOffsetUnits';...
    'ShowEnvPort','ShowEnvPort'};

% LOOP OVER GROUND BLOCKS
for i=1:length(gnd_paths)
    % GET PARAMETER INFO FROM GROUND BLOCK
    for j=1:length(GroundParameters)
        ground_param(i).(char(GroundParameters{j,2})) = get_param(char(gnd_paths(i)),char(GroundParameters{j,1}));
    end
    ground_param(i).BlockPath = gnd_paths(i);
    ground_param(i).GravityVector = [];
    ground_param(i).GravityUnits = [];
    ground_param(i).GravityAsSignal = [];
    
    if(strcmp(ground_param(i).ShowEnvPort,'on'))
        pc_data = get_param(ground_param(i).Handle,'PortConnectivity');
        for pind=1:length(pc_data)
            cblk_ref = get_param(pc_data(pind).DstBlock,'ReferenceBlock');
            cblk_hdl = get_param(pc_data(pind).DstBlock,'Handle');
            if(strfind(regexprep(char(cblk_ref),'\n',' '),'Machine Environment'))
                ground_param(i).GravityVector = get_param(cblk_hdl,'Gravity');
                ground_param(i).GravityUnits = get_param(cblk_hdl,'GravityUnits');
                ground_param(i).GravityAsSignal = get_param(cblk_hdl,'GravityAsSignal');
            end
        end
        
    end
end
