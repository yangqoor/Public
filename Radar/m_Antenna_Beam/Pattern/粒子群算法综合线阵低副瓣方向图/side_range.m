%----------------�����򡪡�------------
clc;
clear;
eps;
c=3e8;                     % ����
fc=1.3e9;                  % ����Ƶ�ʣ�hz��
numda=c/fc;                % ���� wave length
N=16;                      % ������
d=0.5*numda;               % ��Ԫ���
L=N*d;                     % ���߳�
k=(2*pi)/numda;            % ����
fs=10;                      % ����Ƶ��
theta=-90:1/fs:90;    % ��λ�Ƕȷ�Χ��������Χ��(rad)
Ns=length(theta);          % ��������
B=90;    %���������Ϊ90��
theta_d=0;                % ����������
%---------------------��Ӧֵ����------------------------
%------��Ŀ�꺯��--------
fd=[10^(-1.5)*ones(1,800) ones(1,200) 10^(-1.5)*ones(1,801)];
fd=20*log10(fd);
plot(theta,fd,':');hold on;
xlim([-90 90]);
%---------------------����Ⱥ�㷨------------------------
pop_size = 30;          %   pop_size ��Ⱥ��С
part_size = N/2;            %   part_size ���Ӵ�С������Ԫ�������ֵ����Ŀ����Ԫ����Գƣ�������Ŀֻȡһ�롣
a_max=1;a_min=0.3;  %���ȵķ�Χ
c1=1.49445;c2=1.49445;           %ѧϰ����
v_max=1.0;           %����ٶ�
% w=1;               %����Ȩ�����ӣ�Ϊ�ɱ�ֵ�����ò�ͬ��Ȩ�����ӿ���������ٶȡ�
NN=300;%��������
    %---------------------��ʼѰ��------------------------
    pop_a_ini=rand(pop_size,N/2);
    p_a_b=zeros(pop_size,N/2,NN+1); %���Ӿֲ����Ž⣬��ÿ��������Ѱ�Ź����е���ʷ����ֵ��
    p_a_g=zeros(N/2,NN+1);%����ȫ�����Ž⣬�������ӵ�����ֵ��
        %-------��ʼ������-------
        for i=1:pop_size
             f_ini_array(i,:)=present_array(Ns,d,theta,pop_a_ini(i,:));
             erro_ini(i)=array_erro(f_ini_array(i,:),fd);
        end
    [C,I] = min(erro_ini);
    p_a_g(:,1)=pop_a_ini(I,:);%����ʼ������ȫ������ֵ���д洢
    p_a_b(:,:,1)=pop_a_ini;%���������ӵĹ�������ֵ����Ϊ��ʼֵ
    v_a=v_max*(rand(pop_size,NN+1)-0.5*ones(pop_size,NN+1));%���ӷ��ȵ��ٶȳ�ʼ��
    pop_a_present=zeros(pop_size,N/2,NN+1);
    pop_a_present(:,:,1)=pop_a_ini;
    f_present=zeros(pop_size,Ns,NN+1);%ÿ��������ÿ�ε����еķ���ͼ
    f_present(:,:,1)=f_ini_array;
    f_g_array=zeros(NN+1,Ns);%��������Ⱥ��ÿ�ε����е�ȫ�����Ž�ķ���ͼ
    erro_present=zeros(pop_size,NN+1);%���ۺ����ĳ�ʼ����
    erro_present(:,1)=erro_ini;%�����ۺ����ĳ�ʼֵ���д洢
    erro_b=zeros(pop_size,NN+1);%��ʼ�������ڵ��������е�����ֵ��
    erro_b(:,1)=erro_ini;
    erro_g_b=zeros(NN+1,1); %��ʼ���������ӵ�ȫ������ֵ����ֵ��
    erro_g_b(1)=C;%��������Ⱥ�ڳ�ʼʱ���������
    
        %---------------------��������------------------------
        for n=1:NN  
            for ii=1:pop_size    
                 for kk=1:N/2
                     v_a(ii,n+1)=(-0.5*n/NN+0.9)*v_a(ii,n)+c1*rand*(p_a_b(ii,kk,n)-pop_a_present(ii,kk,n))+c2*rand*(p_a_g(kk,n)-pop_a_present(ii,kk,n));%�����ٶȸ��¡�
                     
                     if abs(v_a(ii,n+1))>v_max%�ж������ٶ��Ƿ�Խ�磬�Լ�Խ���Ĵ���
                        v_a(ii,n+1)=v_max*v_a(ii,n+1)/abs(v_a(ii,n+1));
                     end   
                     
                    pop_a_present(ii,kk,n+1)=pop_a_present(ii,kk,n)+v_a(ii,n+1);%����λ�ø��¡�
                    
                    if pop_a_present(ii,kk,n+1)>a_max%�ж����Ӵ�С�Ƿ�Խ�磬�Լ�Խ���Ĵ���
                         pop_a_present(ii,kk,n+1)=a_max;                   
                    elseif  pop_a_present(ii,kk,n+1)<a_min
                         pop_a_present(ii,kk,n+1)=a_min;
                    end        
                    
                    if pop_a_present(ii,kk,n+1)==pop_a_present(ii,kk,n) %Ϊ�˱��������������θ��º���������ĳ�����������ͬ������ͬ�����������С���е�������һ��ɲ�Ҫ��
                         pop_a_present(ii,kk,n+1)=pop_a_present(ii,kk,n+1)-0.01;
                    end
                 end
             
             f_present(ii,:,n+1)=present_array(Ns,d,theta,pop_a_present(ii,:,n+1)); %���÷���ͼ������ÿһ�ε����ķ���ͼ������ÿһ��λ�ǵ�ȡֵ���м��㡣
             erro_present(ii,n+1)=array_erro(f_present(ii,:,n+1),fd);%��ÿһ������ÿһ�ε���������ۺ������м��㡣
            
                %---------------------ÿ�������Ը��º�����������Ž�ĸ���------------------------
                 if erro_present(ii,n+1)<=erro_b(ii,n)
                    erro_b(ii,n+1)=erro_present(ii,n+1);
                    p_a_b(ii,:,n+1)=pop_a_present(ii,:,n+1);
                 else
                    erro_b(ii,n+1)=erro_b(ii,n);
                    p_a_b(ii,:,n+1)= p_a_b(ii,:,n);
                 end 
                 
            end
            
                %---------------------ÿ�����Ӹ��º�ȫ�����Ž�ĸ���------------------------
                [C,I]=min(erro_b(:,n+1));
                erro_g_b(n+1)=C;
                p_a_g(:,n+1)=p_a_b(I,:,n+1);%���һ�ε�����ֵ����Ϊ���Ž����
                
        end
    %---------------------�������------------------------
f_best_array=present_array(Ns,d,theta,p_a_g(:,NN+1)');
plot(theta,f_best_array);grid on;
ylim([-60 0]);
figure
t=1:16;
amplitude=amplitude_curve(p_a_g(:,NN+1));
plot(t,amplitude,'r*');
xlim([1 16]);
ylim([0.1 1.1]);
   