%% Simulacao de detecção de dano
% Comparando Observador de Luenberger (2x mais rápido) e Filtro de Kalman

close all; clear;

%% Definicao do Sistema
A1 = [-0.574 17.825; -17.825 -0.574];
A2 = [-5.762 49.053; -49.053 -5.762];

A = [A1 zeros(2); zeros(2) A2];

B1 = [2.726 0.0021; 1.052 0.0012];
B2 = [-5.042 0.0054; 1.023 -0.0014];

B = [B1; B2];

C21 = [2.938 -6.420];
C22 = [-0.055 -1.499];

C2 = [C21 C22];
D = [0 0];

nivel_ruido = .005;

%% Frequencia de amostragem e sinal de entrada
Fs = 1e3;
Fstart = 0;
Fstop = 12;
Tchirp = 20;

% Vetores de tempo
tVec1 = 0:1/Fs:Tchirp;
tVec2 = (Tchirp):1/Fs:2*Tchirp;
t = [tVec1 tVec2];
dt = 1/Fs;

% Sinal de entrada chirp
x1_chirp = sin(2*pi*(Fstart.*tVec1 + (Fstop-Fstart)/(2*Tchirp).*tVec1.^2));
x2_chirp = sin(2*pi*(Fstart.*(tVec2-Tchirp) + (Fstop-Fstart)/(2*Tchirp).*(tVec2-Tchirp).^2));

x_chirp = [x1_chirp x2_chirp];
u = [x_chirp; x_chirp];

%% Sistema danificado (dano no modo 1)
A_danificado = A;
A2_danificado = A2 * 0.95;
A_danificado(3:4,3:4) = A2_danificado;

%% Prealocacao
n_states = size(A,1);
n_samples = length(t);
tfalha = 20;

%% Projeto do Observador de Luenberger (2x polos)
poles_A = eig(A);
poles_observador = 4 * real(poles_A) + 1i*imag(poles_A);
L = place(A', C2', poles_observador)';

%% Projeto do Filtro de Kalman (para comparar)
Q = 1 * eye(4);
R = 1e-1;
[K_kalman, ~, ~] = lqe(A, eye(4), C2, Q, R);

%% Simulacao - Observador de Luenberger
x = zeros(n_states, n_samples);
xhat_L = zeros(n_states, n_samples);
e_saida_L = zeros(size(C2,1), n_samples);

x(:,1) = [0.5; -0.5; 0.5; -0.5];
xhat_L(:,1) = x(:,1);

for k = 1:n_samples-1
    if t(k) < tfalha
        A_current = A;
    else
        A_current = A_danificado;
    end

    x(:,k+1) = x(:,k) + dt*(A_current*x(:,k) + B*u(:,k));

    y = C2*x(:,k) + nivel_ruido*randn(size(C2,1),1);
    yhat_L = C2*xhat_L(:,k);
    xhat_L(:,k+1) = xhat_L(:,k) + dt*(A*xhat_L(:,k) + B*u(:,k) + L*(y - yhat_L));

    e_saida_L(:,k) = y - yhat_L;
end

e_saida_L(:,end) = C2*x(:,end) - C2*xhat_L(:,end);

%% Simulacao - Filtro de Kalman
xhat_K = zeros(n_states, n_samples);
e_saida_K = zeros(size(C2,1), n_samples);

xhat_K(:,1) = x(:,1);

for k = 1:n_samples-1
    y = C2*x(:,k) + nivel_ruido*randn(size(C2,1),1);
    yhat_K = C2*xhat_K(:,k);
    xhat_K(:,k+1) = xhat_K(:,k) + dt*(A*xhat_K(:,k) + B*u(:,k) + K_kalman*(y - yhat_K));

    e_saida_K(:,k) = y - yhat_K;
end
e_saida_K(:,end) = C2*x(:,end) - C2*xhat_K(:,end);

%% Filtros Lowpass (modo 1) e Highpass (modo 2)
fc_corte_lp = 5;   % Para modo 1
fc_corte_hp = 6;   % Para modo 2

[b_low, a_low] = butter(4, fc_corte_lp/(Fs/2), 'low');
[b_high, a_high] = butter(4, fc_corte_hp/(Fs/2), 'high');

% Aplicar filtragem no erro de saida
erro_saida_L_modo1 = filtfilt(b_low, a_low, e_saida_L);
erro_saida_L_modo2 = filtfilt(b_high, a_high, e_saida_L);

erro_saida_K_modo1 = filtfilt(b_low, a_low, e_saida_K);
erro_saida_K_modo2 = filtfilt(b_high, a_high, e_saida_K);

%% Norma dos erros
norma_erro_L_modo1 = sqrt(sum(erro_saida_L_modo1.^2,1));
norma_erro_L_modo2 = sqrt(sum(erro_saida_L_modo2.^2,1));

norma_erro_K_modo1 = sqrt(sum(erro_saida_K_modo1.^2,1));
norma_erro_K_modo2 = sqrt(sum(erro_saida_K_modo2.^2,1));

%% Plotagens
figure
plot(t, norma_erro_L_modo1, 'b', 'LineWidth', 1.5)
hold on
plot(t, norma_erro_K_modo1, 'r--', 'LineWidth', 1.5)
plot([tfalha tfalha], ylim, '--k')
hold off
xlabel('Tempo (s)')
ylabel('Norma do erro - Modo 1')
title('Comparacao Modo 1: Luenberger vs Kalman')
legend('Luenberger','Kalman')
grid on

figure
plot(t, norma_erro_L_modo2, 'b', 'LineWidth', 1.5)
hold on
plot(t, norma_erro_K_modo2, 'r--', 'LineWidth', 1.5)
plot([tfalha tfalha], ylim, '--k')
hold off
xlabel('Tempo (s)')
ylabel('Norma do erro - Modo 2')
title('Comparacao Modo 2: Luenberger vs Kalman')
legend('Luenberger','Kalman')
grid on