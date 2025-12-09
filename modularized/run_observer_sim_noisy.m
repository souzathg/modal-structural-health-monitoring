function [residuo, SNR_calc] = run_observer_sim_noisy(SysNom, SysReal, L, t, w_in, tfalha)
% RUN_OBSERVER_SIM_NOISY Simula o sistema com ruído de processo e medição.
% 
% Metodologia baseada no TCC:
%   - Ruído de Processo: Covariância Q fixa (incerteza do modelo).
%   - Ruído de Medição: Calculado para garantir SNR = 30dB.
%
% Entradas:
%   SysNom, SysReal: Estruturas com matrizes do sistema (.A, .B, .C, .D)
%   L: Ganho do observador de Luenberger
%   t, w_in: Vetores de tempo e entrada (Chirp)
%   tfalha: Instante da ocorrência do dano

    dt = t(2) - t(1);
    n_states = size(SysNom.A, 1);
    n_out = size(SysNom.C, 1);
    N = length(t);
    
    % --- 1. Definição dos Parâmetros de Ruído (Conforme Texto) ---
    
    % Covariância do Ruído de Processo (Q)
    % Seção 4.6.2: "Q foi definida como uma matriz diagonal... q = 10^-7"
    q_val = 1e-7;
    Q = q_val * eye(n_states);
    
    % SNR alvo para o Ruído de Medição
    % Seção 4.4: "SNR_dB = 30"
    target_SNR_dB = 30;
    
    % --- 2. Pré-simulação para Calibração do Ruído de Medição (R) ---
    % Precisamos saber a potência do sinal "limpo" para calcular o ruído correto.
    % Simulamos o sistema nominal sem ruído rapidamente para obter essa referência.
    x_clean = zeros(n_states, N);
    y_clean = zeros(n_out, N);
    for k = 1:N-1
        dx = SysNom.A * x_clean(:,k) + SysNom.B * w_in(k);
        x_clean(:,k+1) = x_clean(:,k) + dt*dx;
        y_clean(:,k) = SysNom.C * x_clean(:,k) + SysNom.D * w_in(k);
    end
    
    % Cálculo da Potência do Sinal e da Variância do Ruído Necessária
    % P_ruido = P_sinal / 10^(SNR/10)
    R_diag = zeros(n_out, 1);
    for i = 1:n_out
        sinal_rms = rms(y_clean(i, :));
        potencia_sinal = sinal_rms^2;
        potencia_ruido = potencia_sinal / (10^(target_SNR_dB/10));
        R_diag(i) = potencia_ruido;
    end
    R = diag(R_diag); % Matriz de Covariância R calculada
    
    % (Opcional) Retorna a SNR calculada para verificação
    SNR_calc = 10*log10(mean(var(y_clean, 0, 2)) / mean(R_diag));

    % --- 3. Simulação Principal (Com Ruído e Falha) ---
    
    x = zeros(n_states, N); 
    xhat = zeros(n_states, N);
    residuo = zeros(n_out, N);
    
    % Condições iniciais
    x(:,1) = [0;0;0;0]; xhat(:,1) = [0;0;0;0];

    fprintf('Simulação iniciada (SNR: %d dB, Q: %0.1e)...\n', target_SNR_dB, q_val);

    for k = 1:N-1
        % Seleção do Sistema Físico (Saudável ou Danificado)
        if t(k) < tfalha
            Ar = SysNom.A; Cr = SysNom.C; Dr = SysNom.D;
        else
            Ar = SysReal.A; Cr = SysReal.C; Dr = SysReal.D;
        end
        
        % Geração dos Ruídos para este passo
        % Ruído de Processo w_proc ~ N(0, Q)
        % Normalizamos por sqrt(dt) para integração de Euler
        proc_noise = (sqrt(Q) * randn(n_states, 1)) / sqrt(dt);
        
        % Ruído de Medição v ~ N(0, R)
        meas_noise = sqrt(R) * randn(n_out, 1);
        
        % A. Dinâmica do Sistema Real (Com Ruído de Processo)
        % x_dot = A*x + B*u + ruído
        dx = Ar*x(:,k) + SysNom.B*w_in(k) + proc_noise;
        x(:,k+1) = x(:,k) + dt*dx;
        
        % B. Medição (Com Ruído de Sensor)
        % y = C*x + D*u + v
        y_k = Cr*x(:,k) + Dr*w_in(k) + meas_noise;
        
        % C. Observador de Luenberger
        % Predição: y_hat = C*x_hat + D*u
        yhat_k = SysNom.C*xhat(:,k) + SysNom.D*w_in(k);
        
        % Cálculo do Resíduo (Inovação)
        r_k = y_k - yhat_k;
        residuo(:,k) = r_k;
        
        % Atualização do Estado Estimado
        % x_hat_dot = A*x_hat + B*u + L*(y_medido - y_estimado)
        dx_hat = SysNom.A*xhat(:,k) + SysNom.B*w_in(k) + L*r_k;
        xhat(:,k+1) = xhat(:,k) + dt*dx_hat;
    end
end