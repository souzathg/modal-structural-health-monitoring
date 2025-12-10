%% Análise de Sensibilidade Paramétrica (Diagrama de Bode)
% Descrição: Este script gera diagramas de Bode (apenas Magnitude) variando
% os parâmetros de amortecimento (b) e rigidez da suspensão (k2) de
% 0% a 100% do valor nominal.
% A saída analisada é a Posição da Massa Suspensa (y).

clear; clc; close all;

%% 1. Parâmetros Nominais do Sistema
m1 = 1;         % Massa não suspensa [kg]
m2 = 1.45;      % Massa suspensa [kg]
k1 = 1250;      % Rigidez do pneu [N/m] (Fixo)
k2_nom = 900;   % Rigidez NOMINAL da suspensão [N/m]
b_nom  = 7.5;   % Amortecimento NOMINAL [Ns/m]

% Vetor de variações (0% a 100% em passos de 10%)
% Nota: Evitamos 0 exato para k2 para não gerar matriz singular, usamos um valor muito pequeno.
porcentagens = [1e-6, 0.1:0.1:1.0]; 
num_vars = length(porcentagens);

% Definição da Saída para o Bode (Posição da Massa Suspensa y)
C_out = [0, 1, 0, 0];
D_out = 0;

% Vetor de frequências para o plot (0.1 Hz a 20 Hz)
w_freq = logspace(log10(0.1*2*pi), log10(20*2*pi), 500);
f_hz = w_freq / (2*pi);

% Mapa de cores para o gradiente ( Azul -> Vermelho )
colors = jet(num_vars);


%% --- FIGURA 1: Variação do Amortecimento (b) ---
figure('Name', 'Sensibilidade - Amortecimento (b)', 'Color', 'w');
hold on;

title('Resposta à variação do Amortecimento (b)', 'FontSize', 12, 'FontWeight','bold');
subtitle('(b) variando — (k_2) fixo', 'FontSize', 10)
ylabel('Magnitude (dB)', 'FontSize', 11);
xlabel('Frequência (Hz)', 'FontSize', 11);
grid minor; box on;

for i = 1:num_vars
    pct = porcentagens(i);
    
    % Parâmetros atuais
    b_atual = b_nom * pct;
    k2_atual = k2_nom; % k2 fixo no nominal
    
    % Monta o sistema
    sys_curr = get_sys_ss(m1, m2, k1, k2_atual, b_atual, C_out, D_out);
    
    % Calcula a resposta em frequência (Magnitude apenas)
    % squeeze remove dimensões unitárias de matrizes 3D
    [mag, ~] = bode(sys_curr, w_freq);
    mag_db = 20*log10(squeeze(mag));
    
    % Plotagem com cor do gradiente
    semilogx(f_hz, mag_db, 'Color', colors(i,:), 'LineWidth', 0.7);
end
% Ajusta eixos
xlim([0.1 12]); ylim([-50 60]);
colormap(gca, jet); c = colorbar; c.Label.String = 'Porcentagem do valor nominal';


%% --- FIGURA 2: Variação da Rigidez (k2) ---
figure('Name', 'Sensibilidade - Rigidez (k2)', 'Color', 'w');
hold on;

title('Resposta à variação da Rigidez da Suspensão (k_2)', 'FontSize', 12);
subtitle('(b) fixo — (k_2) variando', 'FontSize', 10)
ylabel('Magnitude (dB)', 'FontSize', 11);
xlabel('Frequência (Hz)', 'FontSize', 11);

grid minor; box on;

for i = 1:num_vars
    pct = porcentagens(i);
    
    % Parâmetros atuais
    b_atual = b_nom;     % b fixo no nominal
    k2_atual = k2_nom * pct;
    
    % Monta o sistema
    sys_curr = get_sys_ss(m1, m2, k1, k2_atual, b_atual, C_out, D_out);
    
    % Calcula a resposta em frequência
    [mag, ~] = bode(sys_curr, w_freq);
    mag_db = 20*log10(squeeze(mag));
    
    % Plotagem
    semilogx(f_hz, mag_db, 'Color', colors(i,:), 'LineWidth', 0.7);
end
xlim([0.1 12]); ylim([-50 30]);
colormap(gca, jet); c = colorbar; c.Label.String = 'Porcentagem do valor nominal';


%% Função Auxiliar para Montar o Sistema
function sys = get_sys_ss(m1, m2, k1, k2_val, b_val, C_out, D_out)
    n = 2;
    A = [zeros(n), eye(n); ...
         [-(k1 + k2_val)/m1, k2_val/m1; k2_val/m2, -k2_val/m2], ...
         [-b_val/m1, b_val/m1; b_val/m2, -b_val/m2]];
    % B (Entrada de perturbação w)
    B = [0; 0; k1/m1; 0];
    
    sys = ss(A, B, C_out, D_out);
end