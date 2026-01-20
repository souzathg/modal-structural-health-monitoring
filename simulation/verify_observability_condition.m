function verify_observability_condition(A, C)
% VERIFY OBSERVABILITY CONDITION: Veririfica a condição de observabilidade
% do sistema
% Entradas: Matriz A e C de um sistema no espaço de estados
    rankA = rank(A);
    rankOb = rank(obsv(A,C));
    
    fprintf("O posto da matriz de observabilidade é: " + rankOb + "\n")
    
    if rankA - rankOb == 0
        isObservable = true;
    else
        isObservable = false;
    end
    
    fprintf("O sistema é completamente observável? " + isObservable + "\n")
end