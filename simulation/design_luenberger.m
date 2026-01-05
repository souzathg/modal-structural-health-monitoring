function [L, polos_alocados] = design_luenberger(SysNom, fator_rapidez)
% DESIGN_LUENBERGER Projeta o ganho do Observador de Luenberger por Alocação de Polos.
%
% Metodologia (Seção 4.6.1 do TCC):
%   1. Analisa os polos de malha aberta do sistema.
%   2. Define os polos desejados como N vezes mais rápidos (parte real).
%   3. Calcula o ganho L usando a fórmula de Ackermann (place).
%
% Entradas:
%   SysNom: Estrutura do sistema nominal (.A, .B, .C, .D)
%   fator_rapidez: Quantas vezes o observador deve ser mais rápido (ex: 3)
%
% Saídas:
%   L: Matriz de ganho do observador
%   polos_alocados: Vetor com os polos complexos escolhidos

    fprintf('--- Projetando Observador de Luenberger ---\n');

    % 1. Obter polos do sistema original
    polos_sys = eig(SysNom.A);
    
    % 2. Definir a localização desejada
    % A estratégia é aumentar a magnitude da parte real (estabilidade/rapidez)
    % mantendo a parte imaginária (frequência de oscilação) ou ajustando-a.
    
    % Regra do TCC: "polos do observador deveriam ser três vezes mais rápidos"
    % Nota: Adicionamos um pequeno offset (-0.1) para garantir estabilidade
    % numérica caso algum polo original esteja muito próximo do eixo imaginário.
    polos_desejados = real(polos_sys) * fator_rapidez + 1i * imag(polos_sys) - 0.1;
    
    % Ordenar polos para consistência visual (opcional)
    polos_desejados = sort(polos_desejados);

    % 3. Calcular o Ganho L
    % L' = place(A', C', polos)'
    % Usamos place em vez de acker para melhor condicionamento numérico
    try
        L = place(SysNom.A', SysNom.C', polos_desejados)';
        
        fprintf('Ganho L calculado com sucesso (Fator: %dx).\n', fator_rapidez);
        fprintf('Polos do Observador alocados em:\n');
        disp(polos_desejados);
        
        polos_alocados = polos_desejados;
        
    catch ME
        error('Erro ao alocar polos. Verifique se o sistema é observável ou se há polos repetidos.');
    end
end