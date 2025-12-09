function [SysModal, T] = convert_to_modal(SysFisico)
% CONVERT_TO_MODAL Transforma um sistema de espaço de estados para a forma canônica modal.
%
% Entradas:
%   SysFisico: Struct contendo .A, .B, .C, .D (Coordenadas Físicas)
%
% Saídas:
%   SysModal: Struct contendo .A, .B, .C, .D (Coordenadas Modais)
%   T: Matriz de transformação tal que x_modal = T * x_fisico

    % Cria o objeto de estado-espaço do MATLAB
    sys_obj = ss(SysFisico.A, SysFisico.B, SysFisico.C, SysFisico.D);
    
    % Utiliza a função canon para obter a forma modal
    % 'modal' retorna a forma de Jordan Real (blocos 2x2 para pares complexos)
    [sys_m, T] = canon(sys_obj, 'modal');
    
    % Empacota de volta em uma estrutura simples
    SysModal.A = sys_m.A;
    SysModal.B = sys_m.B;
    SysModal.C = sys_m.C;
    SysModal.D = sys_m.D;
    
    % Exibe informações úteis no console
    fprintf('--- Transformação Modal Concluída ---\n');
    fprintf('Autovalores encontrados (Diagonal de A):\n');
    disp(eig(SysModal.A));
end