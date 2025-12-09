function plot_raw_signature(residuo, t, tfalha, titulo)
% PLOT_RAW_SIGNATURE Plota os resíduos brutos (sem filtro) no tempo.
% Útil para verificar a estabilidade e a magnitude total do erro.
%
% Entradas:
%   residuo: Matriz [n_saidas x n_amostras]
%   t: Vetor de tempo
%   tfalha: Instante da falha
%   titulo: String para o título da figura

    figure('Name', titulo, 'Color', 'w');
    sgtitle(titulo, 'FontWeight', 'bold', 'FontSize', 14);
    
    % --- Subplot 1: Resíduo da Posição (y) ---
    subplot(2,1,1); 
    plot(t, residuo(1,:), 'b', 'LineWidth', 1); 
    hold on;
    xline(tfalha, 'r--', 'Início da Falha', 'LabelVerticalAlignment', 'bottom');
    
    title('Resíduo Bruto - Saída 1 (Posição)'); 
    ylabel('Erro (m)'); 
    xlabel('Tempo (s)');
    grid on; 
    axis tight; % Ajusta os eixos aos dados automaticamente
    
    % --- Subplot 2: Resíduo da Aceleração (y_ddot) ---
    subplot(2,1,2); 
    plot(t, residuo(2,:), 'k', 'LineWidth', 1); 
    hold on;
    xline(tfalha, 'r--', 'Início da Falha', 'LabelVerticalAlignment', 'bottom');
    
    title('Resíduo Bruto - Saída 2 (Aceleração)'); 
    ylabel('Erro (m/s^2)'); 
    xlabel('Tempo (s)');
    grid on; 
    axis tight;
end