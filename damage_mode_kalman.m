close all; clear;

%% Preambulo
system_definition

% ---------------------------
% Filtro de Kalman
% ---------------------------
Q = 1e-5 * eye(4);   % Covariância do ruído de processo
R = 1e-3;            % Covariância do ruído de medição

[K, ~, ~] = lqe(A, eye(4), C2, Q, R);  % Ganho de Kalman

%% Sinal Chirp
chirp

%% Simulação
simulation

butter_filter_output

%% Análise Pós-Simulação

% ---------------------------
% Análise dos Erros
% ---------------------------
norma_erro_total = vecnorm(e);

%% Plots

% ---------------------------
% Plots
% ---------------------------

% Sinal Chirp
figure
plot(t, x_chirp)
xlabel('Tempo (s)')
ylabel('Amplitude')
title('Sinal Chirp aplicado ao sistema (0-12Hz de 0-20s e 20-40s)')
grid on

% % Estados reais e estimados
% figure
% plot(t, x(1,:), 'b', t, xhat(1,:), 'b--')
% hold on
% plot(t, x(2,:), 'r', t, xhat(2,:), 'r--')
% plot(t, x(3,:), 'g', t, xhat(3,:), 'g--')
% plot(t, x(4,:), 'm', t, xhat(4,:), 'm--')
% legend('x1', 'x1 estimado', 'x2', 'x2 estimado', 'x3', 'x3 estimado', 'x4', 'x4 estimado')
% xlabel('Tempo (s)')
% ylabel('Estados')
% title('Estados reais vs estimados (Filtro de Kalman)')
% grid on
% xline(tfalha, '--k', 'Falha');

% Norma total do erro
figure
plot(t, norma_erro_total, 'k', 'LineWidth', 1.5)
xlabel('Tempo (s)')
ylabel('Norma do erro ||e(t)||')
title('Norma do erro total (Filtro de Kalman)')
grid on
xline(tfalha, '--r', 'Falha');

% Erro modal no modo 1
figure
plot(t, erro_saida_modo1, 'b', 'LineWidth', 1.5)
xlabel('Tempo (s)')
ylabel('Erro de saída - Modo 1')
title('Erro de saída no Modo 1 (Filtro Butterworth)')
grid on
hold on
plot([tfalha tfalha], ylim, '--k')
hold off

% Erro modal no modo 2
figure
plot(t, erro_saida_modo2, 'r', 'LineWidth', 1.5)
xlabel('Tempo (s)')
ylabel('Erro de saída - Modo 2')
title('Erro de saída no Modo 2 (Filtro Butterworth)')
grid on
hold on
plot([tfalha tfalha], ylim, '--k')
hold off