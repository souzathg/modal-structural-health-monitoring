function plot_modal_signature(residuo, t, tfalha, Fs, titulo)
% PLOT_MODAL_SIGNATURE Separa os modos usando filtros Passa-Baixas e Passa-Altas.
%
% Entradas:
%   residuo: Matriz de erros [n_saidas x n_amostras]
%   t: Vetor de tempo
%   tfalha: Instante da falha
%   Fs: Frequência de amostragem
%   titulo: Título do gráfico

    % Definição das frequências de corte (conforme solicitado)
    fc_modo1 = 3; % Hz (Passa-Baixas: pega tudo abaixo disso, inc. 1.5Hz)
    fc_modo2 = 7; % Hz (Passa-Altas: pega tudo acima disso, inc. 8.5Hz)
    
    % Normalização para Nyquist
    Wn_low  = fc_modo1 / (Fs/2);
    % Wn_high = fc_modo2 / (Fs/2);
    Wn_modo2 = [6 10] / (Fs/2);
    
    % Projeto dos Filtros (Butterworth 4ª Ordem)
    % Filtro Low-Pass para isolar o Modo 1
    [b_low, a_low] = butter(4, Wn_low, 'low');
    
    % Filtro High-Pass para isolar o Modo 2
    % [b_high, a_high] = butter(4, Wn_high, 'high');
    [b_band, a_band] = butter(4, Wn_modo2, 'bandpass');
    
    % Filtragem (Usando a saída 1: Posição, como referência)
    % filtfilt é crucial aqui para não causar atraso de fase no sinal
    r_modo1 = filtfilt(b_low, a_low, residuo(1,:));
    r_modo2 = filtfilt(b_band, a_band, residuo(1,:));
    
    % Plotagem
    figure('Name', titulo, 'Color', 'w');
    sgtitle(titulo, 'FontWeight', 'bold', 'FontSize', 12);
    
    % --- Subplot Modo 1 (Baixa Frequência) ---
    subplot(2,1,1); 
    plot(t, r_modo1, 'b', 'LineWidth', 1.2); 
    hold on; 
    xline(tfalha, 'r--', 'Falha', 'LabelVerticalAlignment', 'bottom');
    title(sprintf('Modo 1 Isolado (Passa-Baixas fc=%dHz)', fc_modo1)); 
    ylabel('Resíduo (m)'); 
    grid on; axis tight;
    
    % --- Subplot Modo 2 (Alta Frequência) ---
    subplot(2,1,2); 
    plot(t, r_modo2, 'k', 'LineWidth', 1.2); 
    hold on; 
    xline(tfalha, 'r--', 'Falha', 'LabelVerticalAlignment', 'bottom');
    title(sprintf('Modo 2 Isolado (Passa-Altas fc=%dHz)', fc_modo2)); 
    ylabel('Resíduo (m)'); 
    xlabel('Tempo (s)');
    grid on; axis tight;
end