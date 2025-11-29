function [w_in, t] = generate_chirp(Fs, Tchirp, Ampl, Fstart, Fstop)
% GENERATE_CHIRP Gera um sinal de varredura duplo.
% Retorna o vetor de sinal w_in e o vetor de tempo t.

    dt = 1/Fs;
    t_final = 2 * Tchirp;
    t = 0:dt:t_final;
    
    BW = Fstop - Fstart;
    
    % Parte 1 (0 a Tchirp)
    tVec1 = 0:dt:Tchirp;
    w_p1 = Ampl * sin(2*pi*(Fstart.*tVec1 + BW/(2*Tchirp).*tVec1.^2));
    
    % Parte 2 (Tchirp a Final)
    tVec2 = (Tchirp+dt):dt:t_final;
    w_p2 = Ampl * sin(2*pi*(Fstart.*(tVec2 - Tchirp) + BW/(2*Tchirp).*(tVec2 - Tchirp).^2));
    
    % Concatenação e ajuste de tamanho para bater com t
    w_in = [w_p1, w_p2];
    
    % Garante consistência de tamanho (corta excesso se houver arredondamento)
    min_len = min(length(t), length(w_in));
    w_in = w_in(1:min_len);
    t = t(1:min_len);
end