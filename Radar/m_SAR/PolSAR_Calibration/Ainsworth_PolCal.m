function [u_op,v_op,w_op,z_op,alpha_op] = Ainsworth_PolCal(SLC_HH,SLC_HV,SLC_VH,SLC_VV,Flag)
% Polarization Calibration Based on Ainsworth Algorithm.
%
% ���룺
%   1��SLC_HH    ѡ������� HH ͨ���� SLC ����
%   2��SLC_HV               HV
%   3��SLC_VH               VH
%   4��SLC_VV               VV
% ע������ʹ�������һ�£�����ǰ�պ󷢡���ͬAinsworth�㷨��;
%   5��Flag      ��ǣ�a��Ϊ0�������������ս⣻b��Ϊ1�������������ȫ��ֵ���м�ֵ�����ս⣩;
%                ������Ҫ���ԣ����Ƽ�ѡ0;
%
% �����
%   1��������� u_op,v_op,w_op,z_op,alpha_op
%   ע1��
%       ��� Flag==1�����������������1��Ԫ�ر�ʾ��ֵ����2����������α�ʾ�����������
%       ��� Flag==0���������һ��ֵ����ʾ�������ս⣻
%   ע2��
%       ����û�жԽ���ͨ����ƽ�� k �� ����ϵͳ���� Y ���꣨��Ϊ��������Ҫ�Ƿ��������ݣ�
%       k �� Y ������ĳ�����������Ƿ��������ݽ�����⡣
%
% �������ֹ����2017.12.13. 21:19


%%
% -------------------------------------------------------------------------
%                           Ainsworth �㷨
% -------------------------------------------------------------------------
%
% ���룺ĳһ�����򣨷ֲ�Ŀ�꣩��ȫ��������ͨ���� SLC ����
%
% ��������������������� u,v,w,z �� alpha�������� Y �� k��


%% ����۲����O������ؾ���C��4��4����
C = zeros(4,4);
% C11 = < Ohh * conj(Ohh) >
C(1,1) = mean(mean(SLC_HH.*conj(SLC_HH)));
% C12 = < Ohh * conj(Ohv) >
C(1,2) = mean(mean(SLC_HH.*conj(SLC_HV)));
% C13 = < Ohh * conj(Ovh) >
C(1,3) = mean(mean(SLC_HH.*conj(SLC_VH)));
% C14 = < Ohh * conj(Ovv) >
C(1,4) = mean(mean(SLC_HH.*conj(SLC_VV)));

% C21 = < Ohv * conj(Ohh) >
C(2,1) = mean(mean(SLC_HV.*conj(SLC_HH)));
% C22 = < Ohv * conj(Ohv) >
C(2,2) = mean(mean(SLC_HV.*conj(SLC_HV)));
% C23 = < Ohv * conj(Ovh) >
C(2,3) = mean(mean(SLC_HV.*conj(SLC_VH)));
% C24 = < Ohv * conj(Ovv) >
C(2,4) = mean(mean(SLC_HV.*conj(SLC_VV)));

% C31 = < Ovh * conj(Ohh) >
C(3,1) = mean(mean(SLC_VH.*conj(SLC_HH)));
% C32 = < Ovh * conj(Ohv) >
C(3,2) = mean(mean(SLC_VH.*conj(SLC_HV)));
% C33 = < Ovh * conj(Ovh) >
C(3,3) = mean(mean(SLC_VH.*conj(SLC_VH)));
% C34 = < Ovh * conj(Ovv) >
C(3,4) = mean(mean(SLC_VH.*conj(SLC_VV)));

% C41 = < Ovv * conj(Ohh) >
C(4,1) = mean(mean(SLC_VV.*conj(SLC_HH)));
% C42 = < Ovv * conj(Ohv) >
C(4,2) = mean(mean(SLC_VV.*conj(SLC_HV)));
% C43 = < Ovv * conj(Ovh) >
C(4,3) = mean(mean(SLC_VV.*conj(SLC_VH)));
% C44 = < Ovv * conj(Ovv) >
C(4,4) = mean(mean(SLC_VV.*conj(SLC_VV)));
% ���ˣ��۲����O������ؾ���C��4��4�����Ѿ�������ϡ�


%%
% �ýű��У����� u,v,w,z,alpha ��ʾΪһ������
% �� 1 ��Ԫ�ر�ʾ��ֵ
% �� 2 ����������α�ʾ���������


%% ��ʼ������
% 1���������ӣ�u0 = v0 = w0 = z0 = 0
u(1) = 0;
v(1) = 0;
w(1) = 0;
z(1) = 0;
% 2��k ��Ϊ1��k0 = 1 ���� ���ڸýű�������������k������ڸýű���ʼ��Ϊk0.
k0 = 1;
% 3������ alpha �ĳ�ֵ alpha0
alpha0_abs = abs(C(3,3)/C(2,2))^(1/4);
% -----------------------------------------------------------------
% alpha0_phase = atan(C(3,2)) / 2;% ԭʼ�����еı��ʽ������Ϊ���󣬸�Ϊ����ʽ����
alpha0_phase = angle(C(3,2)) / 2;
% -----------------------------------------------------------------
alpha(1) = alpha0_abs * exp(1j*alpha0_phase);
clear alpha0_abs;clear alpha0_phase;


%% �������㶨����� u,v,w,z,alpha
N_iter = 100;% ��������
Epsilon = 1e-15;% ��ֵ

% ����������������1���ﵽ������������2��alpha �ı仯С�ڸ�����ֵ
for i_iter = 1 : N_iter
    if 1 == i_iter  % ��1�μ���ʱ������ʽ����ʱ�� D_Matrix(M) ���ڲ����Ǵ��ţ���˼�Ϊ�Խ��� G.
                    % ����ֱ�ӽ� inv(G) * C * inv(G') չ����ı��ʽ.
        Sigma_1_Matrix = [
            C(1,1)/( abs(k0*alpha(i_iter))^2 ),                    C(1,2)*conj(alpha(i_iter))/(k0*alpha(i_iter)), C(1,3)/(k0*abs(alpha(i_iter))^2),              C(1,4)*conj(k0)*conj(alpha(i_iter))/(k0*alpha(i_iter));
            C(2,1)*alpha(i_iter)/(conj(k0)*conj(alpha(i_iter))),   C(2,2)*abs(alpha(i_iter))^2,                   C(2,3)*alpha(i_iter)/(conj(alpha(i_iter))),    C(2,4)*conj(k0)*abs(alpha(i_iter))^2;
            C(3,1)/(conj(k0)*abs(alpha(i_iter))^2),                C(3,2)*conj(alpha(i_iter))/alpha(i_iter),      C(3,3)/(abs(alpha(i_iter))^2),                 C(3,4)*conj(k0)*conj(alpha(i_iter))/alpha(i_iter);
            C(4,1)*k0*alpha(i_iter)/(conj(k0)*conj(alpha(i_iter))),C(4,2)*k0*abs(alpha(i_iter))^2,                C(4,3)*k0*alpha(i_iter)/(conj(alpha(i_iter))), C(4,4)*abs(k0*alpha(i_iter))^2;
        ];% ԭʼ����ʽ(10).
    end
    
    A = ( Sigma_1_Matrix(2,1) + Sigma_1_Matrix(3,1) )/2;
    B = ( Sigma_1_Matrix(2,4) + Sigma_1_Matrix(3,4) )/2;
    
    X_Matrix = [
        Sigma_1_Matrix(2,1) - A;
        Sigma_1_Matrix(3,1) - A;
        Sigma_1_Matrix(2,4) - B;
        Sigma_1_Matrix(3,4) - B;
    ];
    Zeta_Matrix = [
        0,                      0,                      Sigma_1_Matrix(4,1),    Sigma_1_Matrix(1,1);
        Sigma_1_Matrix(1,1),    Sigma_1_Matrix(4,1),    0,                      0;
        0,                      0,                      Sigma_1_Matrix(4,4),    Sigma_1_Matrix(1,4);
        Sigma_1_Matrix(1,4),    Sigma_1_Matrix(4,4),    0,                      0;
    ];
    Tau_Matrix = [
        0,                      Sigma_1_Matrix(2,2),    Sigma_1_Matrix(2,3),    0;
        0,                      Sigma_1_Matrix(3,2),    Sigma_1_Matrix(3,3),    0;
        Sigma_1_Matrix(2,2),    0,                      0,                      Sigma_1_Matrix(2,3);
        Sigma_1_Matrix(3,2),    0,                      0,                      Sigma_1_Matrix(3,3);
    ];

    X_Matrix_Need = [
        real(X_Matrix);
        imag(X_Matrix);
    ];% 8 �� 1
    Zeta_Tau_Matrix_Need = [
        real( Zeta_Matrix + Tau_Matrix ),   -1*imag( Zeta_Matrix - Tau_Matrix );
        imag( Zeta_Matrix + Tau_Matrix ),      real( Zeta_Matrix - Tau_Matrix );
    ];% 8 �� 8
    
    % ������Է����飬�õ���������������������������
    %       ���Է�����Ϊ�� X_Matrix_Need = Zeta_Tau_Matrix_Need * delta_Solve;
    delta_Solve = linsolve( Zeta_Tau_Matrix_Need, X_Matrix_Need );% ����MATLAB�����������
    
    delta_u = delta_Solve(1) + 1j*delta_Solve(5);
    delta_v = delta_Solve(2) + 1j*delta_Solve(6);
    delta_w = delta_Solve(3) + 1j*delta_Solve(7);
    delta_z = delta_Solve(4) + 1j*delta_Solve(8);
    
    % ���´������� u,v,w,z
    u(i_iter+1) = u(i_iter) + delta_u;
    v(i_iter+1) = v(i_iter) + delta_v;
    w(i_iter+1) = w(i_iter) + delta_w;
    z(i_iter+1) = z(i_iter) + delta_z;
    
    % ���� Sigma_2_Matrix
    Matrix_uvwz = [
        1,                          v(i_iter+1),                w(i_iter+1),                v(i_iter+1)*w(i_iter+1);
        z(i_iter+1),                1,                          w(i_iter+1)*z(i_iter+1),    w(i_iter+1);
        u(i_iter+1),                u(i_iter+1)*v(i_iter+1),    1,                          v(i_iter+1);
        u(i_iter+1)*z(i_iter+1),    u(i_iter+1),                z(i_iter+1),                1;
    ];
%     Sigma_2_Matrix = inv(Matrix_uvwz) * Sigma_1_Matrix * inv( Matrix_uvwz' ); % ע������Ǹ��ǹ���ת�á�
    Sigma_2_Matrix = Matrix_uvwz \ Sigma_1_Matrix;
    Sigma_2_Matrix = Sigma_2_Matrix / ( Matrix_uvwz' );
    
    % ��������� alpha_Updata ������ alpha
    alpha_Updata_abs = abs(Sigma_2_Matrix(3,3)/Sigma_2_Matrix(2,2))^(1/4);
% -----------------------------------------------------------------
%     alpha_Updata_phase = atan(Sigma_2_Matrix(3,2)) / 2;% ԭʼ�����еı��ʽ������Ϊ���󣬸�Ϊ����ʽ����
    alpha_Updata_phase = angle(Sigma_2_Matrix(3,2)) / 2;
% -----------------------------------------------------------------
    alpha_Updata = alpha_Updata_abs * exp(1j*alpha_Updata_phase);
    alpha(i_iter+1) = alpha(i_iter) * alpha_Updata;
    
    % ���㶨�����
    %   ע����һ������� alpha ��old�����Ǳ��θ��º�ģ����ԭʼ���ס�
    D_Matrix = diag( [alpha(i_iter), 1/alpha(i_iter), alpha(i_iter), 1/alpha(i_iter)] )...
        * Matrix_uvwz...
        * diag( [alpha_Updata, 1/alpha_Updata, alpha_Updata, 1/alpha_Updata] );
% --------------------------------------------------------------------
%     % ��1�� ���¹۲�Э�������Ϊ C = Sigma_2_Matrix;���������ź��������飬����Ҳ�����ʣ�
%     C = Sigma_2_Matrix;��������
    % ��2�������ü��� u=v=w=z=0 ʱ�ľ��� G ������ Sigma_1_Matrix��
    % ��ֱ�ӷ��ص���ѭ����ͷ��ɶҲ���� ���� ����
    
    % ��3���ð��� u,v,w,z �ľ��� D_Matrix(M) ������ Sigma_1_Matrix.
%     Sigma_1_Matrix = inv(D_Matrix) * C * inv(D_Matrix');% ���ʽ
    Sigma_1_Matrix = D_Matrix \ C;
    Sigma_1_Matrix = Sigma_1_Matrix / (D_Matrix');  
% --------------------------------------------------------------------
    
    % ����ﵽ��ֵ���������
    if ( abs(alpha(i_iter+1) - alpha(i_iter)) ) < Epsilon
        break;
    end
end


%% ����ֵ
if Flag == 0
    % ������ս�
    u_op = u(end);
    v_op = v(end);
    w_op = w(end);
    z_op = z(end);
    alpha_op = alpha(end);
else
    % �����������ȫ���⣬������ʼֵ���м�ֵ�����ս⡣
    u_op = u;
    v_op = v;
    w_op = w;
    z_op = z;
    alpha_op = alpha;
end


end