%% TCC - ANÁLISE DE FALHAS (MODULARIZADO)
% Autor: Thiago Tioma
% Descrição: Script principal para simulação e diagnóstico de falhas.

clc; clear; close all;

%% 1. Configuração e Modelo Nominal
m1 = 1; m2 = 1.45;
k1 = 1250; k2 = 900;
b  = 7.5;

% Obtendo matrizes nominais usando a função externa
[A, B, C, D] = generate_model(m1, m2, k1, k2, b);

% Empacotando em struct para passar fácil para a simulação
Nominal.A = A; Nominal.B = B; Nominal.C = C; Nominal.D = D;

[NominalModal, T] = convert_to_modal(Nominal);

%% 2. Geração do Sinal Chirp
Fs = 1e3; 
Tchirp = 20; 
[w_in, t] = generate_chirp(Fs, Tchirp, 0.04, 0, 12);

% Plotagem de verificação (opcional)
% figure; plot(t, w_in); title('Sinal de Entrada - Chirp'); grid on; axis tight;

%% 3.1 Projeto do Observador de Luenberger
fprintf('\n=== PROJETO LUENBERGER ===\n');
fator_rapidez = 3; 
[L_luenberger, polos_obs_luen] = design_luenberger(Nominal, fator_rapidez);

%% 3.2 Projeto do Filtro de Kalman
fprintf('\n=== PROJETO KALMAN ===\n');
% Parâmetros do texto (Seção 4.6.2 e 4.4)
q_val = 1e-7;       
target_SNR = 30;    

[L_kalman, Q_kalman, R_kalman] = design_kalman(Nominal, t, w_in, q_val, target_SNR);

%% 4. Simulação Comparativa: Cenário 1 (Dano no Amortecedor)
fprintf('\n--- Simulando Dano no Amortecedor ---\n');
[Ad, Bd, Cd, Dd] = generate_model(m1, m2, k1, k2, b * 0.5); 
Dano1.A = Ad; Dano1.B = Bd; Dano1.C = Cd; Dano1.D = Dd;

% Simulação com Luenberger
fprintf('Rodando Luenberger...\n');
[res_luen_d1, ~] = run_observer_sim_noisy(Nominal, Dano1, L_luenberger, t, w_in, Tchirp);

% Simulação com Kalman
fprintf('Rodando Kalman...\n');
[res_kalman_d1, ~] = run_observer_sim_noisy(Nominal, Dano1, L_kalman, t, w_in, Tchirp);

%% 5. Simulação Comparativa: Cenário 2 (Dano na Mola)
fprintf('\n--- Simulando Dano na Mola ---\n');
[Ad2, Bd2, Cd2, Dd2] = generate_model(m1, m2, k1, k2 * 0.5, b); 
Dano2.A = Ad2; Dano2.B = Bd2; Dano2.C = Cd2; Dano2.D = Dd2;

% Simulação com Luenberger
[res_luen_d2, ~] = run_observer_sim_noisy(Nominal, Dano2, L_luenberger, t, w_in, Tchirp);

% Simulação com Kalman
[res_kalman_d2, ~] = run_observer_sim_noisy(Nominal, Dano2, L_kalman, t, w_in, Tchirp);

%% 6. Simulação Comparativa: Cenário 3 (Dano no Amortecedor e na Mola)
fprintf('\n--- Simulando Dano no Amortecedor e na Mola ---\n');
[Ad3, Bd3, Cd3, Dd3] = generate_model(m1, m2, k1, k2 * 0.5, b * 0.5);
Dano3.A = Ad3; Dano3.B = Bd3; Dano3.C = Cd3; Dano3.D = Dd3;

% Simulação com Luenberger
[res_luen_d3, ~] = run_observer_sim_noisy(Nominal, Dano3, L_luenberger, t, w_in, Tchirp);

% Simulação com Kalman
[res_kalman_d3, ~] = run_observer_sim_noisy(Nominal, Dano3, L_kalman, t, w_in, Tchirp);

%% 7. Análise Modal e Comparação
% Aqui você pode plotar os dois para comparar a imunidade ao ruído

% Comparação Dano 1 (Amortecedor)
plot_modal_signature(res_luen_d1, res_kalman_d1, t, Tchirp, Fs, ...
    'Dano no Amortecedor (b = 50%)');

% Comparação Dano 2 (Mola)
plot_modal_signature(res_luen_d2, res_kalman_d2, t, Tchirp, Fs, ...
    'Dano na Rigidez (k_2 = 50%)');

% Comparação Dano 3 (Misto)
plot_modal_signature(res_luen_d3, res_kalman_d3, t, Tchirp, Fs, ...
    'Dano Misto (b=50%, k_2=50%)');