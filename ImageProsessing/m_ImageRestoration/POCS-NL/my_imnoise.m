% �����˹�����������1Ϊ��������
%v: ����
%im:������ͼ��
%imn:im with noise

%type:
      %1:'unit'
      %2:'gaussian'
      %3:���˹�ź�
function imn=my_imnoise(v,im,type);
if type==1
    noise=rand(size(im))-0.5    ;
    noise=sqrt(v/var(noise(:)))*noise;
    imn=noise;
end

if type==2
    noise=randn(size(im));
    noise=sqrt(v/var(noise(:)))*noise;
    imn=noise;
end


      