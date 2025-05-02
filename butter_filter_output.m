% Frequência de amostragem
Fs = 16e3;  

% Filtro passa-baixa para pegar o modo 1 (~2.8 Hz)
fc_corte = 5;  % Frequência de corte em Hz (um pouco acima de 2.8 Hz para garantir o modo 1 inteiro)
Wn_lowpass = fc_corte / (Fs/2);

% Criar o filtro Butterworth passa-baixa
[b_low, a_low] = butter(4, Wn_lowpass, 'low');  % Ordem 4 é bem segura

% Aplicar o filtro no erro de saída
erro_saida_modo1_lowpass = filtfilt(b_low, a_low, e);