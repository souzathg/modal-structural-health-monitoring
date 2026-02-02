%% Análise de Sensibilidade Paramétrica (Diagrama de Bode)
% Descrição: Este script gera diagramas de Bode (apenas Magnitude) variando
% os parâmetros de amortecimento (b) e rigidez da suspensão (k2) de
% 0% a 100% do valor nominal.
% A saída analisada é a Posição da Massa Suspensa (y).

clear; clc; close all;

%% 1. Parâmetros Nominais do Sistema
m1 = 1;         % Massa não suspensa [kg]
m2 = 2.45;      % Massa suspensa [kg]
k1 = 1250;      % Rigidez do pneu [N/m] (Fixo)
k2_nom = 900;   % Rigidez NOMINAL da suspensão [N/m]
b_nom  = 7.5;   % Amortecimento NOMINAL [Ns/m]

% Vetor de variações (0% a 100% em passos de 10%)
% Nota: Evitamos 0 exato para k2 para não gerar matriz singular, usamos um valor muito pequeno.
porcentagens = [1e-6, 0.1:0.1:1.0]; 
num_vars = length(porcentagens);

% Vetor de frequências (0.1 a 12 Hz conforme seu chirp)
w_freq = linspace(0.1, 12, 500) * 2 * pi; 
f_hz = w_freq / (2*pi);

%% --- FIGURA 1: Variação do Amortecimento (b) ---
figure('Name', 'Sensibilidade - Amortecimento (b)', 'Color', 'w', 'Position', [100, 100, 1000, 800]);

% sgtitle('Resposta à variação do coef. de amortecimento (b)')

% Prepara os eixos
ax1 = subplot(2,1,1); hold on; grid on; title('Saída 1 — Massa Não-Suspensa (y_1)', FontSize=11, FontWeight='bold'); ylabel('Magnitude (dB)');
ax2 = subplot(2,1,2); hold on; grid on; title('Saída 2 — Massa Suspensa (y_2)', FontSize=11, FontWeight='bold'); ylabel('Magnitude (dB)'); xlabel('Frequência (Hz)');

% Cores para o gradiente
cores = jet(num_vars);

for i = 1:num_vars
    pct = porcentagens(i);
    
    % Parâmetros atuais
    b_atual = b_nom * pct;
    k2_atual = k2_nom;     % k2 fixo no nominal
    
    % Monta o sistema
    [A, B, C, D] = generate_model(m1, m2, k1, k2_atual, b_atual);

    sys_curr = ss(A, B, C, D);
    
    % Calcula a resposta em frequência (MIMO: 2 saídas, 1 entrada)
    [mag, ~] = bode(sys_curr, w_freq);
    
    % --- ALTERAÇÃO 2: EXTRAÇÃO DOS DADOS ---
    % mag tem dimensões [Saídas x Entradas x Frequencias] -> [2 x 1 x 500]
    
    % Saída 1 (x1)
    mag_x1 = squeeze(mag(1, 1, :));
    mag_db_x1 = 20*log10(mag_x1);
    
    % Saída 2 (x2)
    mag_x2 = squeeze(mag(2, 1, :));
    mag_db_x2 = 20*log10(mag_x2);
    
    % Plota nos subplots respectivos
    plot(ax1, f_hz, mag_db_x1, 'Color', cores(i,:), 'LineWidth', 1);
    plot(ax2, f_hz, mag_db_x2, 'Color', cores(i,:), 'LineWidth', 1);
end

% Ajustes Finais Figura 1
linkaxes([ax1, ax2], 'x'); xlim(ax1, [0.1 12]);
colormap(ax1, jet); c = colorbar(ax1, 'Position', [0.925 0.33 0.015 0.35]); c.Label.String = '% do coef. de amortecimento da suspensão (b)';
colormap(ax2, jet); % Apenas para manter consistência visual


%% --- FIGURA 2: Variação da Rigidez (k2) ---
figure('Name', 'Sensibilidade - Rigidez (k2)', 'Color', 'w', 'Position', [150, 100, 1000, 800]);

% sgtitle('Resposta à variação do coef. de rigidez (k_2)')

% Prepara os eixos
ax3 = subplot(2,1,1); hold on; grid on; title('Saída 1 — Massa Não-Suspensa (y_1)', FontSize=11, FontWeight='bold'); ylabel('Magnitude (dB)');
ax4 = subplot(2,1,2); hold on; grid on; title('Saída 2 — Massa Suspensa (y_2)', FontSize=11, FontWeight='bold'); ylabel('Magnitude (dB)'); xlabel('Frequência (Hz)');

for i = 1:num_vars
    pct = porcentagens(i);
    
    % Parâmetros atuais
    b_atual = b_nom;      % b fixo no nominal
    k2_atual = k2_nom * pct;
    
    [A, B, C, D] = generate_model(m1, m2, k1, k2_atual, b_atual);

    sys_curr = ss(A, B, C, D);

    % Calcula Bode
    [mag, ~] = bode(sys_curr, w_freq);
    
    % Extrai e Converte para dB
    mag_db_x1 = 20*log10(squeeze(mag(1, 1, :)));
    mag_db_x2 = 20*log10(squeeze(mag(2, 1, :)));
    
    % Plota
    plot(ax3, f_hz, mag_db_x1, 'Color', cores(i,:), 'LineWidth', 1);
    plot(ax4, f_hz, mag_db_x2, 'Color', cores(i,:), 'LineWidth', 1);
end

% Ajustes Finais Figura 2
linkaxes([ax3, ax4], 'x'); xlim(ax3, [0.1 12]);
colormap(ax3, jet); c = colorbar(ax3, 'Position', [0.925 0.33 0.015 0.35]); c.Label.String = '% do coef. de rigidez da suspensão (k_2)';
colormap(ax4, jet);


%% --- FUNÇÃO LOCAL PARA GERAR O SISTEMA ---
function sys = get_sys_ss(m1, m2, k1, k2, b, C, D)
    % Gera as matrizes A e B locais
    % (Copiado da lógica do seu generate_model, mas simplificado para o script)
    
    A = [0, 1, 0, -1;
        -k2/m2, -b/m2, 0, b/m2;
        0, 0, 0, 1;
        k2/m1, b/m1, -k1/m1, -b/m1]; % Com a correção da vírgula
        
    B = [0; 0; -1; 1/m1];
    
    % Cria objeto State-Space
    sys = ss(A, B, C, D);
end