% Copyright 2014-2018 The MathWorks, Inc.

A_a = 0.05;
A_b = 0.5;
A_c = 0.05;
M_a = 1;
I_a = [1/3*M_a*(A_b^2 + A_c^2) 0 0;   0 1/3*M_a*(A_a^2 + A_c^2) 0;   0 0 1/3*M_a*(A_a^2 + A_b^2)];

C_a = 0.25;
C_b = 0.05;
C_c = 0.05;
M_c = 5;
I_c = [1/3*M_c*(C_b^2 + C_c^2) 0 0;   0 1/3*M_c*(C_a^2 + C_c^2) 0;   0 0 1/3*M_c*(C_a^2 + C_b^2)];

