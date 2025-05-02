% ---------------------------
% Simulação
% ---------------------------
% Entrada para o sistema: 2 entradas iguais
u = [x_chirp; x_chirp];

x = zeros(4, length(t));    % Estados reais
xhat = zeros(4, length(t)); % Estados estimados
e = zeros(4, length(t));    % Erro da saída

x(:,1) = [0.0; -0.0; 0.0; -0.0];  % Estado inicial real
xhat(:,1) = x(:,1);               % Estado inicial estimado

% Definição da falha (aplicando no Modo 1)
A_danificado = A;
A1_danificado = A1 * 1;         % Dano severo no modo 1
A_danificado(1:2,1:2) = A1_danificado;

for k = 1:length(t)-1
    if t(k) < tfalha
        A_current = A;
    else
        A_current = A_danificado;
    end

    % Sistema real
    x(:,k+1) = x(:,k) + dt*(A_current*x(:,k) + B*u(:,k));

    % Observador Kalman
    y = C2*x(:,k);
    yhat = C2*xhat(:,k);
    xhat(:,k+1) = xhat(:,k) + dt*(A*xhat(:,k) + B*u(:,k) + K*(y - yhat));

    % Erro de saída
    e(:,k) = y - yhat;
end

% Último erro de saída
y_end = C2*x(:,end);
yhat_end = C2*xhat(:,end);
e(:,end) = y_end - yhat_end;
