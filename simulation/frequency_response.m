%% Resposta em Frequência com Decomposição Modal (2 Saídas)
% Autor: Thiago Tioma
% Descrição: Decompõe a resposta do sistema nos seus modos de vibração
% (Modo 1 e Modo 2) e plota para ambas as saídas (y_1 e y_2).

clear; clc; close all;

%% 1. Parâmetros Nominais
m1 = 1;         % Massa não suspensa [kg]
m2 = 2.45;      % Massa suspensa [kg]
k1 = 1250;      % Rigidez do pneu [N/m]
k2 = 900;       % Rigidez da suspensão [N/m]
b  = 7.5;       % Amortecimento [Ns/m]

% Vetor de frequências para o gráfico (0.1 a 100 Hz para visualização ampla)
w_freq = logspace(-1, 2, 1000) * 2 * pi; 
f_hz = w_freq / (2*pi);

%% 2. Construção do Modelo Original
[A, B, C, D] = generate_model_thesis(m1, m2, k1, k2, b);

sys_full = ss(A, B, C, D);

%% 3. Decomposição Modal
% Transforma o sistema para a forma canônica modal.
% A matriz A_modal será diagonal em blocos 2x2 (para pares complexos).
[sys_modal, T] = modalreal(sys_full);

A_m = sys_modal.A;
B_m = sys_modal.B;
C_m = sys_modal.C;

damp(sys_modal)

% Identificação dos Modos
% O sistema tem 4 estados. Na forma modal, eles estão em pares (1-2 e 3-4).
% Vamos calcular a frequência natural de cada par para saber quem é quem.

% Par 1 (Estados 1 e 2)
eigen_1 = eig(A_m(1:2, 1:2));
wn_1 = abs(eigen_1(1)) / (2*pi); % Freq em Hz

% Par 2 (Estados 3 e 4)
eigen_2 = eig(A_m(3:4, 3:4));
wn_2 = abs(eigen_2(1)) / (2*pi); % Freq em Hz

% Lógica de ordenação: Modo 1 é o de menor frequência (corpo), Modo 2 é maior (roda)
if wn_1 < wn_2
    % A ordem já está correta (Baixa Freq nos estados 1-2)
    idx_m1 = 1:2;
    idx_m2 = 3:4;
else
    % A ordem está invertida
    idx_m1 = 3:4;
    idx_m2 = 1:2;
end

%% 4. Criação dos Subsistemas Modais
% Cria um sistema que contém APENAS a dinâmica do Modo 1
% Zeramos a contribuição dos estados do Modo 2
sys_mode1 = ss(A_m(idx_m1, idx_m1), B_m(idx_m1,:), C_m(:, idx_m1), 0);

% Cria um sistema que contém APENAS a dinâmica do Modo 2
sys_mode2 = ss(A_m(idx_m2, idx_m2), B_m(idx_m2,:), C_m(:, idx_m2), 0);

%% 5. Cálculo da Resposta em Frequência
% Calcula magnitude para o sistema completo e para os modos isolados
[mag_full, ~] = bode(sys_full, w_freq);
[mag_m1, ~]   = bode(sys_mode1, w_freq);
[mag_m2, ~]   = bode(sys_mode2, w_freq);

% Conversão para dB e remoção de dimensões extras (squeeze)
% Saída 1 (Massa Não Suspensa - Pneu)
y1_full_db = 20*log10(squeeze(mag_full(1,1,:)));
y1_m1_db   = 20*log10(squeeze(mag_m1(1,1,:)));
y1_m2_db   = 20*log10(squeeze(mag_m2(1,1,:)));

% Saída 2 (Massa Suspensa - Chassi)
y2_full_db = 20*log10(squeeze(mag_full(2,1,:)));
y2_m1_db   = 20*log10(squeeze(mag_m1(2,1,:)));
y2_m2_db   = 20*log10(squeeze(mag_m2(2,1,:)));

%% 6. Plotagem (Estilo Visual da sua Imagem)
figure('Color', 'w', 'Position', [100, 100, 900, 700]);

% --- Subplot 1: Massa Não Suspensa (x1) ---
subplot(2,1,1); hold on; grid minor;
p1 = semilogx(f_hz, y1_full_db, 'k-', 'LineWidth', 1); % Sistema Completo
p2 = semilogx(f_hz, y1_m1_db,   'b:', 'LineWidth', 1); % Modo 1
p3 = semilogx(f_hz, y1_m2_db,   'r:', 'LineWidth', 1); % Modo 2

title('Saída y_1 — Massa Não Suspensa (m_1)', 'FontSize', 11);
ylabel('Magnitude (dB)', 'FontSize', 10);
legend([p1, p2, p3], {'Sistema', 'Modo 1', 'Modo 2'}, 'Location', 'best');
xlim([0.1 100]); ylim([-120 40]);
xscale log

% --- Subplot 2: Massa Suspensa (x2) ---
subplot(2,1,2); hold on; grid minor;
semilogx(f_hz, y2_full_db, 'k-', 'LineWidth', 1);
semilogx(f_hz, y2_m1_db,   'b:', 'LineWidth', 1);
semilogx(f_hz, y2_m2_db,   'r:', 'LineWidth', 1);

title('Saída y_2 — Massa Suspensa (m_2)', 'FontSize', 11);
xlabel('Frequência (Hz)', 'FontSize', 10); ylabel('Magnitude (dB)', 'FontSize', 10);
xlim([0.1 100]); ylim([-120 40]);
xscale log

