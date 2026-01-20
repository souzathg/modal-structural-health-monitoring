%% Visualização do Sinal de Entrada (Chirp) - 3 Figuras Separadas
% Autor: Thiago Tioma
% Descrição: Plota o sinal no tempo, o espectrograma e o zoom em janelas distintas.

clc; clear; close all;

%% 1. Configuração (Mesmos parâmetros do main.m)
Fs = 1e3;           % Frequência de amostragem (1000 Hz)
Tchirp = 20;        % Duração de CADA varredura
Ampl = 0.04;        % Amplitude (4 cm)
Fstart = 0;         % Frequência inicial
Fstop = 12;         % Frequência final

%% 2. Geração do Sinal
% Chama sua função local
[w_in, t] = generate_chirp(Fs, Tchirp, Ampl, Fstart, Fstop);

%% FIGURA 1: Domínio do Tempo (Completo)
figure('Name', 'Sinal Completo no Tempo', 'Color', 'w', 'Position', [50, 500, 800, 400]);

plot(t, w_in, 'b', 'LineWidth', 1.0);
grid on;
%title(sprintf('Sinal Chirp (0-12Hz)'), 'FontSize', 12, 'FontWeight', 'normal');
xlabel('Tempo (s)');
ylabel('Amplitude (m)');
xlim([0, t(end)]);
ylim([-Ampl*1.2, Ampl*1.2]); % Margem visual para não cortar picos

%% FIGURA 2: Espectrograma (Frequência x Tempo)
figure('Name', 'Espectrograma do Chirp', 'Color', 'w', 'Position', [50, 50, 800, 400]);

% Parâmetros do espectrograma: janela de 512 amostras, overlap alto (480) para suavidade
spectrogram(w_in, kaiser(512,5), 480, 512, Fs, 'yaxis');

%title(sprintf('Espectrograma: Varredura de %.1f a %.1f Hz', Fstart, Fstop), 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Tempo (s)');
ylabel('Frequência (Hz)');
ylim([0, 12]); % Foco na faixa de interesse (0-15Hz)
colorbar;      % Mostra a escala de intensidade

%% FIGURA 3: Zoom Detalhado (Início)
figure('Name', 'Zoom no Inicio (Baixa Frequencia)', 'Color', 'w', 'Position', [900, 500, 600, 400]);

plot(t, w_in, 'b.-', 'LineWidth', 1.2, 'MarkerSize', 8);
grid on;
title('Zoom nos primeiros 2 segundos (Detalhe da Senóide)', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Tempo (s)'); 
ylabel('Amplitude (m)');
xlim([0, 2]); % Apenas os primeiros 2 segundos
ylim([-Ampl*1.2, Ampl*1.2]);