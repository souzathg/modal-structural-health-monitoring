function [residuo, SNR_calc] = run_observer_sim_noisy(SysNom, SysReal, L, t, w_in, tfalha)
% RUN_OBSERVER_SIM_NOISY Suporta MIMO (Múltiplas Saídas).

    dt = t(2) - t(1);
    n_states = size(SysNom.A, 1);
    n_out = size(SysNom.C, 1); % Agora n_out = 2
    N = length(t);
    
    % --- 1. Definição de Ruídos ---
    q_val = 1e-7;
    Q = q_val * eye(n_states);
    
    % Simulação Prévia "Limpa" para calibração do R (SNR 30dB)
    % Precisamos saber a potência do sinal em CADA saída para ajustar o ruído
    y_clean = lsim(ss(SysNom.A, SysNom.B, SysNom.C, SysNom.D), w_in, t)';
    
    target_SNR_dB = 30;
    R_diag = zeros(n_out, 1);
    
    for i = 1:n_out
        signal_power = rms(y_clean(i, :))^2;
        noise_power = signal_power / (10^(target_SNR_dB/10));
        R_diag(i) = noise_power;
    end
    R = diag(R_diag); % Matriz R (2x2)
    
    % --- 2. Inicialização ---
    x = zeros(n_states, N);
    x_hat = zeros(n_states, N);
    residuo = zeros(n_out, N);
    
    % --- 3. Loop de Simulação ---
    for k = 1:N-1
        % Seleção do Sistema (Nominal vs Falha)
        if t(k) < tfalha
            Ar = SysNom.A; 
            % Importante: Usar B e C corretos do sistema real
            % Se SysReal tem falha paramétrica, Ar muda.
            % Se SysReal tem falha de sensor, Cr muda (não é o caso aqui, falha física).
        else
            Ar = SysReal.A; 
        end
        % Mantemos B, C, D fixos se a falha for só em A (b e k)
        % Mas usamos SysReal para garantir.
        
        % Ruídos
        proc_noise = (sqrt(Q) * randn(n_states, 1)) / sqrt(dt);
        meas_noise = (sqrt(R) * randn(n_out, 1)); % Vetor 2x1
        
        % Dinâmica Real (Euler)
        dx = Ar * x(:,k) + SysNom.B * w_in(k) + proc_noise;
        x(:,k+1) = x(:,k) + dt * dx;
        
        % Medição (2 Saídas)
        y_k = SysNom.C * x(:,k) + SysNom.D * w_in(k) + meas_noise;
        
        % Observador
        dy_hat = SysNom.C * x_hat(:,k) + SysNom.D * w_in(k); % y estimado sem correção
        dx_hat = SysNom.A * x_hat(:,k) + SysNom.B * w_in(k) + L * (y_k - dy_hat);
        x_hat(:,k+1) = x_hat(:,k) + dt * dx_hat;
        
        % Resíduo
        residuo(:,k) = y_k - dy_hat;
    end
    SNR_calc = target_SNR_dB; % Retorno simplificado
end