function [ r,f1 ] = sep_angulares(size,spokes )
%UNTITLED4 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
hsup=(size-1)/2;
[x,y]=meshgrid([-hsup:hsup]);
[THETA,r]=cart2pol(x,y);
f1=sin(THETA*spokes);
f1=f1>=0;

end

