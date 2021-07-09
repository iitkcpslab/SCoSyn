function cns_param = getSM1GConstraints(Src_mdl)
% getSM1GConstraints - Get key parameters for constraints in a Simscape Multibody 1G model

% Copyright 2014-2019 The MathWorks Inc.

cns_param=[];       % INITIALIZE STRUCTURE
load_system(Src_mdl);   % LOAD MODELS

% FIND BLOCKS
constraint_paths = find_system(Src_mdl,'FollowLinks','on','LookUnderMasks','all','regexp','on','ReferenceBlock','mblibv.*/Constraints &  Drivers/.*');

% CONSTRAINT PARAMETER NAMES (1G, cns_param STRUCTURE)
ConstraintParameters = { ...
    'Name','Name';...
    'Position','Position';...
    'Orientation','Orientation';...
    'Handle','Handle'};

for i=1:length(constraint_paths)
    % GET PARAMETER INFO FROM CONSTRAINT BLOCK
    for j=1:length(ConstraintParameters)
        cns_param(i).(char(ConstraintParameters{j,2})) = get_param(char(constraint_paths(i)),char(ConstraintParameters{j,1}));
    end
    cns_param(i).BlockPath = constraint_paths(i);
    cns_param(i).ConstraintType = strrep(regexprep(get_param(cns_param(i).Handle,'ReferenceBlock'),'\n',' '),'mblibv1/Constraints &  Drivers/','');
end
