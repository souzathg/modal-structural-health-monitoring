close all; clear;

% ---------------------------
% Definição do Sistema
% ---------------------------
A1 = [-0.574 17.825; 
     -17.825 -0.574];
A2 = [-5.762 49.053;
     -49.053 -5.762];

A = [A1 zeros(2);
     zeros(2) A2];

B1 = [2.726 0.0021;
      1.052 0.0012];
B2 = [-5.042 0.0054;
      1.023 -0.0014];

B = [B1; B2];

C21 = [2.938 -6.420];
C22 = [-0.055 -1.499];

C2 = [C21 C22];
D = [0 0];

% Projeto do Observador
poles_sys = eig(A);
poles_observer = 4 * real(poles_sys) + 1i*imag(poles_sys);
L = place(A', C2', poles_observer)';  % Ganho do Observador

% ---------------------------
% Definição do sinal Chirp
% ---------------------------
Fs = 1e3;            % Frequência de amostragem
Fstart = 0;           % Frequência inicial
Fstop = 12;            % Frequência final
BW = Fstop - Fstart;
Tchirp = 20;          % Duração de cada chirp (s)

tVec1 = 0:1/Fs:Tchirp;
tVec2 = (Tchirp):1/Fs:2*Tchirp;

x1_chirp = sin(2*pi*(Fstart.*tVec1 + BW/(2*Tchirp).*tVec1.^2));
x2_chirp = sin(2*pi*(Fstart.*(tVec2 - Tchirp) + BW/(2*Tchirp).*(tVec2 - Tchirp).^2));

x_chirp = [x1_chirp x2_chirp];
t = [tVec1 tVec2];
dt = 1/Fs;
tfalha = 20;          % Falha em 20 segundos

% Entrada para o sistema: 2 entradas iguais
u = [x_chirp; x_chirp];

% ---------------------------
% Simulação do Sistema
% ---------------------------
x = zeros(4, length(t));    % Estados reais
xhat = zeros(4, length(t)); % Estados estimados
e = zeros(4, length(t));    % Erro de estimação

x(:,1) = [0.0; -0.0; 0.0; -0.0];  % Estado inicial real
xhat(:,1) = x(:,1);         % Estado inicial estimado

% Definição da falha (aplicando no Modo 1)
A_danificado = A;
A2_danificado = A2 * 0.95;         % Dano severo no modo 1
A_danificado(3:4,3:4) = A2_danificado;

% Simulação
for k = 1:length(t)-1
    if t(k) < tfalha
        A_current = A;
    else
        A_current = A_danificado;
    end
    
    % Sistema real
    x(:,k+1) = x(:,k) + dt*(A_current*x(:,k) + B*u(:,k));
    
    % Observador
    y = C2*x(:,k);
    yhat = C2*xhat(:,k);
    xhat(:,k+1) = xhat(:,k) + dt*(A*xhat(:,k) + B*u(:,k) + L*(y - yhat));
    
    % Erro
    e(:,k) = x(:,k) - xhat(:,k);
end
e(:,end) = x(:,end) - xhat(:,end);

norma_erro_total = vecnorm(e);
norma_erro_modo1 = vecnorm(e(1:2,:));  % Estados 1 e 2
norma_erro_modo2 = vecnorm(e(3:4,:));  % Estados 3 e 4

% Encontrar índice da falha
idx_falha = find(t >= tfalha, 1);

% Erro médio após a falha
erro_modo1_after = mean(norma_erro_modo1(idx_falha:end));
erro_modo2_after = mean(norma_erro_modo2(idx_falha:end));

% Comparação
disp(['Erro médio após falha - Modo 1: ', num2str(erro_modo1_after)]);
disp(['Erro médio após falha - Modo 2: ', num2str(erro_modo2_after)]);

if erro_modo1_after > 2*erro_modo2_after
    disp('>> Conclusão: Dano no Modo 1 detectado.');
elseif erro_modo2_after > 2*erro_modo1_after
    disp('>> Conclusão: Dano no Modo 2 detectado.');
else
    disp('>> Conclusão: Não foi possível identificar um modo afetado de forma clara.');
end

% ---------------------------
% Saídas Reais e Estimadas
% ---------------------------
y_real = C2*x;
y_est = C2*xhat;

% Definir C para o modo 1
C_modo1 = [C21 0 0];  % Zeroa as contribuições do modo 2

% Saídas reais e estimadas só do modo 1
y_real_modo1_semfiltro = C_modo1 * x;
y_est_modo1_semfiltro = C_modo1 * xhat;

% Erro da saída do modo 1
erro_saida_modo1_semfiltro = y_real_modo1_semfiltro - y_est_modo1_semfiltro;

% Definir C para o modo 2
C_modo2 = [0 0 C22];

% Saídas reais e estimadas só do modo 2
y_real_modo2_semfiltro = C_modo2 * x;
y_est_modo2_semfiltro = C_modo2 * xhat;

% Erro da saída do modo 2
erro_saida_modo2_semfiltro = y_real_modo2_semfiltro - y_est_modo2_semfiltro;

erro_saida = y_real - y_est;

% Plotando saída real vs saída estimada
figure
plot(t, y_real, 'b', 'LineWidth', 1.0)
hold on
plot(t, y_est, 'r--', 'LineWidth', 1.0)
xlabel('Tempo (s)')
ylabel('Saída')
legend('Saída Real', 'Saída Estimada (Observador de Luenberger)')
title('Saída real vs Saída estimada pelo Observador de Luenberger')
grid on
xline(tfalha, '--k', 'Falha');

% Sinal Chirp
figure
plot(t, x_chirp)
xlabel('Tempo (s)')
ylabel('Amplitude')
title('Sinal Chirp aplicado ao sistema (0-12Hz de 0-20s e 20-40s)')
grid on

% Estados reais e estimados
figure
plot(t, x(1,:), 'b', t, xhat(1,:), 'b--')
hold on
plot(t, x(2,:), 'r', t, xhat(2,:), 'r--')
plot(t, x(3,:), 'g', t, xhat(3,:), 'g--')
plot(t, x(4,:), 'm', t, xhat(4,:), 'm--')
legend('x1', 'x1 estimado', 'x2', 'x2 estimado', 'x3', 'x3 estimado', 'x4', 'x4 estimado')
xlabel('Tempo (s)')
ylabel('Estados')
title('Estados reais vs estimados (Filtro de Kalman)')
grid on
xline(tfalha, '--k', 'Falha');

% Norma total do erro
figure
plot(t, norma_erro_total, 'k', 'LineWidth', 1.5)
xlabel('Tempo (s)')
ylabel('Norma do erro ||e(t)||')
title('Norma do erro total (Filtro de Kalman)')
grid on
xline(tfalha, '--r', 'Falha');

% Norma do erro por modo
figure
plot(t, norma_erro_modo1, 'b', 'LineWidth', 1.5)
hold on
plot(t, norma_erro_modo2, 'r', 'LineWidth', 1.5)
xlabel('Tempo (s)')
ylabel('Norma do erro por modo ||e(t)||')
legend('Erro do Modo 1', 'Erro do Modo 2')
title('Norma do erro de estimação separada por modo (Filtro de Kalman)')
grid on
xline(tfalha, '--k', 'Falha');

figure
plot(t, erro_saida)
xlabel('Tempo (s)')
ylabel('Erro de saída')
title('Erro de saída observado vs estimado (sem norma)')
grid on
xline(tfalha, '--r', 'Falha');

figure
plot(t, erro_saida_modo1_semfiltro, 'b', 'LineWidth', 1.5)
hold on
plot(t, erro_saida_modo2_semfiltro, 'r', 'LineWidth', 1.5)
xlabel('Tempo (s)')
ylabel('Erro de saída modal')
legend('Erro do Modo 1', 'Erro do Modo 2')
title('Erro da saída modal SEM filtragem')
grid on
xline(tfalha, '--k', 'Falha');