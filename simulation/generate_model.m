function [A, B, C, D] = generate_model(m1, m2, k1, k2, b)
% GENERATE_MODEL Constrói as matrizes de espaço de estados do sistema de suspensão.
% Entradas: Parâmetros físicos (massas, rigidezes, amortecimento).
% Saídas: Matrizes A, B, C, D do sistema.

    n = 2; % Graus de liberdade

    % Matriz A (Dinâmica)
    A = [zeros(n), eye(n); ...
        [-(k1 + k2)/m1, k2/m1; k2/m2, -k2/m2], ...
        [-b/m1, b/m1; b/m2, -b/m2]];

    % Matriz B (Entrada da perturbação w)
    B = [0; 0; k1/m1; 0];

    % Matriz C (Saídas: Posição y_1 e Posição y_2)
    C = [1, 0, 0, 0; ...
         0, 1, 0, 0];

    % Matriz D (Transmissão direta)
    D = [0; 0];
end