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

%% 2. Geração do Sinal Chirp
Fs = 1e3; 
Tchirp = 20; 
[w_in, t] = generate_chirp(Fs, Tchirp, 0.04, 0, 12);

% Plotagem de verificação (opcional)
figure; plot(t, w_in); title('Sinal de Entrada - Chirp'); grid on; axis tight;

%% 3. Projeto do Observador (Luenberger)
polos_sys = eig(A);
fator_rapidez = 3;
polos_obs = real(polos_sys)*fator_rapidez + 1i*imag(polos_sys) - 0.5;

% Ackermann para calcular L
L = place(A', C', polos_obs)';
fprintf('Ganho L calculado. Polos em: %.2f +/- %.2fi\n', ...
    mean(real(polos_obs)), mean(abs(imag(polos_obs))));

%% 4. Simulação: Cenário 1 (Dano Amortecedor)
fprintf('Simulando Dano no Amortecedor...\n');
[Ad, Bd, Cd, Dd] = generate_model(m1, m2, k1, k2, b * 0.5); % b reduzido
Dano1.A = Ad; Dano1.B = Bd; Dano1.C = Cd; Dano1.D = Dd;

res_dano1 = run_observer_sim(Nominal, Dano1, L, t, w_in, Tchirp);

%% 5. Simulação: Cenário 2 (Dano Mola)
fprintf('Simulando Dano na Mola...\n');
[Ad2, Bd2, Cd2, Dd2] = generate_model(m1, m2, k1, k2 * 0.5, b); % k2 reduzido
Dano2.A = Ad2; Dano2.B = Bd2; Dano2.C = Cd2; Dano2.D = Dd2;

res_dano2 = run_observer_sim(Nominal, Dano2, L, t, w_in, Tchirp);

%% 6. Análise Modal dos Resultados
% Identifica frequências naturais para os filtros
freqs_rad = sort(abs(imag(eig(A))));
freqs_hz = freqs_rad(freqs_rad > 0.1) / (2*pi); % Remove os 0s e converte
freqs_principais = [freqs_hz(1), freqs_hz(3)]; % Pega os 2 modos positivos

% Chama a função de plotagem externa
plot_modal_signature(res_dano1, t, Tchirp, freqs_principais, Fs, ...
    'Assinatura: Dano no Amortecedor');

plot_modal_signature(res_dano2, t, Tchirp, freqs_principais, Fs, ...
    'Assinatura: Dano na Mola');