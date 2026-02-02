%% ANÁLISE DE DANOS (COMPLETO - 2 SAÍDAS)
% Descrição: Simulação de 3 cenários de dano com análise MIMO (y_1 e y_2).

clc; clear; close all;

%% 1. Configuração e Modelo Nominal
m1 = 1;         % Massa não suspensa [kg]
m2 = 2.45;      % Massa suspensa [kg]
k1 = 1250;      % Rigidez do pneu [N/m]
k2_nom = 900;   % Rigidez da suspensão [N/m]
b_nom  = 7.5;   % Amortecimento [Ns/m]

% Gera o modelo original
[A, B, C, D] = generate_model_thesis(m1, m2, k1, k2_nom, b_nom);

Nominal.A = A; Nominal.B = B; Nominal.C = C; Nominal.D = D;

% Checagem de observabilidade
fprintf('\n=== VERIFICAÇÃO DE OBSERVABILIDADE ===\n');
verify_observability_condition(A, C)

%% 2. Geração do Sinal Chirp
Fs = 1e3; 
Tchirp = 20; 
[w_in, t] = generate_chirp(Fs, Tchirp, 0.04, 0, 12);

%% 3. Projeto dos Observadores (MIMO)

% --- Luenberger ---
fprintf('\n=== PROJETO LUENBERGER (MIMO) ===\n');
fator_rapidez = 3;
polos_planta = eig(A);
% Garante que os polos sejam complexos conjugados estáveis
polos_desejados = real(polos_planta) * fator_rapidez + 1i * imag(polos_planta);
L_luenberger = place(A', C', polos_desejados)'; 

% --- Kalman ---
fprintf('\n=== PROJETO KALMAN (MIMO) ===\n');
q_proj = 1e-4; 
Q_kalman = q_proj * eye(4);
% R deve ser 2x2 (uma estimativa de ruído para cada sensor)
R_kalman = 1e-4 * eye(2); 
L_kalman = lqe(A, eye(4), C, Q_kalman, R_kalman);

%% ---------------------------------------------------------
%% CENÁRIO 1: Dano no Amortecedor (b = 50%)
%% ---------------------------------------------------------
fprintf('\n--- Simulando Cenário 1: Amortecedor ---\n');

% Gera modelo com falha (b reduzido)
[Ad1, Bd1, ~, ~] = generate_model(m1, m2, k1, k2_nom, b_nom * 0.5);

% Empacota (Mantendo C e D de 2 saídas)
Dano1.A = Ad1; Dano1.B = Bd1; Dano1.C = C; Dano1.D = D;

% Simulações
[res_luen_d1, ~] = run_observer_sim_noisy(Nominal, Dano1, L_luenberger, t, w_in, Tchirp);
[res_kalman_d1, ~] = run_observer_sim_noisy(Nominal, Dano1, L_kalman, t, w_in, Tchirp);

% Plotagem
plot_modal_signature(res_luen_d1, res_kalman_d1, t, Tchirp, Fs, ...
    'Cenário 1: Dano no Amortecedor (b=50%)');

%% ---------------------------------------------------------
%% CENÁRIO 2: Dano na Rigidez (k_2 = 50%)
%% ---------------------------------------------------------
fprintf('\n--- Simulando Cenário 2: Rigidez ---\n');

% Gera modelo com falha (k2 reduzido)
[Ad2, Bd2, ~, ~] = generate_model(m1, m2, k1, k2_nom * 0.5, b_nom);

% Empacota
Dano2.A = Ad2; Dano2.B = Bd2; Dano2.C = C; Dano2.D = D;

% Simulações
[res_luen_d2, ~] = run_observer_sim_noisy(Nominal, Dano2, L_luenberger, t, w_in, Tchirp);
[res_kalman_d2, ~] = run_observer_sim_noisy(Nominal, Dano2, L_kalman, t, w_in, Tchirp);

% Plotagem
plot_modal_signature(res_luen_d2, res_kalman_d2, t, Tchirp, Fs, ...
    'Cenário 2: Dano na Rigidez (k_2=50%)');

%% ---------------------------------------------------------
%% CENÁRIO 3: Dano Misto (b=50%, k_2=50%)
%% ---------------------------------------------------------
fprintf('\n--- Simulando Cenário 3: Misto ---\n');

% Gera modelo com falha dupla
[Ad3, Bd3, ~, ~] = generate_model(m1, m2, k1, k2_nom * 0.5, b_nom * 0.5);

% Empacota
Dano3.A = Ad3; Dano3.B = Bd3; Dano3.C = C; Dano3.D = D;

% Simulações
[res_luen_d3, ~] = run_observer_sim_noisy(Nominal, Dano3, L_luenberger, t, w_in, Tchirp);
[res_kalman_d3, ~] = run_observer_sim_noisy(Nominal, Dano3, L_kalman, t, w_in, Tchirp);

% Plotagem
plot_modal_signature(res_luen_d3, res_kalman_d3, t, Tchirp, Fs, ...
    'Cenário 3: Dano Misto (b=50%, k_2=50%)');