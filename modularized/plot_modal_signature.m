function plot_modal_signature(residuo, t, tfalha, freqs_hz, Fs, titulo)
% PLOT_MODAL_SIGNATURE Filtra resíduos nas frequências naturais e plota.

    f1 = freqs_hz(1); 
    f2 = freqs_hz(2);
    
    % Projeto dos Filtros
    Wn1 = [f1-1 f1+1] / (Fs/2); [b1, a1] = butter(4, Wn1, 'bandpass');
    Wn2 = [f2-2 f2+2] / (Fs/2); [b2, a2] = butter(4, Wn2, 'bandpass');
    
    % Filtragem (apenas da primeira saída como exemplo)
    r_modo1 = filtfilt(b1, a1, residuo(1,:));
    r_modo2 = filtfilt(b2, a2, residuo(1,:));
    
    % Plotagem
    figure('Name', titulo, 'Color', 'w');
    sgtitle(titulo, 'FontWeight', 'bold');
    
    subplot(2,1,1); 
    plot(t, r_modo1, 'b'); hold on; xline(tfalha, 'r--', 'Falha');
    title(sprintf('Resíduo Modo 1 (%.1f Hz)', f1)); 
    grid on; ylabel('Erro (m)'); axis tight;
    
    subplot(2,1,2); 
    plot(t, r_modo2, 'k'); hold on; xline(tfalha, 'r--', 'Falha');
    title(sprintf('Resíduo Modo 2 (%.1f Hz)', f2)); 
    grid on; ylabel('Erro (m)'); axis tight;
end