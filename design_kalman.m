function [L_kalman, Q, R] = design_kalman(SysNom, t, w_in, q_val, target_SNR_dB)
% DESIGN_KALMAN Projeta o ganho do Filtro de Kalman estacionário.
%
% Metodologia (Seção 4.6.2 do TCC):
%   1. Estima a potência do sinal de saída (simulação seca).
%   2. Calcula R para atingir a SNR alvo (30dB).
%   3. Define Q com base no parâmetro q (1e-7).
%   4. Resolve a equação de Riccati (lqe) para achar o ganho.
%
% Entradas:
%   SysNom: Estrutura do sistema nominal (.A, .B, .C, .D)
%   t, w_in: Vetores de tempo e entrada (para calcular potência do sinal)
%   q_val: Intensidade do ruído de processo (ex: 1e-7)
%   target_SNR_dB: Relação Sinal-Ruído desejada (ex: 30)

    fprintf('--- Projetando Filtro de Kalman ---\n');

    dt = t(2) - t(1);
    n_states = size(SysNom.A, 1);
    n_out = size(SysNom.C, 1);
    N = length(t);

    % --- 1. Definição de Q (Ruído de Processo) ---
    % Conforme texto: "Q foi definida como uma matriz diagonal... q*I"
    Q = q_val * eye(n_states);
    
    % G: Matriz de entrada do ruído de processo. 
    % Assumimos que o ruído afeta todos os estados diretamente (G=I).
    G = eye(n_states); 

    % --- 2. Cálculo de R (Ruído de Medição via SNR) ---
    % Precisamos simular o sistema nominal para saber a potência do sinal
    x = zeros(n_states, N);
    y_clean = zeros(n_out, N);
    
    for k = 1:N-1
        dx = SysNom.A * x(:,k) + SysNom.B * w_in(k);
        x(:,k+1) = x(:,k) + dt*dx;
        y_clean(:,k) = SysNom.C * x(:,k) + SysNom.D * w_in(k);
    end
    
    % Cálculo da variância necessária para R
    R_diag = zeros(n_out, 1);
    for i = 1:n_out
        sinal_rms = rms(y_clean(i, :));
        potencia_sinal = sinal_rms^2;
        % P_ruido = P_sinal / 10^(SNR/10)
        potencia_ruido = potencia_sinal / (10^(target_SNR_dB/10));
        R_diag(i) = potencia_ruido;
    end
    R = diag(R_diag);

    fprintf('Matriz R calculada para SNR %d dB.\n', target_SNR_dB);
    disp(diag(R)');

    % --- 3. Cálculo do Ganho Ótimo (LQE) ---
    % lqe resolve a equação algébrica de Riccati
    % [L, P, E] = lqe(A, G, C, Q, R)
    [L_kalman, ~, poles_kalman] = lqe(SysNom.A, G, SysNom.C, Q, R);
    
    % O comando lqe retorna L tal que o observador é: dot(x) = Ax + Bu + L(y - Cx)
    % Exatamente como precisamos para a função de simulação.
    
    fprintf('Ganho de Kalman calculado.\n');
    fprintf('Polos do filtro de Kalman (Malha Fechada):\n');
    disp(poles_kalman);
end