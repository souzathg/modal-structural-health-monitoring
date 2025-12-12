function residuo = run_observer_sim(SysNom, SysReal, L, t, w_in, tfalha)
% RUN_OBSERVER_SIM Simula o sistema real e o observador de Luenberger.
% Entradas:
%   SysNom: struct com .A, .B, .C, .D (Modelo Nominal)
%   SysReal: struct com .A, .B, .C, .D (Modelo com Dano)
%   L: Ganho do observador
%   t, w_in: vetores de tempo e entrada
%   tfalha: instante da troca de modelo

    dt = t(2) - t(1);
    n_states = size(SysNom.A, 1);
    n_out = size(SysNom.C, 1);
    N = length(t);
    
    x = zeros(n_states, N); 
    xhat = zeros(n_states, N);
    residuo = zeros(n_out, N);
    
    % Condições iniciais
    x(:,1) = [0;0;0;0]; xhat(:,1) = [0;0;0;0];

    for k = 1:N-1
        % Troca do sistema físico no tempo da falha
        if t(k) < tfalha
            Ar = SysNom.A; Cr = SysNom.C; Dr = SysNom.D;
        else
            Ar = SysReal.A; Cr = SysReal.C; Dr = SysReal.D;
        end
        
        % 1. Medição do Real
        y_k = Cr*x(:,k) + Dr*w_in(k);
        
        % 2. Estimativa
        yhat_k = SysNom.C*xhat(:,k) + SysNom.D*w_in(k);
        
        % 3. Resíduo
        r_k = y_k - yhat_k;
        residuo(:,k) = r_k;
        
        % 4. Integração (Euler)
        % Estado Real
        dx = Ar*x(:,k) + SysNom.B*w_in(k);
        x(:,k+1) = x(:,k) + dt*dx;
        
        % Estado Observador (usa sempre modelo nominal + correção L)
        dx_hat = SysNom.A*xhat(:,k) + SysNom.B*w_in(k) + L*r_k;
        xhat(:,k+1) = xhat(:,k) + dt*dx_hat;
    end
end