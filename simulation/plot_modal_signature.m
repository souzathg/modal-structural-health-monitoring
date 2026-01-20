function plot_modal_signature(residuo_luen, residuo_kalman, t, tfalha, Fs, titulo)
% PLOT_MODAL_SIGNATURE - Layout 2x2 com 2 Saídas e Modos Sobrepostos
%
% Layout:
%   [ Saída 1 - Luenberger ]   [ Saída 1 - Kalman ]
%   [ Saída 2 - Luenberger ]   [ Saída 2 - Kalman ]
%
% Em cada subplot: Modo 1 (Azul) e Modo 2 (Vermelho/Laranja) sobrepostos.

    % --- 1. Filtros ---
    Wn_low  = 4 / (Fs/2);      % Passa-Baixas (Modo 1)
    Wn_band = [6 10] / (Fs/2); % Passa-Faixa (Modo 2)
    
    [b_low, a_low] = butter(4, Wn_low, 'low');
    [b_band, a_band] = butter(4, Wn_band, 'bandpass');
    
    figure('Name', titulo, 'Color', 'w', 'Position', [100, 100, 1200, 700]);
    sgtitle(titulo, 'FontWeight', 'bold', 'FontSize', 12);
    
    residuos = {residuo_luen, residuo_kalman};
    nomes_obs = {'Luenberger', 'Kalman'};
    nomes_saida = {'Saída 1 (M. Não Suspensa)', 'Saída 2 (M. Suspensa)'};
    
    % Loop para gerar os 4 gráficos
    plot_idx = 1;
    axes_handles = [];
    
    for i_saida = 1:2 % Linhas (Saída 1, Saída 2)
        for i_obs = 1:2 % Colunas (Luenberger, Kalman)
            
            % Seleciona o resíduo correto (Luen ou Kal) e a linha correta (Saída 1 ou 2)
            res_bruto = residuos{i_obs}(i_saida, :);
            
            % Filtra os Modos
            r_modo1 = filtfilt(b_low, a_low, res_bruto);
            r_modo2 = filtfilt(b_band, a_band, res_bruto);
            
            % Plotagem
            ax = subplot(2, 2, plot_idx);
            hold on;
            
            % Plot Modo 1 (Azul - Grosso)
            h1 = plot(t, r_modo1, 'b', 'LineWidth', 1.2);
            
            % Plot Modo 2 (Laranja - Fino para destaque sobreposto)
            h2 = plot(t, r_modo2, 'r--', 'LineWidth', 0.8);
            
            % Linha de Falha
            xline(tfalha, 'k:', 'LineWidth', 1.5);
            
            % Decoração
            title(sprintf('%s - %s', nomes_saida{i_saida}, nomes_obs{i_obs}));
            grid on; axis tight;
            if i_saida == 2; xlabel('Tempo (s)'); end
            if i_obs == 1; ylabel('Resíduo (m)'); end
            
            % Legenda apenas no primeiro gráfico para não poluir
            if plot_idx == 1
                legend([h1, h2], 'Modo 1 (<4Hz)', 'Modo 2 (6-10Hz)', 'Location', 'best');
            end
            
            axes_handles = [axes_handles, ax];
            plot_idx = plot_idx + 1;
        end
    end
    
    % Sincroniza Eixos Y por linha (para comparação justa entre Luenberger e Kalman na mesma saída)
    linkaxes(axes_handles(1:2), 'y'); % Linha 1 igual
    linkaxes(axes_handles(3:4), 'y'); % Linha 2 igual
end