%% �˺������������Ѿ������Ļز�

%%
function [echo,MethodFlag] = SetEcho(SignalPara,RangePara,AzimuthPara,RadarPara,TargetPara)

j=sqrt(-1);
c=SignalPara.c;
Rref=RangePara.Rref;
TargetPos=TargetPara.TargetPos;

Vr=RadarPara.Vr;
tr=RangePara.tr;
ta=AzimuthPara.ta;

Na=AzimuthPara.Na;
Nr=RangePara.Nr;
echo=zeros(Na,Nr);

ta2=ta'*ones(1,Nr);
tau=ones(Na,1)*tr;

MethodFlag=0;%MethodFlag����ֱ�ӽ����Ϊ1���������

for n = 1:1%TargetPara.TargetNum
    Rt=sqrt((Vr.*ta2-TargetPos(n,2).*ones(Na,Nr)).^2+(TargetPos(n,1).*ones(Na,Nr)).^2);
    %
    R_delta=Rt-Rref;
    
    
    %   sita = atan( (Vr.*ta2-TargetPos(n,2).*ones(Na,Nr))/TargetPos(n,1) );
    %      wa=(sinc(0.886.*sita./AzimuthPara.beta_bw)).^2;
    wa=((abs(ta2-(TargetPos(n,2)/Vr.*ones(Na,Nr))))<=(AzimuthPara.Ls/2/Vr.*ones(Na,Nr)));%��λ����ͼ
    wr=((abs(tau-2.*Rt./c))<=(SignalPara.Tp/2.*ones(Na,Nr)));%��������ͼ
    
    if MethodFlag==0
        echo=echo+exp(-j*4*pi/c*(SignalPara.gama.*(tau-2*Rref/c)+SignalPara.fc).*R_delta ...
            +j*4*pi*SignalPara.gama/(c^2)*R_delta.^2).* ...
            ((abs(ta2-(TargetPos(n,2)/Vr.*ones(Na,Nr))))<=(AzimuthPara.Ls/2/Vr.*ones(Na,Nr))).* ...
            ((abs(tau-2*Rt./c))<=(SignalPara.Tp/2.*ones(Na,Nr)));      %ֱ�ӽ��
    else if MethodFlag==1
            echo=echo+exp(j*2*pi*(SignalPara.fc.*(tau-2*Rt/c)) ...
                +j*pi*SignalPara.gama*(tau-2*Rt/c).^2).*wa.*wr;
            
    else
            
            % % cs test echo
            echo=echo+exp(-j*4*pi*(SignalPara.fc.*Rt./c) ...
                +j*pi*SignalPara.gama.*(tau-2*Rt/c).^2).*wa.*wr;
        
        end
    end
 end
    %
    if MethodFlag==1
        
        alpha_a=2;%��λ��λͼչ�����ӣ���λ����ͼӦ�ñȻز��е�����Ŀ���Ҫ����һЩ���������ܱ�֤�����е�Ŀ��Ļز������Խ��
        alpha_r=2;%��������λͼչ�����ӣ���������ͼӦ�ñȻز��е�����Ŀ���Ҫ����һЩ���������ܱ�֤�����е�Ŀ��Ļز������Խ��
        %���ݣ�����״������25ҳ
        
        wa=(abs(ta2-(TargetPos(n,2)/Vr.*ones(Na,Nr)))<=AzimuthPara.Ls*alpha_a/2/Vr.*ones(Na,Nr));
        wr=(abs(tau-2*Rref./c)<=SignalPara.Tp*alpha_r/2.*ones(Na,Nr));
        echo_ref=exp(j*2*pi*(SignalPara.fc.*(tau-2*Rref/c))+j*pi*SignalPara.gama*(tau-2*Rref/c).^2).*wa.*wr;
        echo=echo.*conj(echo_ref);
    end
end
