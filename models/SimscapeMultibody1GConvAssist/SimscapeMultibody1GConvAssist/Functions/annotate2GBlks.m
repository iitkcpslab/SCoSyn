function annotate2GBlks(type, ann_str, horiz_al, ann_pos)
% annotate2GBlks - Add annotation to model with SM2G blocks
%   annotate2GBlks(type, ann_str, horiz_al, ann_pos)
%    type:   'fix_1G' - element should be fixed or removed from 1G model
%            'fix_2G' - element must be verified/adjusted in 2G blocks
%    ann_str:   Annotation string
%    horiz_al:  Horizontal alignment
%    ann_pos:   Position rectangle for annotation

% Copyright 2014-2019 The MathWorks Inc.

if(strcmpi(type,'fix_1G'))
    % ELEMENT SHOULD BE FIXED IN 1G MODEL
    ann_color='red';
elseif(strcmpi(type,'fix_2G'))
    % DATA MUST BE VERIFIED/ADJUSTED IN 2G MODEL
    ann_color='blue';
elseif(strcmpi(type,'info'))
    % INFORMATION ONLY
    ann_color = 'black';
end

if(verLessThan('matlab','8.2'))
    % Annotation position different in R2013a
    ann_pos = [ann_pos(1) ann_pos(2)];
end

add_block('built-in/Note',ann_str,...
    'ForeGroundColor',ann_color,...
    'HorizontalAlignment',horiz_al,...
    'FontSize','12',...
    'Position',ann_pos)
