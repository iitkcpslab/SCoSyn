function [RM] =  EUA_to_RotM_str(order,EA,units)
% EUA_to_RotM_str - Construct rotation matrix as a string

% Copyright 2014-2019 The MathWorks Inc.

R1 = Rm_str(order(1),char(EA{1}),units);
R2 = Rm_str(order(2),char(EA{2}),units);
R3 = Rm_str(order(3),char(EA{3}),units);
RM = [R1 '*' R2 '*' R3];

function [Rm_str] =  Rm_str(axis,Ang,units)

s='sin';
c='cos';

if(strcmp(units,'deg'))
    s='sind';
    c='cosd';
end

cA = [c '(' Ang ')'];
sA = [s '(' Ang ')'];

if(strcmp(axis,'X'))
    Rm_str = ['[1 0 0;'...
        '0 ' cA ' -' sA ';'...
        '0 ' sA '  ' cA ']'];
elseif(strcmp(axis,'Y'))
    Rm_str = ['[' cA ' 0 ' sA ';'...
        '0 1 0;'...
        '-' sA ' 0 ' cA ']'];
elseif(strcmp(axis,'Z'))
    Rm_str = ['[' cA ' -' sA ' 0;'...
        sA ' ' cA ' 0;'...
        '0 0 1]'];
    
end



