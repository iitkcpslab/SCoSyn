function [Rm_str] =  Rm_str(axis,Ang,units)

% CREATE ROTATION MATRIX AS A STRING
% FOR PRESERVING PARAMETERIZATION OF 1G COORDINATE SYSTEMS
% THAT USE EULER ANGLES (EULER ANGLES NOT AVAILABLE IN 2G)

% Copyright 2014-2019 The MathWorks Inc.

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



