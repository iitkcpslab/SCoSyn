function convSM1G2GMsg(msg,varargin)
% convSM1G2GMsg - Write messages to Command Window, file, or both

% Copyright 2014-2019 The MathWorks Inc.

persistent fileID
persistent where

if (nargin==3)
    Src_mdl = varargin{1};
    where = varargin{2};
end

if (strcmpi(where,'both') || strcmpi(where,'file'))
    if isempty(fileID)
        fileID = fopen([Src_mdl '_conv1G2G.txt'],'w');
        fprintf(fileID,'%s\n\n',['Conversion Report for Simscape Multibody 1G -> 2G for ' Src_mdl]);
    end
    if(~isempty(msg))
        fprintf(fileID,'%s\n',msg);
    end
end
if (strcmpi(where,'both') || strcmpi(where,'cmdwindow'))
    disp(msg)
end

if strcmp(msg,'END OF REPORT')
    if (strcmpi(where,'both') || strcmpi(where,'file'))
        fclose(fileID);
        clear fileID
    end
    clear where
end

