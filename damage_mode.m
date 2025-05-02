close all

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

sys = ss(A, B, C2, D);

sys1 = ss(A1,B1, C21, 0);
sys2 = ss(A2, B2, C22, 0);

figure
bodemag(sys, 'k', ...
    sys1, 'b--', ...
    sys2, 'r--')
legend ('Sistema','Modo 1', 'Modo 2')
grid minor