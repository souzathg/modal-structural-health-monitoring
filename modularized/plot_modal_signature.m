function plot_modal_signature(residuo_luen, residuo_kalman, t, tfalha, Fs, titulo)
% PLOT_MODAL_SIGNATURE Plota Luenberger e Kalman em subplots separados (Grade 2x2).
%
% Layout:
%   [ Luenberger Modo 1 ]  [ Kalman Modo 1 ]
%   [ Luenberger Modo 2 ]  [ Kalman Modo 2 ]
%
% Entradas:
%   residuo_luen: Matriz de erros do Luenberger
%   residuo_kalman: Matriz de erros do Kalman
%   t: Vetor de tempo
%   tfalha: Instante da falha
%   Fs: Frequência de amostragem
%   titulo: Título geral da figura

    % --- 1. Definição e Projeto dos Filtros ---
    fc_modo1 = 4; % Hz (Corte do Passa-Baixas)
    
    Wn_low  = fc_modo1 / (Fs/2);
    Wn_band = [6 10] / (Fs/2);
    
    [b_low, a_low] = butter(4, Wn_low, 'low');
    [b_band, a_band] = butter(4, Wn_band, 'bandpass');
    
    % --- 2. Filtragem dos Sinais ---
    % Luenberger
    r_luen_m1 = filtfilt(b_low, a_low, residuo_luen(1,:));
    r_luen_m2 = filtfilt(b_band, a_band, residuo_luen(1,:));
    
    % Kalman
    r_kalman_m1 = filtfilt(b_low, a_low, residuo_kalman(1,:));
    r_kalman_m2 = filtfilt(b_band, a_band, residuo_kalman(1,:));
    
    % --- 3. Plotagem em Grade 2x2 ---
    figure('Name', titulo, 'Color', 'w', 'Position', [100, 100, 1000, 600]);
    sgtitle(titulo, 'FontWeight', 'bold', 'FontSize', 12);
    
    % -- LINHA 1: MODO 1 (Baixa Frequência) --
    
    % Subplot 1: Luenberger Modo 1
    ax1 = subplot(2,2,1); 
    plot(t, r_luen_m1, 'b', 'LineWidth', 1); hold on;
    xline(tfalha, 'k--', 'Falha');
    title('Luenberger: Modo 1'); 
    ylabel('Resíduo (m)'); grid on; axis tight;
    
    % Subplot 2: Kalman Modo 1
    ax2 = subplot(2,2,2); 
    plot(t, r_kalman_m1, 'r', 'LineWidth', 1); hold on;
    xline(tfalha, 'k--', 'Falha');
    title('Kalman: Modo 1'); 
    grid on; axis tight;
    
    % -- LINHA 2: MODO 2 (Alta Frequência) --
    
    % Subplot 3: Luenberger Modo 2
    ax3 = subplot(2,2,3); 
    plot(t, r_luen_m2, 'b', 'LineWidth', 1); hold on;
    xline(tfalha, 'k--', 'Falha');
    title('Luenberger: Modo 2'); 
    ylabel('Resíduo (m)'); xlabel('Tempo (s)'); grid on; axis tight;
    
    % Subplot 4: Kalman Modo 2
    ax4 = subplot(2,2,4); 
    plot(t, r_kalman_m2, 'r', 'LineWidth', 1); hold on;
    xline(tfalha, 'k--', 'Falha');
    title('Kalman: Modo 2'); 
    xlabel('Tempo (s)'); grid on; axis tight;
    
    % --- 4. Sincronização de Eixos (Dica Profissional) ---
    % Trava os eixos Y da linha de cima para serem iguais (comparação justa)
    linkaxes([ax1, ax2], 'y');
    % Trava os eixos Y da linha de baixo para serem iguais
    linkaxes([ax3, ax4], 'y');
end