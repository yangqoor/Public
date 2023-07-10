%   ���������ֵ��
%   �㷨�ο�����:  ������. MATLAB6.xͼ����. �廪��ѧ������, 2002: 261-262.
function [th,segImg]=thresh_md(cX,map)
count=imhist(cX,map);
[m,n]=size(cX);
N=m*n-sum(sum(find(cX==0),1));
L=size(count);      %��ͼ��Ҷȵȼ�
count=count/N;      %������Ҷȳ��ֵĸ���
%�ҳ����ָ��ʲ�Ϊ0����С�Ҷ�
for i=2:L
  if count(i)~=0
    st=i-1;
    break;
  end
end
%�ҳ����ָ��ʲ�Ϊ0�����Ҷ�
for i=L:-1:1
  if count(i)~=0
    nd=i-1;
    break;
  end
end
f=count(st+1:nd+1);
p=st;q=nd-st;       %p,q�ֱ�Ϊ�Ҷ���ʼ�ͽ���ֵ
%����Ҷȵ�ƽ��ֵ
u=0;
for i=1:q
  u=u+f(i)*(p+i-1);
  ua(i)=u;
end;
%����ͼ���ƽ���Ҷ�
for i=1:q
  w(i)=sum(f(1:i));
end;
%�����ѡ��ͬkֵʱ,A����ĸ���
d=(u*w-ua).^2./(w.*(1-w));
%�����󷽲��Ӧ�ĻҶȼ�
[y,tp]=max(d);
%th��Ϊ�����ֵ
th=tp+p;

segImg=(cX>th);

