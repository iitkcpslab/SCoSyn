%init_model;

    g = -9.81;     % Gravidade
    Ix = 7.5e-3;      % In�rcia eixo X
    Iy = 7.5e-3;      % In�rcia eixo Y
    Iz = 1.3e-2;     % In�rcia eixo Z
    L = 0.2;       % Dist�ncia do centro at� qualquer um dos motores
    Km = 7.5e-7;      % Cte aerodin�mica (thrust)
    Kf = 3.13e-5;      % Cte de arrasto (drag)
    m = 0.5;        % Massa do drone
    Jr = 6e-5;      % In�rcia do rotor
    % Redu��o de vari�veis
    a1 = (Iy - Iz)/Ix;
    a2 = Jr/Ix;
    a3 = (Iz - Ix)/Iy;
    a4 = Jr/Iy;
    a5 = (Ix - Iy)/Iz;
    b1 = L/Ix;
    b2 = L/Iy;
    b3 = L/Iz;
    