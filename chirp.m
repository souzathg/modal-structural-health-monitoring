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