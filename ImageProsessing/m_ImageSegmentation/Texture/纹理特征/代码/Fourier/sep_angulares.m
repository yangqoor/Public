function [ r,f1 ] = sep_angulares(size,spokes )
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
hsup=(size-1)/2;
[x,y]=meshgrid([-hsup:hsup]);
[THETA,r]=cart2pol(x,y);
f1=sin(THETA*spokes);
f1=f1>=0;

end

