%% Análise de Sensibilidade da Saída em Função do Dano
% Variação de 100% a 0% nos modos 1 e 2 - Diagrama de Bode

close all; clear;

%% Definicao do Sistema base
A1_base = [-0.574 17.825; -17.825 -0.574];
A2_base = [-5.762 49.053; -49.053 -5.762];

B1 = [2.726 0.0021; 1.052 0.0012];
B2 = [-5.042 0.0054; 1.023 -0.0014];

C21 = [2.938 -6.420];
C22 = [-0.055 -1.499];

C2 = [C21 C22];
D = [0 0];

B = [B1; B2];

%% Fatores de dano (0% -> 100% de saúde)
struct_health = 0:10:100;
fatores = struct_health/100;  % Converte para 1.0, 0.9, ..., 0.0

%% Frequencia de analise
Fs = 1e3;                   % Frequencia de amostragem (apenas para referencia)
freq = linspace(0,12,500);  % Frequencia de 0 a 12 Hz
omega = 2*pi*freq;          % Converter para rad/s para o bode

%% Armazenar respostas para plot
mag_all = zeros(length(freq), length(fatores));

%% Loop sobre as variacoes
for i = 1:length(fatores)
    fator = fatores(i);

    % Aplicar o fator de dano nos dois modos
    A1_danificado = A1_base * fator;
    A2_danificado = A2_base * fator;

    % Construir nova matriz A danificada
    A_danificado = [A1_danificado zeros(2); zeros(2) A2_danificado];

    % Sistema dinamico
    sys_danificado = ss(A_danificado, B, C2, D);

    % Resposta em frequencia
    [mag, ~] = bode(sys_danificado, omega);

    % mag tem dimensao (nsaida, nentrada, nfrequencia)
    % Vamos pegar a primeira saida e primeira entrada:
    mag_all(:,i) = squeeze(mag(1,1,:));
end

%% Plotar todos os resultados
figure
hold on
colors = jet(length(fatores));  % Paleta de cores

for i = 1:length(fatores)
    plot(freq, 20*log10(mag_all(:,i)), 'Color', colors(i,:), 'LineWidth', 1.5)
end

xlabel('Frequência (Hz)')
ylabel('Magnitude (dB)')
title('Diagrama de Bode - Variação dos Modos com Dano')
grid on
legend(arrayfun(@(p) sprintf('Saúde Estrutural %d%%', p), struct_health, 'UniformOutput', false))
hold off
