function [A_bar, B_bar, C_bar, D_bar] = generate_model(m1, m2, k1, k2, b)
% GENERATE_MODEL Constrói as matrizes de espaço de estados do sistema de suspensão.
% Entradas: Parâmetros físicos (massas, rigidez, amortecimento).
% Saídas: Matrizes A_bar, B_bar, C_bar, D_bar do sistema.

    n = 2; % Graus de liberdade

    M = [m1, 0;
        0, m2];

    D = [b, -b;
        -b, b];

    K = [k1+k2, -k2;
        -k2, k2];

    Bw = [k1; 0];

    Cd = eye(n);

    Cv = zeros(n);

    Dw = zeros(2,1);

    % Matriz A (Dinâmica)
    A_bar = [zeros(n), eye(n);
        -(M\K), -(M\D)];

    % Matriz B (Entrada da perturbação w)
    B_bar = [zeros(2,1);
        M\Bw];

    % Matriz C (Saídas: Posição y_1 e Posição y_2)
    C_bar = [Cd, Cv];

    % Matriz D (Transmissão direta)
    D_bar = Dw;
end